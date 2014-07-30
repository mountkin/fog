require 'fog/qingcloud/model'

module Fog
  module Compute
    class QingCloud

      class Address < Fog::QingCloud::Model

        identity  :id,                         :aliases => 'eip_id'
        attribute :public_ip,                  :aliases => 'eip_addr'
        attribute :name,                       :aliases => 'eip_name'

        attribute :server_id
        attribute :router_id
        attribute :bandwidth
        attribute :status
        attribute :need_icp
        attribute :transition_status

        def initialize(attributes = {})
          # assign server first to prevent race condition with persisted?
          self.server = attributes.delete(:server)
          super
        end

        def destroy
          requires_one :public_ip, :id
          unless self.id
            self.id = public_ip
            self.reload
          end
          service.release_address(id)
          true
        rescue Fog::QingCloud::Errors::PermissionDenied => e
          raise e unless e.message =~ /has already been deleted/i
          true
        end

        def server=(new_server)
          if new_server
            associate(new_server)
          else
            disassociate
          end
        end

        def ready?
          status == 'available' and transition_status == ''
        end

        def server
          service.servers.get(server_id)
        end

        def router
          service.routers.get(router_id)
        end

        def router=(router)
          rtid = router.respond_to?(:id) ? router.id : router
          if rtid
            # Associate
            service.routers.new('id' => rtid).eip = self
            self.router_id = rtid
          elsif router_id
            # Dissociate
            service.routers.new('id' => router_id).eip = nil
            self.router_id = nil
          end
          true
        end

        def save
          requires :bandwidth
          unless persisted?
            eip_id = service.allocate_address(bandwidth, 1, name, need_icp).body['eips'].first
            self.id = eip_id
            wait_for {ready?}
            if @server
              self.server = @server
            end
          else
            modify_attributes(name, description)
          end
          true
        end

        def change_bandwidth(bw)
          if persisted?
            service.change_address_bandwidth(id, bw)
          else
            bandwidth = bw
          end
        end

        private

        def associate(new_server)
          unless persisted?
            @server = new_server
          else
            @server = nil
            self.server_id = new_server.id
            service.associate_address(id, server_id)
          end
        end

        def disassociate
          @server = nil
          self.server_id = nil
          if persisted?
            service.disassociate_address(id)
          end
        end

      end

    end
  end
end
