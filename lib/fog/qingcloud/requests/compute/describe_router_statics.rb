module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/describe_router_statics.html]
        def describe_router_statics(rt_id, rule_id = [], type = nil)
          args = {'action' => 'DescribeRouterStatics', 
                  'static_type' => type, 
                  'router' => rt_id}
          args.merge!(Fog::QingCloud.indexed_param('router_statics', [*rule_id]))
          request(args)
        end
      end

      class Mock
        def describe_router_statics(rt_id, rule_id = [], type = nil)
        end        
      end
    end
  end
end
