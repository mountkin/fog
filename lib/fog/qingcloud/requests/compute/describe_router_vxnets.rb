module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified routers
        # {API Reference}[https://docs.qingcloud.com/api/router/describe_router_vxnets.html]
        def describe_router_vxnets(router_id, vxnet_id)
          request({
            'action' => 'DescribeRouterVxnets',
            'router' => router_id,
            'vxnet'  => vxnet_id
          })
        end
      end

      class Mock
        def describe_router_vxnets(router_id, vxnet_id)
        end
      end
    end
  end
end
