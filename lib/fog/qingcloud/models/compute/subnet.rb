require 'fog/qingcloud/model'

module Fog::Compute
  class QingCloud
    class Subnet < Fog::QingCloud::Model
      
      identity :id,           :aliases => 'vxnet_id'

      attribute :router_id
      attribute :gateway_ip,  :aliases => 'manager_ip'
      attribute :cidr_block,  :aliases => 'ip_network'
      attribute :ip_start,    :aliases => 'dyn_ip_start'
      attribute :ip_end,      :aliases => 'dyn_ip_end'
      attribute :name,        :aliases => 'vxnet_name'
      attribute :features
      attribute :created_at,   :aliases => 'create_time'

      def servers
        requires :id
        vxnet_instances = service.describe_vxnet_instances(id).body['instance_set']
        instance_ids = vxnet_instances.map { |i| i['instance_id'] }
        service.servers.all('instance-id' => instance_ids)
      end

    end
  end
end
