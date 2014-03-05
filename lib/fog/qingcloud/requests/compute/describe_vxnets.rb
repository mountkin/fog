module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified vxnets
        # { API Reference}[https://docs.qingcloud.com/api/vxnet/describe_vxnets.html]
        def describe_vxnets(filters = {})
          params = Fog::QingCloud.indexed_param('vxnets', [*filters['vxnet-id']])
          params['search_word'] = filters['search_word']
          request({
            'action'    => 'DescribeVxnets',
            'verbose'   => filters['verbose'] || 1
          }.merge!(params))
        end
      end

      class Mock
        def describe_vxnets(filters = {})
          vxnets = self.data[:vxnets]

          # Transition from pending to available
          vxnets.each do |vxnet|
            case vxnet['state']
              when 'pending'
                vxnet['state'] = 'available'
            end
          end

          if filters['vxnet-id']
            vxnets = vxnets.reject {|vxnet| vxnet['vxnet_id'] != filters['vxnet-id']}
          end

          Excon::Response.new(
            :status => 200,
            :body   => {
              'vxnet_set' => vxnets
            }
          )
        end
      end
    end
  end
end
