require "xmlrpc/client"

# Base Class for resources using the spacewalk XMLRPC API
# Has three properties that need to be provided for the spacewalk login
# :spacewalk_server - The full url of the xml rpc api endpoint on the spacewalk spacewalk_server
# :spacewalk_login - The login user
# :spacewalk_password - The password for the login user
#
# A method executeXmlRpc is provided to help with executing commands agaist the server.
# A block passed to the method will be passed the xmlrpc client and auth key from a successful logon.
# Once the block is finished the client is logged out.
module Spacewalk
  class XmlrpcBase < Chef::Resource
    property :spacewalk_server, String, required: true
    property :spacewalk_login, String, required: true
    property :spacewalk_password, String, required: true


#
# Method to execute a surrounded by a xmlrpc log on/log off
# The xmlrpc client and the auth key to use with it are
# passed into the supplied block
    def executeXmlRpc
      @SPACEWALK_URL = "http://#{spacewalk_server}/rpc/api"
      @SPACEWALK_LOGIN = "#{spacewalk_login}"
      @SPACEWALK_PASSWORD = "#{spacewalk_password}"

      @client = XMLRPC::Client.new2(@SPACEWALK_URL)
      @key = @client.call('auth.login', @SPACEWALK_LOGIN, @SPACEWALK_PASSWORD)

      #yield to the block passing it the clien and the auth key
      yield @client, @key

      @client.call('auth.logout', @key)

    end
  end
end
