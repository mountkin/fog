module Fog
  module Compute
    class QingCloud
      class Real

        # Describe all or specified vxnets
        # { API Reference}[https://docs.qingcloud.com/api/vxnet/describe_vxnet_instances.html]
        def describe_vxnet_instances(vxnet_id, filters = {})
          params = {
            'action' => 'DescribeVxnetInstances',
            'status' => filters['status'] || 'running'
          }.merge Fog::QingCloud.indexed_param('instances', filters['instance-id'])

          request(params)
        end
      end

      class Mock
        def describe_vxnet_instances(vxnet_id, filters = {})
          instances = self.data[:instances]
          instances = instances.select {|i| i['vxnets'].map {|v| v['vxnet_id']}.include?(vxnet_id) }

          Excon::Response.new(
            :status => 200,
            :body   => {
              'instance_set' => instances,
              'action'       => 'DescribeVxnetInstancesResponse',
              'ret_code'     => 0,
              'total_count'  => instances.length
            }
          )
        end
      end
    end
  end
end
