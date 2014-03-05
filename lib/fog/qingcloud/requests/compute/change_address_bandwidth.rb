module Fog
  module Compute
    class QingCloud
      class Real

        # Delete a key pair that you own
        # {API Reference}[https://docs.qingcloud.com/api/eip/change_address_bandwidth.html]
        def change_address_bandwidth(id, bandwidth)
          args = {
            'action'    => 'ChangeEipsBandwidth',
            'bandwidth' => bandwidth
          }.merge(Fog::QingCloud.indexed_param('eips', id))
          request(args)
        end

      end

      class Mock

        def change_address_bandwidth(id, bandwidth)

          response = Excon::Response.new
          response.status = 200

          unless (unknown_eips = [*id] - self.data[:addresses].keys).empty?
            raise Fog::QingCloud::Errors::NotFound, "unknown eips: #{unknown_eips.join(', ')}"
          end

          [*id].each do |x|
            self.data[:addresses][x]['bandwidth'] = bandwidth
          end

          response.body = {
            'action' => 'ChangeEipsBandwidthResponse',
            'job_id' => Fog::QingCloud::Mock.job_id,
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
