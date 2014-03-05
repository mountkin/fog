module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/delete_routers.html]
        def delete_routers(id)
          args = {'action' => 'DeleteRouters'}
          args.merge!(Fog::QingCloud.indexed_param('routers', [*id]))
          request(args)
        end
      end

      class Mock
        def delete_routers(id)
        end        
      end
    end
  end
end
