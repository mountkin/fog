module Fog
  module Compute
    class QingCloud
      class Real

        # Delete a key pair that you own
        # {API Reference}[https://docs.qingcloud.com/api/keypair/delete_key_pairs.html]
        def delete_key_pairs(key_id)
          args = {
            'action'    => 'DeleteKeyPairs',
          }
          args.merge! Fog::QingCloud.indexed_param('keypairs', [*key_id])
          request(args)
        end

      end

      class Mock

        def delete_key_pairs(key_id)
          response = Excon::Response.new
          key_id = [*key_id]
          unless (unknown_keys = key_id - self.data[:key_pairs].keys).empty?
            raise Fog::QingCloud::Errors::NotFound, "ResourceNotFound, resource #{unknown_keys.join(', ')} not found"
          end
          self.data[:key_pairs].delete_if {|k, v| key_id.include? k}
          response.status = 200
          response.body = {
            'action' => 'DeleteKeyPairsResponse',
            'keypairs' => [*key_id],
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
