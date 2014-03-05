module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/join_router.html]
        def join_router(rt_id, vxnet_id, ip_network, features = 1)
          args = {'action' => 'JoinRouter',
                  'router' => rt_id,
                  'vxnet'  => vxnet_id,
                  'ip_network' => ip_network,
                  'features' => features}
          request(args)
        end
      end

      class Mock
        def join_router(rt_id, vxnet_id, ip_network, features = 1)
        end        
      end
    end
  end
end
