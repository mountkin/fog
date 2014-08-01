require 'fog/qingcloud/model'
require 'fog/qingcloud/models/compute/router_rules'

module Fog
  module Compute
    class QingCloud
      class Router < Fog::QingCloud::Model
        identity  :id,               :aliases => 'router_id'
        attribute :status
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
        rescue Fog::QingCloud::Errors::PermissionDenied => e
          raise e unless e.message =~ /has already been deleted/i
          true
        end

        def ready?
          status == 'active' and transition_status == ''
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
            wait_for {status == 'poweroffed'}
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

        def rules(rule_ids = [], type = nil)
          requires :id
          json = service.describe_router_statics(id, rule_ids, type).body['router_static_set']
          json.inject([]) do |ret, o|
            ret << RouterRule.convert_type(o['static_type']).new(o)
          end
        end
        alias_method :statics, :rules

        def get_rule(rule_id)
          rules(rule_id).first
        end
        alias_method :get_static, :get_rule

        def add_rules(rules, auto_apply = true)
          requires :id
          service.add_router_statics(id, RouterRule.to_query([*rules]))
          service.update_routers(id) if auto_apply
          wait_for {ready?}
          true
        end
        alias_method :add_rule, :add_rules
        alias_method :add_statics, :add_rules
        alias_method :add_static, :add_rules

        def add_port_forward_rule(src_port, dst_ip, dst_port, protocol, auto_apply = true)
          rule = PortForwardRule.new(
            src_port: src_port,
            dst_ip: dst_ip,
            dst_port: dst_port,
            protocol: protocol
          )
          add_rules(rule, auto_apply)
        end

        def add_vpn_rule(type, port, protocol, cidr, auto_apply = true)
          rule = VPNRule.new(
            vpn_type: type,
            vpn_port: port,
            vpn_protocol: protocol,
            vpn_cidr_block: cidr
          )
          add_rules(rule, auto_apply)
        end

        def add_dhcp_rule(server_id, dhcp_options, auto_apply = true)
          rule = DHCPRule.new(
            server_id: server_id,
            dhcp_options: dhcp_options
          )
          add_rules(rule, auto_apply)
        end

        def add_gre_rule(gre_options, auto_apply = true)
          rule = GRERule.new(gre_options: gre_options)
          add_rules(rule, auto_apply)
        end

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
