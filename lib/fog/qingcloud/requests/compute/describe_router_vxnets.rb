module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified routers
        # {API Reference}[https://docs.qingcloud.com/api/router/describe_router_vxnets.html]
        def describe_router_vxnets(router_id, options = {})
          request({
            'action' => 'DescribeRouterVxnets',
            'router' => router_id
          }.merge!(options))
        end
      end

      class Mock
        def describe_router_vxnets(roter_id, options = {})
        end
      end
    end
  end
end
