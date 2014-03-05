module Fog
  module Compute
    class QingCloud
      class Real
        def run_instances(image_id, count, options = {})
          vxnets = options.delete('vxnets') || []
          options.merge! Fog::QingCloud.indexed_param('vxnets', vxnets)
          request({
            'action'    => 'RunInstances',
            'image_id'   => image_id,
            'count'  => count,
          }.merge!(options))
        end
      end

      class Mock

        def run_instances(image_id, count, options = {})
          response = Excon::Response.new
          response.status = 200

          sg = options['security_group'] || 'default'
          instances_set = []

          if options['login_keypair'] && describe_key_pairs('keypair-id' => options['login_keypair']).body['keypair_set'].empty?
            raise Fog::QingCloud::Errors::NotFound, "The key pair '#{options['login_keypair']}' does not exist"
          end
          
          options['vxnets'] ||= []
          vxnets = options['vxnets'].map do |vxnet_id|
            vxnet = describe_vxnets('vxnet-id' => vxnet_id).body['vxnet_set'].first
            
            {
              'vxnet_name' => vxnet['vxnet_name'],
              'vxnet_type' => vxnet['vxnet_type'],
              'vxnet_id'   => vxnet_id,
              'nic_id'     => Fog::QingCloud::Mock.mac,
              'private_ip' => Fog::QingCloud::Mock.private_ip_address
            }
          end
          count.times do
            instance = {
              'vcpus_current' => 1,
              'instance_id' => Fog::QingCloud::Mock.instance_id,
              'volume_ids' => [],
              'vxnets' => vxnets,
              'memory_current' => 1024,
              'sub_code' => 0,
              'transition_status' => 'creating',
              'instance_name' => options['instance_name'],
              'instance_type' => options['instance_type'],
              'create_time' => Time.now,
              'status' => 'pending',
              'description' => nil,
              'security_group' => {'is_default' => 0, 'security_group_id' => options['security_group']},
              'status_time' => Time.now,
              'image' => {
                'processor_type' => '64bit',
                'platform' => 'linux',
                'image_size' => 20,
                'image_name' => 'CentOS 6.4 64bit',
                'image_id' => image_id,
                'os_family' => 'centos',
                'provider' => 'system'},
              'keypair_ids' => [options['login_keypair']]
            }
            
            instances_set << instance
            self.data[:instances][instance['instance_id']] = instance
          end
          response.body = {
            'action'     => 'RunInstancesResponse',
            'instances'  => instances_set.map { |x| x['instance_id'] },
            'job_id'     => Fog::QingCloud::Mock.job_id,
            'ret_code'   => 0
          }
          response
        end

      end
    end
  end
end
