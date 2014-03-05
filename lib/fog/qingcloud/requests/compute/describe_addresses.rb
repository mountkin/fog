module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/eip/describe_eips.html]
        def describe_addresses(filters = {})
          params = {}
          params['search_word'] = filters['public-ip'] if filters['public-ip']
          params.merge!(Fog::QingCloud.indexed_param('eips', filters['eip-id']))
          params.merge!(Fog::QingCloud.indexed_param('status', filters['status']))

          request({
            'action'    => 'DescribeEips',
          }.merge!(params))
        end

      end

      class Mock

        def describe_addresses(filters = {})
          response = Excon::Response.new

          addresses_set = self.data[:addresses].values

          aliases = {'public-ip' => 'public_ip', 'instance-id' => 'instance_id'}
          for filter_key, filter_value in filters
            aliased_key = aliases[filter_key]
            addresses_set = addresses_set.reject{|address| ![*filter_value].include?(address[aliased_key])}
          end

          response.status = 200
          response.body = {
            'eip_set'  => addresses_set
          }
          response
        end

      end
    end
  end
end
