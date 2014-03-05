require 'fog/core/collection'
require 'fog/qingcloud/models/compute/router'

module Fog
  module Compute
    class QingCloud

      class Routers < Fog::Collection

        attribute :filters

        model Fog::Compute::QingCloud::Router

        ACTIVE_STATUS = %w[pending active poweroffed suspended]
        
        def initialize(attributes)
          self.filters ||= {}
          filters['status'] = ACTIVE_STATUS unless filters['status']
          super
        end

        def all(filters = self.filters)
          self.filters = filters
          data = service.describe_routers(filters).body['router_set']
          load(data.map do |r|
              eip = r.delete('eip') || {}
              unless eip.empty?
                r['public_ip'] = eip['eip_addr']
                r['address_id'] = eip['eip_id']
              end
              vxnets = r.delete('vxnets') || []
              r['vxnets'] = []
              vxnets.each do |x|
                r['vxnets'] << service.vxnets.get(x['vxnet_id'])
              end
              r
            end
          )
        end
        
        def get(router_id)
          if router_id
            self.class.new(:service => service).all('router-id' => router_id).first
          end
        rescue Fog::QingCloud::Errors::NotFound
          nil
        end

      end
    end
  end
end


