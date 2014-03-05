require 'fog/core/collection'
require 'fog/qingcloud/models/compute/vxnet'

module Fog
  module Compute
    class QingCloud

      class Vxnets < Fog::Collection

        attribute :filters

        model Fog::Compute::QingCloud::Vxnet

        # Creates a new vxnet
        #
        # QingCloud.vxnets.new

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        # Returns an array of all Vxnets that have been created
        #
        # QingCloud.vxnets.all
        #
        # ==== Returns
        #
        # Returns an array of all VPCs
        #
        #>> QingCloud.vxnets.all
        # <Fog::QingCloud::Compute::Vxnet
        # filters={}
        # [
        # vxnet_id=vxnet-someId,
        # state=[pending|available],
        # vpc_id=vpc-someId
        # cidr_block=someIpRange
        # available_ip_address_count=someInt
        # tagset=nil
        # ]
        # >
        #

        def all(filters = filters)
          unless filters.is_a?(Hash)
            Fog::Logger.warning("all with #{filters.class} param is deprecated, use all('vxnet-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'vxnet-id' => [*filters]}
          end
          self.filters = filters
          data = service.describe_vxnets(filters).body
          load(data['vxnet_set'].map do |vxnet|
              rt = vxnet.delete('router')
              vxnet['router_id'] = rt['router_id'] if rt
              vxnet
            end
          )
        end

        # Used to retrieve a Vxnet
        # vxnet-id is required to get the associated VPC information.
        #
        # You can run the following command to get the details:
        # QingCloud.vxnets.get("vxnet-12345678")
        #
        # ==== Returns
        #
        #>> QingCloud.vxnets.get("vxnet-12345678")
        # <Fog::QingCloud::Compute::Vxnet
        # vxnet_id=vxnet-someId,
        # state=[pending|available],
        # vpc_id=vpc-someId
        # cidr_block=someIpRange
        # available_ip_address_count=someInt
        # tagset=nil
        # >
        #

        def get(vxnet_id)
          if vxnet_id
            self.class.new(:service => service).all('vxnet-id' => vxnet_id).first
          end
        end

      end

    end
  end
end
