module Fog
  module Compute
    class QingCloud
      class Real

        # Create a new key pair
        # {API Reference} [https://docs.qingcloud.com/api/keypair/create_key_pairs.html]
        def create_key_pair(key_name = '', mode = 'system', encrypt_method = 'ssh-rsa', public_key = '')
          args = {
            'action'       => 'CreateKeyPair',
            'keypair_name' => key_name,
            'mode'         => mode
          }

          if mode == 'user'
            args['public_key'] = public_key
          else
            args['encrypt_method'] = encrypt_method
          end

          request(args)
        end

      end

      class Mock

        def create_key_pair(key_name = '', mode = 'system', encrypt_method = 'ssh-rsa', public_key = '')
          response = Excon::Response.new
          response.status = 200
          data = {
            'action'       => 'CreateKeyPairResponse',
            'keypair_id'   => Fog::QingCloud::Mock.key_id,
            'ret_code'     => 0
          }
          data['private_key'] = mode == 'user' ? '' : Fog::QingCloud::Mock.key_material

          self.data[:key_pairs][data['keypair_id']] = {
              'description' => 'test',
              'encrypt_method' => encrypt_method,
              'keypair_name'  => key_name,
              'instance_ids' => [],
              'create_time' => Time.now,
              'keypair_id'  => data['keypair_id'],
              'pub_key'  => Fog::QingCloud::Mock.public_key
          }
          response.body = data
          response
        end

      end
    end
  end
end
