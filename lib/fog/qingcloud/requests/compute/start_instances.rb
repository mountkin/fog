module Fog
  module Compute
    class QingCloud
      class Real

        # Start specified instance
        # {API Reference}[https://docs.qingcloud.com/api/instance/start_instances.html]
        def start_instances(instance_id)
          params = Fog::QingCloud.indexed_param('instances', instance_id).merge('action' => 'StartInstances')
          request(params)
        end

      end

      class Mock
        def start_instances(instance_id)
          instance_ids = Array(instance_id)

          instance_set = self.data[:instances].select {|id, s| instance_ids.include?(id) }

          if instance_set.empty?
            raise Fog::QingCloud::Errors::NotFound, "The instance ID '#{instance_ids.join(', ')}' does not exist"
          else
            instance_set.map! do |x| 
              x['status'] = 'pending'
              x['transition_status'] = 'starting'
              self.data[:modified_at][x['instance_id']] = Time.now
              x
            end
            response = Excon::Response.new
            response.status = 200
            response.body = {
              'action' => 'StartInstancesResponse',
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
