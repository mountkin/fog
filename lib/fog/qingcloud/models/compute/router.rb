require 'fog/qingcloud/model'
require 'fog/qingcloud/models/compute/router_rules'

module Fog
  module Compute
    class QingCloud
      class Router < Fog::QingCloud::Model
        identity  :id,               :aliases => 'router_id'
        attribute :state,             :aliases => 'status'
        attribute :is_applied
        attribute :description
        attribute :transition_status
        attribute :security_group_id
        attribute :created_at,        :aliases => 'create_time'
        attribute :private_ip
        attribute :type,             :aliases => 'router_type'
        attribute :vxnet_ids,         :aliases => 'vxnets'
        attribute :name,             :aliases => 'router_name'
        attribute :status_time
        attribute :public_ip
        attribute :address_id

        
        def initialize(attributes = {})
          super
        end

        def save
          if persisted?
            modify_attributes(name, description)
          else
            self.id = service.create_routers(name, 1, security_group_id).body['routers'].first
            wait_for {ready?}
          end
          true
        end

        def destroy
          requires :id
          service.delete_routers(id)
          true
        end

        def ready?
          state == 'active'
        end

        def eip=(ip)
          raise Fog::Errors::Error, "Unsupported eip parameter for creating routers" unless persisted?
          if ip =~ /^[0-9]{1,3}\..+/
            ip_str = ip
            ip_id = service.addresses.get(ip).id
          elsif ip.respond_to? :id
            ip_str = ip.public_ip
            ip_id = ip.id
          elsif ip && ip != ''
            ip_obj = service.addresses.get(ip)
            ip_str = ip_obj.public_ip
            ip_id  = ip_obj.id
          else
            ip_str = ip_id = nil
          end
          service.modify_router_attributes(id, 'eip' => ip_id)
          service.update_routers(id)
          merge_attributes('public_ip' => ip_str, 'address_id' => ip_id)
          true
        end

        def eip
          service.addresses.get(address_id)
        end

        alias_method :address, :eip
        alias_method :address=, :eip=

        def security_group=(sg_id)
          if persisted?
            service.modify_router_attributes(id, 'security_group' => sg_id)
            service.apply_security_group(sg_id)
          end
          merge_attributes('security_group_id' => sg_id)
        end
        
        # Return an object of the security group attached to this router.
        def security_group
          requires :id
          service.security_groups.get(security_group_id)
        end

        def poweroff
          if persisted?
            service.routers_power(id, 'off')
            wait_for {state == 'poweroffed'}
          end
          true
        end
        alias_method :stop,  :poweroff

        def poweron
          if persisted?
            service.routers_power(id, 'on')
            wait_for {ready?}
          end
          true
        end
        alias_method :start, :poweron

        # Vxnets connected to this router
        def subnets
          requires :id
          data = service.describe_router_vxnets(id).body['router_vxnet_set']
          data.map { |net| Fog::Compute::QingCloud::Subnet.new(net) }
        end

        def rules(rule_ids = [], type = nil)
          requires :id
          json = service.describe_router_statics(id, rule_ids, type).body['router_static_set']
          json.inject([]) do |ret, o|
            ret << Fog::Compute::QingCloud::RouterRule.convert_type(o['static_type']).new(o)
          end
        end
        alias_method :statics, :rules

        def get_rule(rule_id)
          rules(rule_id).first
        end
        alias_method :get_static, :get_rule

        def add_rules(rules)
          requires :id
          service.add_router_statics(id, Fog::Compute::QingCloud::RouterRule.to_query([*rules]))
          service.update_routers(id)
          wait_for {ready?}
          true
        end
        alias_method :add_rule, :add_rules
        alias_method :add_statics, :add_rules
        alias_method :add_static, :add_rules

        def delete_rules(rule_id)
          requires :id
          service.delete_router_statics([*rule_id])
          service.update_routers(id)
          wait_for {ready?}
          true
        end
        alias_method :delete_rule, :delete_rules
        alias_method :delete_statics, :delete_rules
        alias_method :delete_static, :delete_rules

      end
    end
  end
end
