module Fog
  module Compute
    class QingCloud
      class Real

        def leave_vxnet(vxnet_id, server_id)
          params = Fog::QingCloud.indexed_param('instances', [*server_id])
          params['vxnet'] = vxnet_id
          request({
            'action'    => 'LeaveVxnet',
          }.merge!(params))
        end
      end

      class Mock
        def leave_vxnet(vxnet_id, server_id)
          vxnets = self.data[:vxnets]

          # Transition from pending to available
          vxnets.each do |vxnet|
            case vxnet['state']
              when 'pending'
                vxnet['state'] = 'available'
            end
          end

          if filters['vxnet-id']
            vxnets = vxnets.reject {|vxnet| vxnet['vxnetId'] != filters['vxnet-id']}
          end

          Excon::Response.new(
            :status => 200,
            :body   => {
              'requestId' => Fog::QingCloud::Mock.request_id,
              'vxnetSet' => vxnets
            }
          )
        end
      end
    end
  end
end
