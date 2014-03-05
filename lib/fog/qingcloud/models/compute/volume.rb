require 'fog/qingcloud/model'

module Fog
  module Compute
    class QingCloud

      class Volume < Fog::QingCloud::Model

        identity  :id,                    :aliases => 'volume_id'

        attribute :created_at,            :aliases => 'create_time'
        attribute :status_time
        attribute :server_id,             :aliases => 'instance_id'
        attribute :size
        attribute :state,                 :aliases => 'status'
        attribute :name,                  :aliases => 'volume_name'
        attribute :description
        attribute :transition_status
        attribute :zone

        def initialize(attributes = {})
          # assign server first to prevent race condition with persisted?
          self.server = attributes.delete(:server)
          super
        end

        def destroy
          requires :id

          service.delete_volumes(id)
          true
        end

        def ready?
          state == 'available'
        end

        def save
          if persisted?
            modify_attributes(name, description)
          else
            requires :size
            self.id = service.create_volumes(zone, size, 'name' => name).body['volumes'].first
            wait_for {ready?}
            if @server
              self.server = @server
            end
          end
          true
        end

        def server
          requires :server_id
          service.servers.get(server_id)
        end

        def server=(new_server)
          if new_server
            attach(new_server)
          else
            detach
          end
        end

        private

        def attach(new_server)
          if !persisted?
            @server = new_server
            self.zone = new_server.zone
          elsif new_server
            wait_for { ready? }
            @server = nil
            self.server_id = new_server.id
            service.attach_volumes(server_id, id)
            reload
          end
        end

        def detach(force = false)
          @server = nil
          self.server_id = nil
          if persisted?
            service.detach_volumes(server.id, id)
            reload
          end
        end

      end
    end
  end
end
