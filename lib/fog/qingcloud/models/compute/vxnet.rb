require 'fog/qingcloud/model'
require 'ostruct'

module Fog
  module Compute
    class QingCloud

      class Vxnet < Fog::QingCloud::Model

        identity  :id,                          :aliases => 'vxnet_id'
        attribute :router_id
        attribute :type,                        :aliases => 'vxnet_type'
        attribute :server_ids,                  :aliases => 'instance_ids'
        attribute :name,                        :aliases => 'vxnet_name'
        attribute :created_at,                  :aliases => 'create_time'
        attribute :description

        # Removes an existing vxnet
        #
        # vxnet.destroy
        #
        # ==== Returns
        #
        # True or false depending on the result
        #

        def destroy
          requires :id
          service.delete_vxnets(id)
          true
        rescue Fog::QingCloud::Errors::PermissionDenied => e
          raise e unless e.message =~ /has already been deleted/i
          true
        end


        # Create a vxnet
        #

        def save
          if persisted?
            modify_attributes(name, description)
          else
            requires :type
            options = {'vxnet_name' => name,
                       'count' => 1,
                       'vxnet_type' => type}
            self.id = service.create_vxnets(options).body['vxnets'].first
            reload
          end
          true
        end

        def join_router(router, cidr_block = '192.168.1.0/24', features = 1)
          requires :id
          router = router.id if router.respond_to? :id
          service.join_router(router, id, cidr_block, features)
          true
        end
        
        def leave_router
          requires :id, :router_id
          service.leave_router(router_id, id)
          true
        end

        def router
          requires :id, :router_id
          service.routers.get(router_id)
        end
        
        def servers
          requires :id
          vxnet_instances = service.describe_vxnet_instances(id).body['instance_set']
          instance_ids = vxnet_instances.map { |i| i['instance_id'] }
          service.servers.all('instance-id' => instance_ids)
        end
        
        # The following attributes are available if the vxnet is connected to a router.
        #   ip_network
        #   manager_ip
        #   features
        #   dyn_ip_start
        #   dyn_ip_end
        #   create_time
        def network_attrs
          requires :id
          return OpenStruct.new unless router_id
          OpenStruct.new(service.describe_router_vxnets(router_id).body['router_vxnet_set'].find{ |x| x['vxnet_id'] == id })
        end
      end
    end
  end
end
