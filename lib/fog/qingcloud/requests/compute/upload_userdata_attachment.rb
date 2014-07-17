module Fog
  module Compute
    class QingCloud
      class Real

        # Delete a key pair that you own
        # {API Reference}[https://docs.qingcloud.com/api/userdata/upload_userdata_attachment.html]
        def upload_userdata_attachment(options)
          request(options.merge('action' => 'UploadUserDataAttachment'))
        end

      end

      class Mock

        def upload_userdata_attachment(options)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'action'   => 'UploadUserDataAttachment',
            'attachment_id' => 'uda-' + Fog::Mock.random_hex(8),
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
