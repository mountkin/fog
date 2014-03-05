module Fog
  module Compute
    class QingCloud
      class Real

        # Delete an EBS volume
        #
        # ==== Parameters
        # * volume_id<~String> - Id of volume to delete.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        #
        # { API Reference}[https://docs.qingcloud.com/api/volume/delete_volumes.html]
        def delete_volumes(volume_id)
          args = {
              'action'    => 'DeleteVolumes',
            }.merge(Fog::QingCloud.indexed_param('volumes', [*volume_id]))
          request(args)
        end

      end

      class Mock

        def delete_volumes(volume_id)
          response = Excon::Response.new
          if volume = self.data[:volumes][volume_id]
            if volume["attachmentSet"].any?
              attach = volume["attachmentSet"].first
              raise Fog::Compute::QingCloud::Error.new("Client.VolumeInUse => Volume #{volume_id} is currently attached to #{attach["instanceId"]}")
            end
            self.data[:deleted_at][volume_id] = Time.now
            volume['status'] = 'deleting'
            response.status = 200
            response.body = {
              'requestId' => Fog::QingCloud::Mock.request_id,
              'return'    => true
            }
            response
          else
            raise Fog::Compute::QingCloud::NotFound.new("The volume '#{volume_id}' does not exist.")
          end
        end

      end
    end
  end
end
