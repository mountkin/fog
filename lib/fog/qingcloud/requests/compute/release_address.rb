module Fog
  module Compute
    class QingCloud
      class Real

        # Release an elastic IP address.
        # {API Reference}[https://docs.qingcloud.com/api/eip/release_eips.html]
        def release_address(id)
          args = Fog::QingCloud.indexed_param('eips', [*id])
          args['action'] = 'ReleaseEips'
          request(args)
        end

      end

      class Mock

        def release_address(id)
          response = Excon::Response.new
          ids = [*id]

          address = self.data[:addresses][public_ip_or_allocation_id] || self.data[:addresses].values.detect {|a| a['allocationId'] == public_ip_or_allocation_id }

          if address
            if address['allocationId'] && public_ip_or_allocation_id == address['publicIp']
              raise Fog::Compute::QingCloud::Error, "InvalidParameterValue => You must specify an allocation id when releasing a VPC elastic IP address"
            end

            self.data[:addresses].delete(address['publicIp'])
            response.status = 200
            response.body = {
              'requestId' => Fog::QingCloud::Mock.request_id,
              'return'    => true
            }
            response
          else
            raise Fog::Compute::QingCloud::Error.new("AuthFailure => The address '#{public_ip_or_allocation_id}' does not belong to you.")
          end
        end

      end
    end
  end
end
