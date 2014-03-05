module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/instance/terminate_instances.html]
        def terminate_instances(instance_id)
          params = Fog::QingCloud.indexed_param('instances', instance_id)
          request({
            'action'    => 'TerminateInstances',
          }.merge!(params))
        end

      end

      class Mock

        def terminate_instances(instance_id)
          response = Excon::Response.new
          instance_id = [*instance_id]
          if (self.data[:instances].keys & instance_id).length == instance_id.length
            response.status = 200
            for id in instance_id
              self.data[:instances].delete(id)
            end

            describe_addresses('instance-id' => instance_id).body['eip_set'].each do |address|
              if address['resource'].has_key?('resource_id') and instance_id.include?(address['resource']['resource_id'])
                disassociate_address(address['eip_id'])
              end
            end

            describe_volumes('verbose' => 1,'instance-id' => instance_id).body['volume_set'].each do |volume|
              if !volume['instance'].empty? and instance_id.include?(volume['instance']['instance_id'])
                detach_volume(volume['volume_id'])
              end
            end
            
            response.body = {
              'action'    => 'TerminateInstancesResponse',
              'job_id'    => Fog::QingCloud::Mock.job_id,
              'ret_code'  => 0
            }

            response
          else
            raise Fog::QingCloud::Errors::NotFound, "The instance ID '#{instance_id}' does not exist"
          end
        end

      end
    end
  end
end
