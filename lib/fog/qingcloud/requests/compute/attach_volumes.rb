module Fog
  module Compute
    class QingCloud
      class Real


        # Attach an  EBS volume with a running instance, exposing as specified device
        # {API Reference}[https://docs.qingcloud.com/api/volume/attach_volumes.html]
        def attach_volumes(instance_id, volume_id)
          request(
            'action'      => 'AttachVolumes',
            'volumes'     => [*volume_id],
            'instance'    => instance_id,
          )
        end

      end

      class Mock

        def attach_volumes(instance_id, volume_id)
          response = Excon::Response.new
          ids = [*volume_id]
          unless (unknown_ids = ids - self.data[:volumes].keys).empty?
              raise Fog::QingCloud::Errors::NotFound, "The volumes '#{unknown_ids.join(', ')}' are not exist."
          end
          
          instance = self.data[:instances][instance_id]
          unless instance
              raise Fog::QingCloud::Errors::NotFound, "The instance ID '#{instance_id}' does not exist."
          end

          response.status = 200
          ids.each do |vid|
            volume = self.data[:volumes][vid]['instance']
            unless volume['status'] == 'available'
              raise Fog::QingCloud::Errors::PermissionDenied, "Client.VolumeInUse => Volume #{vid} is unavailable"
            end
            volume['instance'] = {
              'instance_id' => instance_id,
              'instance_name' => instance['instance_name']
            }
            volume['status'] = 'in-use'
            instance['volume_ids'] |= [vid]
          end

          response.body = {
            'action' => 'AttachVolumesResponse',
            'job_id' => Fog::QingCloud::Mock.job_id,
            'ret_code' => 0
          }
        end

      end
    end
  end
end
