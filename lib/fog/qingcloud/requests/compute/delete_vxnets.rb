module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/vxnet/delete_vxnets.html]
        def delete_vxnets(vxnet_id)
          args = {
              'action' => 'DeleteVxnets'
            }.merge(Fog::QingCloud.indexed_param('vxnets', [*vxnet_id]))
          request(args)
        end
      end
      
      class Mock
        def delete_vxnets(vxnet_id)
          Excon::Response.new.tap do |response|
            if vxnet_id
              self.data[:vxnets].reject! { |v| [*vxnet_id].iclude?(v['vxnet_id']) }
              response.status = 200
            
              response.body = {
                  "action" => "DeleteVxnetsResponse",
                  "vxnets" => [
                    "vxnet-7mwzdbs",
                    "vxnet-f3y0h3q"
                  ],
                  "ret_code" => 0
                }
            else
              message = 'MissingParameter => '
              message << 'The request must contain the parameter vxnet_id'
              raise Fog::Compute::QingCloud::Error.new(message)
            end
          end
        end
      end
    end
  end
end
