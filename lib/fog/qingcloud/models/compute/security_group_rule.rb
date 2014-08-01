require 'fog/qingcloud/model'

module Fog::Compute
  class QingCloud
    class SecurityGroupRule < Fog::QingCloud::Model
      
      identity :id,            :aliases => 'security_group_rule_id'
      
      attribute :group_id,     :aliases => 'security_group_id'
      attribute :priority
      attribute :protocol
      attribute :action
      attribute :direction
      attribute :name,         :aliases => 'security_group_rule_name'
      attribute :val1
      attribute :val2
      attribute :val3
      attribute :auto_apply

      def initialize(attrs = {})
        if attrs['protocol']
          case attrs['protocol'].to_sym
          when :tcp, :udp
            attrs['val1'], attrs['val2'] = to_range(attrs['port_range']) if attrs['port_range']
          when :icmp
            attrs['val1'] ||= attrs.delete('icmp_type')
            attrs['val2'] ||= attrs.delete('icmp_code')
          end
        end
        attrs['val3'] ||= attrs.delete('src_ip')
        @auto_apply = attrs.delete('auto_apply') || true

        super attrs
      end
      
      def save
        requires :group_id
        if persisted?
          requires :priority
          modify_attributes(priority, name)
        else
          requires :protocol, :priority
          self.id = service.add_security_group_rules(group_id, to_query).body['security_group_rules'].first
        end
        service.apply_security_group(group_id) if @auto_apply
        true
      end

      def destroy
        requires :id
        service.delete_security_group_rules(id)
        service.apply_security_group(group_id) if @auto_apply
        true
      end

      def modify_attributes(priority, name = nil)
        requires :id, :priority
        service.modify_security_group_rule_attributes(id, priority, name)
        merge_attributes('priority' => priority, 'name' => name)
        true
      end

      alias_method :src_ip=, :val3=
      alias_method :src_ip, :val3
      alias_method :icmp_type=, :val1=
      alias_method :icmp_code=, :val2=

      def port_range=(range)
        r = to_range(range)
        merge_attributes('val1' => r.first, 'val2' => r.last)
      end

      def port_range
        return nil if protocol == 'icmp'
        port_end = val2.empty? ? val1 : val2
        (val1.to_i .. port_end.to_i)
      end

      def to_range(stuff)
        if stuff.is_a? Range
          [stuff.first, stuff.end]
        elsif stuff.is_a? Integer
          [stuff, stuff]
        end
      end

      def to_query(n = 1)
        query = ['protocol', 'priority', 'action', 
                 'direction', 'val1', 'val2', 'val3'
                ].inject({}) do |ret, x|
          ret["rules.#{n}.#{x}"] =  send(x.to_sym)
          ret
        end
        query["rules.#{n}.security_group_rule_name"] = name
        query
      end
    end
  end
end
