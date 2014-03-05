module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/poweroff_routers.html]
        # {API Reference}[https://docs.qingcloud.com/api/router/poweron_routers.html]
        def routers_power(id, action)
          action = action.downcase.capitalize
          args = {'action' => "Power#{action}Routers"}
          args.merge!(Fog::QingCloud.indexed_param('routers', [*id]))
          request(args)
        end
      end

      class Mock
        def routers_power(id, action)
        end        
      end
    end
  end
end
