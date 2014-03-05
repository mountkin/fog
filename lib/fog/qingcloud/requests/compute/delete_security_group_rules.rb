module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/sg/delete_security_group_rules.html]
        def delete_security_group_rules(rule_id)
          args = {
            'action' => 'DeleteSecurityGroupRules'
          }.merge(Fog::QingCloud.indexed_param('security_group_rules', rule_id))
          request(args)
        end
      end

      class Mock
        def delete_security_group_rules(rule_id)
          group_id = self.data[:security_group_rule_maps][rule_id]
          raise Fog::QingCloud::Errors::NotFound, "security group #{rule_id} does not exist" unless group_id

          self.data[:security_groups][group_id]['rules'].delete_if {|rid, r| [*rule_id].include?(rid)} 
          self.data[:security_groups][group_id]['is_applied'] = 0

          response = Excon::Response.new
          response.body = {
            'action'   => 'DeleteSecurityGroupRulesResponse',
            'security_group_rules' => [*rule_id],
            'ret_code' => 0
          }
          response
        end        
      end
    end
  end
end
