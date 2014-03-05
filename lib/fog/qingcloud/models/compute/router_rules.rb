require 'ostruct'

module Fog::Compute
  class QingCloud
    class RouterRule
      attr_reader :router_static_id, :vxnet_id, :create_time, :static_type
      alias_method :id, :router_static_id
      alias_method :type, :static_type
      
      def initialize(opts = {})
        @params = []
        opts.keys.each do |k| 
          if respond_to?("#{k}=".to_sym)
            send("#{k}=".to_sym, opts[k])
          else
            instance_variable_set("@#{k}".to_sym, opts[k])
          end
        end
        @static_type = self.class.const_get('TYPE')
      end

      def self.bind_param(req_key, alias_key)
        [req_key, alias_key].each do |x|
          class_eval <<-EOS, __FILE__, __LINE__
            def #{x}
              param = @params.find {|x| x.req_key == "#{req_key}" or x.alias_key == "#{alias_key}"}
              val = param.val if param
              val
            end

            def #{x}=(v)
              param = @params.find {|x| x.req_key == "#{req_key}" or x.alias_key == "#{alias_key}"}
              unless param
                param = OpenStruct.new({req_key: "#{req_key}", alias_key: "#{alias_key}", val: nil})
                @params << param
              end
              param.val = v
            end
          EOS
        end
      end

      def to_h(i)
        @params.inject({}) do |x, o|
          if o.val
            x["statics.#{i}.#{o.req_key}"] = o.val if o.val
            x["statics.#{i}.static_type"]  = type
          end
          x
        end
      end
      
      def self.convert_type(t)
        [PortForwardRule, VPNRule, DHCPRule, GRERule][t - 1]
      end

      def self.to_query(rules)
        rules.compact!
        (1..rules.length).inject({}) {|ret, i| ret.merge rules[i - 1].to_h(i)}
      end
    end

    class PortForwardRule < RouterRule
      TYPE = 1
      bind_param :val1, :src_port
      bind_param :val2, :dst_ip
      bind_param :val3, :dst_port
      bind_param :val4, :protocol
    end

    class VPNRule < RouterRule
      TYPE = 2
      bind_param :val1, :vpn_type
      bind_param :val2, :vpn_port
      bind_param :val3, :vpn_protocol
      bind_param :val4, :vpn_cidr_block
    end

    class DHCPRule < RouterRule
      TYPE = 3
      bind_param :val1, :server_id
      bind_param :val2, :dhcp_options
    end

    class GRERule < RouterRule
      TYPE = 4
      bind_param :val1, :gre_options
    end


  end
end
