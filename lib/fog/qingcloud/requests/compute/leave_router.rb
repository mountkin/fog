module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/leave_router.html]
        def leave_router(rt_id, vxnet_id)
          args = {'action' => 'LeaveRouter',
                  'router' => rt_id}
          args.merge! Fog::QingCloud.indexed_param('vxnets', [*vxnet_id])
          request(args)
        end
      end

      class Mock
        def leave_router(rt_id, vxnet_id)
        end        
      end
    end
  end
end
