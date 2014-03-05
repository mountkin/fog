module Fog
  module Compute
    class QingCloud
      class Real

        # Create an EBS volume
        # {API Reference}[https://docs.qingcloud.com/api/volume/create_volumes.html]
        def create_volumes(zone, size, options = {})
          request({
            'action'            => 'CreateVolumes',
            'zone'  => zone,
            'size'              => size,
          }.merge(options.reject{|k, v| v.nil?}))
        end

      end

      class Mock

        def create_volumes(zone, size, options = {})
          response = Excon::Response.new
          if zone && size
            if size < 10
              raise Fog::Compute::QingCloud::Error.new("InvalidParameterValue => Volume of #{size}GiB is too small; minimum is 10GiB.")
            end

            response.status = 200
            volume_id = Fog::QingCloud::Mock.volume_id
            self.data = {
              "action" => "CreateVolumesResponse",
              "job_id" => "j-bm6ym3r8",
              "volumes" => [volume_id],
              "ret_code" => 0
            }
            response.body = self.data
          else
            response.status = 200
            response.body = {
              'ret_code' => 1100
            }
            unless zone
              response.body['message'] = 'The request must contain the parameter zone'
            else
              response.body['message'] = 'The request must contain the parameter size'
            end
          end
          response
        end

      end
    end
  end
end
