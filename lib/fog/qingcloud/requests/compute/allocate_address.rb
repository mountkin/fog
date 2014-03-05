module Fog
  module Compute
    class QingCloud
      class Real

        # Acquire an elastic IP address.
        #
        # ==== Parameters
        # * domain<~String> - Type of EIP, either standard or vpc
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'publicIp'<~String> - The acquired address
        #     * 'requestId'<~String> - Id of the request
        #
        # {API Reference}[https://docs.qingcloud.com/api/eip/allocate_eips.html]
        def allocate_address(bandwidth, count = 1, name = nil, need_icp = 0)
          args = {'action' => 'AllocateEips',
                  'count' => count,
                  'eip_name' => name,
                  'bandwidth' => bandwidth,
                  'need_icp' => need_icp}
          request(args)
        end

      end

      class Mock

        def allocate_address(bandwidth, count = 1, name = nil, need_icp = 0)
          if (describe_addresses.body['eip_set'].size + count) > self.data[:quota][:addresses]
            raise Fog::QingCloud::Error::QuotaExceeded, "quota exceeded"
          end
          
          response = Excon::Response.new
          response.status = 200
          eips = {}
          count.times do |i|
            public_ip = Fog::QingCloud::Mock.ip_address
            eip = {
              'status' => 'available',
              'eip_id' => Fog::QingCloud::Mock.address_id,
              'description' => nil,
              'need_icp' => 0,
              'sub_code' => 0,
              'transition_status' => '',
              'icp_codes' => '',
              'eip_group' => {
                'eip_group_id' => 'eipg-00000000',
                'eip_group_name' => 'BGP multi-line'
              },
              'bandwidth' => bandwidth,
              'create_time' => Time.now,
              'status_time' => Time.now,
              'eip_name' => name,
              'resource' => {},
              'eip_addr' => public_ip
            }
            eips[eip['eip_id']] = eip
          end
          self.data[:addresses].merge! eips

          response.body = {
              'action' => 'AllocateEipsResponse',
              'eips' => eips.keys,
              'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
