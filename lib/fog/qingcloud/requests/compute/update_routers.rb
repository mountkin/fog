module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/update_routers.html]
        def update_routers(id)
          args = {'action' => 'UpdateRouters'}
          args.merge!(Fog::QingCloud.indexed_param('routers', [*id]))
          request(args)
        end
      end

      class Mock
        def update_routers(id)
        end        
      end
    end
  end
end
