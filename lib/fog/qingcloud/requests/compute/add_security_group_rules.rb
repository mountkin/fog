module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/sg/add_security_group_rules.html]
        def add_security_group_rules(group_id, options)
          args = {
            'action' => 'AddSecurityGroupRules',
            'security_group' => group_id
          }.merge(options)
          request(args)
        end
      end

      class Mock
        def add_security_group_rules(group_id, options)
          sg = self.data[:security_groups][group_id]
          raise Fog::QingCloud::Errors::NotFound, "security group #{group_id} does not exist" unless sg

          args = []
          # Convert options from {'rules.1.key' => 'xxx', 'rules.2.key' => 'yyy'} to [{'key' => 'xxx'},{'key' => 'yyy'}]
          options.each_pair do |k, v|
            n, param = k.split('.')[1..-1]
            n = n.to_i
            args[n] ||= {}
            args[n][param] = v
          end
          args.compact!

          sg['rules'] |= args.inject({}) do |ret, r| 
            r['security_group_rule_id'] = Fog::QingCloud::Mock.security_group_rule_id
            ret[r['security_group_rule_id']] = r
            self.data[:security_group_rule_maps][r['security_group_rule_id']] = group_id
            ret
          end
          sg['is_applied'] = 0

          response = Excon::Response.new
          response.body = {
            'action'   => 'AddSecurityGroupRulesResponse',
            'security_group_rules' => sg['rules'].keys,
            'ret_code' => 0
          }
          response
        end        
      end
    end
  end
end
