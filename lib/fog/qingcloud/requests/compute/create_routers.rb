module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/create_routers.html]
        def create_routers(name = nil, count = 1, security_group = nil)
          args = {'action' => 'CreateRouters',
                  'count' => count,
                  'router_name' => name,
                  'security_group' => security_group}.reject {|k, v| v.nil?}
          request(args)
        end
      end

      class Mock
        def create_routers(name = nil, count = 1, security_group = nil)
        end        
      end
    end
  end
end
