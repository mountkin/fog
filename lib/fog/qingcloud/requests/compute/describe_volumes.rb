module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified volumes.
        # {API Reference}[https://docs.qingcloud.com/api/volume/describe_volumes.html]
        def describe_volumes(filters = {})
          params = Fog::QingCloud.indexed_param('volumes', filters['volume-id'])
          params.merge!(Fog::QingCloud.indexed_param('status', filters['status']))
          params['search_word'] = filters['name']
          params['instance_id'] = filters['instance-id']
          request({
            'action'    => 'DescribeVolumes',
            'verbose'   => filters['verbose'] || 1
          }.merge!(params))
        end

      end

      class Mock

        def describe_volumes(filters = {})

          filters['search_word'] = filters['name'] || filters['search_word']
          
          volume_set = self.data[:volumes]
          if filters['instance-id']
            volume_set = volume_set.select {|id, v| v['instance_id'] == filters['instance-id']}
          end
          if filters['volume-id']
            volume_set = volume_set.select {|id, v| [*filters['volume-id']].include? id}
          end
          if filters['status']
            volume_set = volume_set.select {|id, v| [*filters['status']].include? v['status']}
          end
          if filters['search_word']
            volume_set = volume_set.select {|id, v| v['name'] =~ Regexp.new(filters['search_word']) or id =~ Regexp.new(filters['search_word'])}
          end

          response = Excon::Response.new
          response.status = 200
          response.body = {
            'action' => 'DescribeVolumesResponse',
            'total_count' => volume_set.length,
            'volume_set' => volume_set.values,
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
