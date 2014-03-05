module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all specified security group rules
        # {API Reference}[https://docs.qingcloud.com/api/sg/describe_security_group_rules.html]
        def describe_security_group_rules(group_id = nil, rule_ids = nil, direction = nil)
          params = {
            'action'  => 'DescribeSecurityGroupRules',
            'security_group' => group_id,
            'direction' => direction
          }.merge(Fog::QingCloud.indexed_param('security_group_rules', rule_ids))
          request(params)
        end

      end

      class Mock

        def describe_security_group_rules(group_id = nil, rule_ids = nil, direction = nil)
          response = Excon::Response.new

          if group_id
            sg = self.data[:security_groups][group_id]
            raise Fog::QingCloud::Errors::NotFound, "security group #{group_id} does not exist" unless sg
            rule_set = sg['rules']
          else
            rule_set = self.data[:security_groups].map {|sg| sg['rules']}
          end

          if rule_ids
            rule_set = rule_set.select {|id, r| [*rule_ids].include? id}
          end

          if direction
            rule_set = rule_set.select {|id, r| r['direction'] == direction}
          end

          response.status = 200
          response.body = {
            'action'             => 'DescribeSecurityGroupRulesResponse',
            'security_group_rule_set' => rule_set.values,
            'total_count'        => rule_set.length,
            'ret_code'           => 0
          }
          response
        end

      end
    end
  end
end
