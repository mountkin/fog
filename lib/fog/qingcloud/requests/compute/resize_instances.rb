module Fog
  module Compute
    class QingCloud
      class Real

        # Resize specified instance
        # If target_instance_type is specified, cpu and memory will be ignored. 
        # Otherwise cpu and memory must be specified.
        # {API Reference}[https://docs.qingcloud.com/api/instance/resize_instances.html]
        def resize_instances(instance_id, target_instance_type = nil, cpu = nil, memory = nil)
          params = Fog::QingCloud.indexed_param('instances', instance_id)
          if target_instance_type
            params['instance_type'] = target_instance_type
          else
            raise Fog::QingCloud::Errors::CommonClientError, "cpu must be one of [1, 2, 4, 8, 16]." unless [1, 2, 4, 8, 16].include? cpu
            raise Fog::QingCloud::Errors::CommonClientError, "memory must be one of [512, 1024, 2048, 4096, 8192, 16384]." unless [512, 1024, 2048, 4096, 8192, 16384].include? memory

            params['cpu'] = cpu
            params['memory'] = memory

          end
          request({
            'action'    => 'ResizeInstances'
          }.merge!(params))
        end

      end

      class Mock
        def resize_instances(instance_id, target_instance_type = nil, cpu = nil, memory = nil)
          instance_ids = Array(instance_id)
          instance_set = self.data[:instances].select {|id, s| instance_ids.include?(id) }

          if instance_set.empty?
            raise Fog::QingCloud::Errors::NotFound, "The instance ID '#{instance_ids.join(', ')}' does not exist"
          else
            instance_set.map! do |x| 
              x['status'] = 'pending'
              x['transition_status'] = 'resizeping'
              self.data[:modified_at][x['instance_id']] = Time.now
              if target_instance_type
                x['instance_type'] = target_instance_type
                # TODO: assign vcpus_current and memory_current
              else
                x['cpu'] = cpu
                x['memory'] = memory
                x['instance_type'] = '' #?? 
              end
              x
            end
            response = Excon::Response.new
            response.status = 200
            response.body = {
              'action' => 'ResizeInstancesResponse',
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
