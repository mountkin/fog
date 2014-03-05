module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified security groups
        # {API Reference}[https://docs.qingcloud.com/api/sg/describe_security_groups.html]
        def describe_security_groups(filters = {})
          id = filters['group-id']
          params = Fog::QingCloud.indexed_param('security_groups', filters['group-id'])
          params['search_word'] = filters['search-word'] || filters['search_word'] || filters['group-name']
          request({
            'action'  => 'DescribeSecurityGroups',
            'verbose' => filters['verbose'] || 1
          }.merge!(params))
        end

      end

      class Mock

        def describe_security_groups(filters = {})
          response = Excon::Response.new
          id = [*filters['group-id']]
          search_word = filters['search-word'] || filters['search_word'] || filters['group-name']

          security_group_info = self.data[:security_groups]

          security_group_info = security_group_info.select {|k, v| id.include? k}
          if search_word
            security_group_info = security_group_info.select {|k, v| k =~ Regexp.new(search_word) or v['security_group_name'] =~ Regexp.new(search_word)}
          end

          response.status = 200
          response.body = {
            'action'             => 'DescribeSecurityGroupsResponse',
            'security_group_set' => security_group_info.values,
            'total_count'        => security_group_info.length,
            'ret_code'           => 0
          }
          response
        end

      end
    end
  end
end
