require 'fog/core/collection'
require 'fog/qingcloud/models/compute/address'

module Fog
  module Compute
    class QingCloud

      class Addresses < Fog::Collection

        attribute :filters
        attribute :server

        model Fog::Compute::QingCloud::Address

        ACTIVE_STATUS = %w[pending available associated suspended]

        # Used to create an IP address
        # The IP address can be retrieved by running QingCloud.addresses.get("test").  See get method below.
        #

        def initialize(attributes)
          self.filters ||= {}
          filters['status'] = ACTIVE_STATUS unless filters['status']
          super
        end

        # QingCloud.addresses.all

        def all(filters = filters)
          self.filters = filters
          data = service.describe_addresses(filters).body
          load(data['eip_set'].map do |eip|
              if res = eip.delete('resource')
                eip['server_id'] = res['resource_id'] if res['resource_type'] == 'instance'
                eip['router_id'] = res['resource_id'] if res['resource_type'] == 'router'
              end
              eip
            end
          )
          if server
            self.replace(self.select {|address| address.server_id == server.id})
          end
          self
        end

        # Used to retrieve an IP address
        #
        # public_ip or eip-id is required to get the associated IP information.
        #
        # You can run the following command to get the details:
        # QingCloud.addresses.get("76.7.46.54")
        # or with eip_id:
        # QingCloud.addresses.get("eip-zpvk9pq7")

        def get(public_ip)
          if public_ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
            self.class.new(:service => service).all('public-ip' => public_ip).find {|x| x.public_ip == public_ip}
          elsif public_ip
            self.class.new(:service => service).all('eip-id' => public_ip).first
          end
        end

        def new(attributes = {})
          if server
            super({ :server => server }.merge!(attributes))
          else
            super(attributes)
          end
        end

      end

    end
  end
end
