module Fog
  module Compute
    class QingCloud
      class Real

        # Stop specified instance
        # {API Reference}[https://docs.qingcloud.com/api/instance/reset_instances.html]
        def reset_instances(instance_id)
          params = Fog::QingCloud.indexed_param('instances', instance_id)
          params['force'] = 1 if force
          request({
            'action'    => 'ResetInstances'
          }.merge!(params))
        end

      end

      class Mock
        def reset_instances(instance_id)
          instance_ids = Array(instance_id)
          instance_set = self.data[:instances].select {|id, s| instance_ids.include?(id) }

          if instance_set.empty?
            raise Fog::QingCloud::Errors::NotFound, "The instance ID '#{instance_ids.join(', ')}' does not exist"
          else
            instance_set.each do |x|
              unless ['running', 'stopped'].include? x['status']
                raise Fog::QingCloud::Errors::PermissionDenied, "instance must be in 'running' or 'stopped' status"
              end
            end

            instance_set.map! do |x| 
              x['status'] = 'pending'
              x['transition_status'] = 'reseting'
              self.data[:modified_at][x['instance_id']] = Time.now
              x
            end
            response = Excon::Response.new
            response.status = 200
            response.body = {
              'action' => 'ResetInstancesResponse',
              'job_id' => Fog::QingCloud::Mock.job_id,
              'ret_code' => 0
            }
            response
          end
        end
      end
    end
  end
end
