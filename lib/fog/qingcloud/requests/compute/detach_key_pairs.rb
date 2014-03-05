module Fog
  module Compute
    class QingCloud
      class Real

        # Delete a key pair that you own
        # {API Reference}[https://docs.qingcloud.com/api/keypair/detach_key_pairs.html]
        def detach_key_pairs(key_id, instance_id)
          args = {
            'action'    => 'DetachKeyPairs',
          }
          args.merge! Fog::QingCloud.indexed_param('keypairs', [*key_id])
          args.merge! Fog::QingCloud.indexed_param('instances', [*key_id])
          request(args)
        end

      end

      class Mock

        def detach_key_pairs(key_id, instance_id)
          response = Excon::Response.new
          key_id = [*key_id]
          instance_id = [*instance_id]

          raise Fog::QingCloud::Errors::CommonClientError, "key_id count and instance_id count must be equal" if key_id.length != instance_id.length
          key_id.each_with_index do |k, i|
            self.data[:key_pairs][k]['instance_ids'].delete instance_id[i]
            self.data[:instances][instance_id[i]]['keypair_ids'].delete k
          end

          response.status = 200
          response.body = {
            'action' => 'DetachKeyPairsResponse',
            'job_id' => Fog::QingCloud::Mock.job_id,
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
