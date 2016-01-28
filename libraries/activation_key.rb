require "xmlrpc/client"
require_relative "spacewalk_xmlrpc"

# Custom resource for dealing with activation keys on the spacewalk server.
# Uses the xmlrpc api to communicate with the spacewalk server.
# Only create metods implemented so far

module Spacewalk
  class ActivationKey < XmlrpcBase
    resource_name :spacewalk_activation_key

    property :key_description, String, name_property: true, required: true # The description to use with for the key
    property :key_id, String # The key id, if blank and creating a key the server will generate one.
                             # A key is always prepended with an org id so a key provided to the create withh have the org id prepended
                             # For eample with or id 1 and key_id my_key_value the activation key would become 1-my_key_value
    property :base_channel, String # A base Channel to associate with the key
    property :universal_default, [TrueClass, FalseClass], default: true # Is the key the universal default, the server can only have one so any existing will be changed to false
    property :provisioning_entitled, [TrueClass, FalseClass], default: false # Is the key provisioning entitled
    property :virtualization_host, [TrueClass, FalseClass], default: false # Is the key virtualization_host entitled, can't be used with virtualization_host_platform
    property :virtualization_host_platform, [TrueClass, FalseClass], default: false # Is the key virtualization_host_platform entitled , can't be used with virtualization_host
    property :usage_limit, Fixnum # Sets a usage limit for the key, leave nil for unlimited
    property :generated_key_callback, Proc # A proc to be called and passed the generated key, is called even if no key is created with the key_id of the already existing key


    # Checks if a key matching the description exists, if not raises CurrentValueDoesNotExist allowing the converge
    # If a key matches the descriton the generated_key_callback is called with that keys key_id
    load_current_value do |new_resource|
      self.key_description = new_resource.key_description
      self.spacewalk_server = new_resource.spacewalk_server
      self.spacewalk_login = new_resource.spacewalk_login
      self.spacewalk_password = new_resource.spacewalk_password

      foundkey = false
      #Look though keys for one matching the description
      executeXmlRpc do |client, key|
        activationKeys = client.call('activationkey.listActivationKeys', key)
        for activationkey in activationKeys do
          if (self.key_description.eql?(activationkey["description"]))
            key_id = activationkey["key"]
            foundkey = true
            new_resource.generated_key.call(key_id) unless new_resource.generated_key.nil?
          end
        end
      end
      raise Chef::Exceptions::CurrentValueDoesNotExist unless foundkey
    end

    action :create do
      converge_if_changed :key_description do

        #Set up the entitlement array, it's just an array of strings
        entitlementArray = Array.new
        raise "Only one of virtualization_host or virtualization_host_platform can be specified" if virtualization_host && virtualization_host_platform
        array.push("provisioning_entitled") if provisioning_entitled
        array.push("virtualization_host") if virtualization_host
        array.push("virtualization_host_platform") if virtualization_host_platform

        #There are two create apis, one takes a usage limit, the other is for unlimited usage
        executeXmlRpc do |client, key|
          key_id = nil
          if (usage_limit.nil?)
            key_id = client.call('activationkey.create', key, key_id, key_description, base_channel, entitlementArray, universal_default)
          else
            key_id = client.call('activationkey.create', key, key_id, key_description, base_channel, usage_limit, entitlementArray, universal_default)
          end
          generated_key.call(key_id)
        end
      end
    end
  end
end
