module Fog
  module Compute
    class QingCloud
      class Real

        def describe_instances(filters = {})
          params = {}
          ['instance-id', 'image-id', 'instance-type', 'status', 'state'].each do |item|
            if filters[item]
              ids = filters.delete(item)
              item = 'instances' if item == 'instance-id'
              item = 'status' if item == 'state'

              [*ids].each_with_index do |id, index|
                params.merge!("#{item.gsub(/-/, '_')}.#{index + 1}" => id)
              end
            end
          end
          params['search_word'] = filters['search-word'] || filters['search_word']

          request({
            'action'  => 'DescribeInstances',
            'verbose' => 1
          }.merge!(params))
        end

      end

      class Mock

        def describe_instances(filters = {})

          response = Excon::Response.new

          instance_set = self.data[:instances].values
          aliases = {
            'instance-id'   => 'instance_id',
            'image-id'      => 'image_id',
            'instance-type' => 'instance_type',
            'state'         => 'status'
          }
          
          # Mock instance status change
          instance_set.map! do |instance|
            target_status = ''
            timestamp = instance['transition_status'] == 'creating' ? instance['create_time'] : self.data[:modified_at][instance['instance_id']]
            timestamp ||= 0
            case instance['transition_status']
            when 'creating', 'starting', 'restarting', 'resuming', 'recovering', 'reseting'
              target_status = 'running'
            when 'stopping'
              target_status = 'stopped'
            when 'suspending'
              target_status = 'suspended'
            when 'terminating'
              target_status = 'terminated'
              target_status = 'ceased' if Time.now - timestamp > Fog::Mock.delay * 2
            end
            if Time.now - timestamp > Fog::Mock.delay
              instance['status'] = target_status
              instance['transition_status'] = ''
            end
            instance
          end

          for filter_key, filter_value in filters
            if filter_key == 'search_word'
              instance_set = instance_set.select {|instance| instance['instance_name'] =~ Regexp.new(filter_value) or instance['instance_id'] =~ Regexp.new(filter_value)}
            else
              aliased_key = aliases[filter_key] || filter_key
              instance_set = instance_set.select {|instance| [*filter_value].include?(instance[aliased_key])}
            end
          end

          response.status = 200
          response.body = {
            'action'       => 'DescribeInstancesResponse',
            'instance_set' => instance_set, 
            'ret_code'     => 0,
            'total_count'  => instance_set.length
          }
          response
        end

      end
    end
  end
end
