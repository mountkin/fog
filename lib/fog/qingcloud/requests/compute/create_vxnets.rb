module Fog
  module Compute
    class QingCloud
      class Real

        # Creates a Vxnet with the CIDR block you specify.
        # {API Reference}[https://docs.qingcloud.com/api/vxnet/create_vxnets.html]
        def create_vxnets(options)
          request({
            'action'     => 'CreateVxnets',
          }.merge!(options))

        end
      end

      class Mock
        def create_vxnets(options)
          Excon::Response.new.tap do |response|
            if options['vxnet_type']
              response.status = 200
              vxnet = {
                "vxnet_type" => 1,
                "vxnet_id" => Fog::QingCloud::Mock.vxnet_id,
                "instance_ids" => [
                  "i-syx7qtud"
                ],
                "vxnet_name" => "test",
                "create_time" => "2013-08-27T10:02:25Z",
                "router" => {
                  "router_id" => "rtr-b0u6sdj6",
                  "router_name" => "demo"
                },
                "description" => nil
              }
              self.data[:vxnets].push(vxnet)
              response.body = {
                'vxnets'   => [vxnet],
                'ret_code' => 0
              }
            else
              response.status = 200
              response.body = {
                'ret_code' => 1100,
                'message'  => 'vxnet_type cannot be empty'
              }
            end
          end
        end
      end
    end
  end
end
