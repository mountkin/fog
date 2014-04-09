module Fog
  module Compute
    class QingCloud
      class Real


        # Detach an  EBS volume from a running instance
        #
        # {API Reference}[https://docs.qingcloud.com/api/volume/detach_volumes.html]
        def detach_volumes(server_id, volume_id)
          args = {
            'action'   => 'DetachVolumes',
            'instance'    => server_id
          }.merge Fog::QingCloud.indexed_param('volumes', volume_id)
          request(args)
        end

      end

      class Mock

        def detach_volumes(server_id, volume_id)
          response = Excon::Response.new
          response.status = 200

          raise Fog::QingCloud::Errors::NotFound, "server #{server_id} not found" unless self.data[:instances][server_id]
          
          [*volume_id].each do |vid|
             self.data[:instances][server_id]['volume_ids'].delete(vid)
             self.data[:volumes][vid]['instance'] = {}
          end
          response.body = {
            'action' => 'DetachVolumesResponse',
            'job_id' => Fog::QingCloud::Mock.job_id,
            'ret_code' => 0
          }
        end

      end
    end
  end
end
