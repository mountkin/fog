module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified routers
        # {API Reference}[https://docs.qingcloud.com/api/router/describe_routers.html]
        def describe_routers(filters = {})
          unless filters.is_a?(Hash)
            Fog::Logger.warning("describe_routers with #{filters.class} param is deprecated, use describe_routers('router-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'router-id' => [*filters]}
          end
          params = Fog::QingCloud.indexed_param('routers', filters['router-id']) || {}
          params.merge!(Fog::QingCloud.indexed_param('status', filters['status'])) if filters['status']
          params['search_word'] = filters['search_word']
          request({
            'action'    => 'DescribeRouters',
          }.merge!(params))
        end
      end

      class Mock
        def describe_routers(filters = {})
          routers = self.data[:routers]

          # Transition from pending to available
          routers.each do |router|
            case router['state']
              when 'pending'
                router['state'] = 'available'
            end
          end

          if filters['router-id']
            routers = routers.reject {|router| router['routerId'] != filters['router-id']}
          end

          Excon::Response.new(
            :status => 200,
            :body   => {
              'router_set' => routers
            }
          )
        end
      end
    end
  end
end
