require 'fog/qingcloud/model'
require 'fog/qingcloud/models/compute/security_group_rules'

module Fog
  module Compute
    class QingCloud

      class SecurityGroup < Fog::QingCloud::Model

        identity  :id,            :aliases => 'security_group_id'
        alias_method :group_id, :id

        attribute :description
        attribute :name,        :aliases => 'security_group_name'
        attribute :is_applied
        attribute :created_at, :aliases => 'create_time'
        attribute :is_default
        attribute :resources

        def add_rule(attrs)
          requires :id
          attrs['group_id'] = id
          service.security_group_rules.new(attrs).save
        end

        def ingress_rules
          requires :id
          rules(:ingress)
        end

        def egress_rules
          requires :id
          rules(:egress)
        end

        def rules(direction = nil)
          requires :id
          service.security_group_rules.all('group-id' => id, 'direction' => direction)
        end

        def delete_rules(rule_id)
          service.delete_security_group_rules(rule_id)
          true
        end
        alias_method :delete_rule, :delete_rules

        def apply
          requires :id
          service.apply_security_group(id)
          merge_attributes('is_applied' => 1)
          true
        end

        def destroy
          requires_one :group_id
          service.delete_security_groups(group_id)
          true
        rescue Fog::QingCloud::Errors::PermissionDenied => e
          raise e unless e.message =~ /has already been deleted/i
          true
        end

        # Create a security group
        #
        #  >> g = QingCloud.security_groups.new(:name => "some_name", :description => "something")
        #  >> g.save
        #
        # == Returns:
        #
        # True or an exception depending on the result. Keep in mind that this *creates* a new security group.
        # As such, it yields an InvalidGroup.Duplicate exception if you attempt to save an existing group.
        #

        def save
          if persisted?
            modify_attributes(name, description)
          else
            data = service.create_security_group(name).body
            merge_attributes('id' => data['security_group_id'])
            reload
          end
          true
        end

      end

    end
  end
end
