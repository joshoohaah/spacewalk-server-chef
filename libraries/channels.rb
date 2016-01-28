require "xmlrpc/client"
require_relative "spacewalk_xmlrpc"

# Custom resource for channels on spacewalk using the xmlrpc api
# Just lists all channels for now as a test.
module Spacewalk
  class Channels < XmlrpcBase

    resource_name :spacewalk_channels

    action :listAll do

      executeXmlRpc do |client, key|
        channels = client.call('channel.listAllChannels', key)
        for channel in channels do
          p channel["label"]
        end
      end
    end
  end
end
