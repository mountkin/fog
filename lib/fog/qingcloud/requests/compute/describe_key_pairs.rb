module Fog
  module Compute
    class QingCloud
      class Real


        # Describe all or specified key pairs
        # {API Reference}[https://docs.qingcloud.com/api/keypair/describe_key_pairs.html]
        def describe_key_pairs(filters = {})
          unless filters.is_a?(Hash)
            Fog::Logger.deprecation("describe_key_pairs with #{filters.class} param is deprecated, use describe_key_pairs('keypair-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'keypair-id' => [*filters]}
          end

          args = {
            'action'    => 'DescribeKeyPairs',
            'verbose'   => filters['verbose'] || 1
          }
          args['instance_id'] = filters['instance-id'] || filters['instance_id']
          args.merge!(Fog::QingCloud.indexed_param('keypairs', [*filters['keypair-id']]))
          args['encrypt_method'] = filters['encrypt_method'] || filters['encrypt-method']
          args['search_word'] = filters['search_word'] || filters['search-word'] || filters['keypair-name']

          request(args)
        end

      end

      class Mock

        def describe_key_pairs(filters = {})
          unless filters.is_a?(Hash)
            Fog::Logger.deprecation("describe_key_pairs with #{filters.class} param is deprecated, use describe_key_pairs('keypair-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'keypair-id' => [*filters]}
          end

          response = Excon::Response.new

          key_set = self.data[:key_pairs]
          
          args = {}
          args['instance_id'] = filters['instance-id'] || filters['instance_id']
          args['encrypt_method'] = filters['encrypt_method'] || filters['encrypt-method']
          args['search_word'] = filters['search_word'] || filters['search-word']

          if args['instance_id']
            key_set = key_set.select {|id, kp| kp['instance_ids'].include? args['instance_id']}
          end
          
          if filters['keypair-id']
            key_set = key_set.select {|id, kp| [*filters['keypair-id']].include? id}
          end

          if args['encrypt_method']
            key_set = key_set.select {|id, kp| kp['encrypt_method'] == args['encrypt_method']}
          end

          if args['search_word']
            key_set = key_set.select {|id, kp| kp['keypair_name'] =~ Regexp.new(args['search_word']) or kp['keypair_id'] =~ args['search_word']}
          end

          response.status = 200
          response.body = {
            'action'      => 'DescribeKeyPairsResponse',
            'keypair_set' => key_set.values,
            'total_count' => key_set.length,
            'ret_code'    => 0
          }
          response
        end

      end
    end
  end
end
