module Fog
  module Compute
    class QingCloud
      class Real


        # Create a new security group
        def create_security_group(name = nil)
          request(
            'action'            => 'CreateSecurityGroup',
            'security_group_name'         => name
          )
        end

      end

      class Mock

        def create_security_group(name = nil)
          response = Excon::Response.new
          if self.data[:security_groups].length < self.data[:quota][:security_groups]
            data = {
              'is_applied'          => 1,
              'description'         => nil,
              'security_group_name' => name,
              'security_group_id'   => Fog::QingCloud::Mock.security_group_id,
              'is_default'          => 0,
              'create_time'         => Time.now,
              'resources'           => [],
              'rules'               => []
            }
            self.data[:security_groups][data['security_group_id']] = data
            response.body = {
              'action'   => 'CreateSecurityGroupResponse',
              'ret_code' => 0,
              'security_group_id' => data['security_group_id']
            }
            response
          else
            raise Fog::QingCloud::Errors::QuotaExceeded, "You can create #{self.data[:quota][:security_groups]} security groups."
          end
        end

      end
    end
  end
end
