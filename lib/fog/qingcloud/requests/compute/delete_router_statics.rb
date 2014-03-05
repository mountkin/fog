module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/update_routers.html]
        def delete_router_statics(rule_id)
          args = {'action' => 'DeleteRouterStatics'}.merge(
              Fog::QingCloud.indexed_param('router_statics', [*rule_id])
            )
          request(args)
        end
      end

      class Mock
        def delete_router_statics(rule_id)
        end        
      end
    end
  end
end
