require 'fog/core/collection'
require 'fog/qingcloud/models/compute/security_group_rule'

module Fog
  module Compute
    class QingCloud
      class SecurityGroupRules < Fog::Collection

        attribute :filters

        model Fog::Compute::QingCloud::SecurityGroupRule

        def all(filters = self.filters)
          group_id = filters['group-id']
          rule_id  = filters['rule-id']
          direction = filters['direction']
          direction = [:ingress, :egress].index(direction)
          data = service.describe_security_group_rules(group_id, rule_id, direction).body
          load(data['security_group_rule_set'])
        end

        def get(security_group_rule_id)
          if security_group_rule_id
            all('rule-id' => security_group_rule_id).first
          end
        rescue Fog::QingCloud::Errors::NotFound
          nil
        end
      end
    end
  end
end
