module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/sg/apply_security_group.html]
        def apply_security_group(id, server_ids = [])
          args = {'action' => 'ApplySecurityGroup',
                  'security_group' => id}
          args.merge!(Fog::QingCloud.indexed_param('instances', [*server_ids]))
          request(args)
        end
      end

      class Mock
        def apply_security_group(id, server_ids = [])
          sg = self.data[:security_groups][id]
          raise Fog::QingCloud::Errors::NotFound, "security group #{id} does not exist" unless sg
          unknown_servers = server_ids - self.data[:instances].keys
          raise Fog::QingCloud::Errors::NotFound, "servers #{unknown_servers.join(', ')} are not found" unless unknown_servers.empty?
          server_ids.each do |sid|
            self.data[:instances][sid]['security_group'] = {
              'is_default' => 0,
              'security_group_id' => id
            }
          end
          sg['is_applied'] = 1
          response = Excon::Response.new
          response.body = {
            'action'   => 'ApplySecurityGroupResponse',
            'job_id'   => Fog::QingCloud::Mock.job_id,
            'ret_code' => 0
          }
          response
        end        
      end
    end
  end
end
