module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/update_routers.html]
        def add_router_statics(rt_id, rules)
          args = {'action' => 'AddRouterStatics', 'router' => rt_id}.merge(rules)
          request(args)
        end
      end

      class Mock
        def add_router_statics(rt_id, rules)
        end        
      end
    end
  end
end
