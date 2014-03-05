module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/sg/modify_security_group_rule_attributes.html]
        def modify_security_group_rule_attributes(rule_id, priority, name = nil)
          args = {
            'action' => 'ModifySecurityGroupRuleAttributes',
            'security_group_rule' => rule_id,
            'security_group_rule_name' => name
          }
          request(args)
        end
      end

      class Mock
        def modify_security_group_rule_attributes(rule_id, priority, name = nil)
          group_id = self.data[:security_group_rule_maps][rule_id]
          raise Fog::QingCloud::Errors::NotFound, "security group #{rule_id} does not exist" unless group_id

          rule = self.data[:security_groups][group_id]['rules'][rule_id]
          rule['security_group_rule_name'] = name if name
          rule['priority'] = priority
          self.data[:security_groups][group_id]['is_applied'] = 0

          response = Excon::Response.new
          response.body = {
            'action'   => 'AddSecurityGroupRulesResponse',
            'security_group_rule_id' => rule['security_group_rule_id'],
            'ret_code' => 0
          }
          response
        end        
      end
    end
  end
end
