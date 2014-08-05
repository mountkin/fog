require 'fog/core/collection'
require 'fog/qingcloud/models/compute/server'

module Fog
  module Compute
    class QingCloud

      class Servers < Fog::Collection

        attribute :filters

        model Fog::Compute::QingCloud::Server

        ACTIVE_STATUS = %w[pending running stopped suspended]

        # Creates a new server
        #
        def initialize(attributes)
          self.filters ||= {}
          filters['status'] = ACTIVE_STATUS unless filters['status']
          super
        end

        def all(filters = self.filters)
          self.filters = filters
          data = service.describe_instances(filters).body['instance_set']
          load(data.map do |x| 
              x['vxnet_ids'] = x['vxnets'].map{|v| v['vxnet_id']}
              x['image_id'] = x['image']['image_id']
              x
            end
          )
        end

        def bootstrap(new_attributes = {})
          server = service.servers.new(new_attributes)

          unless new_attributes[:key_name]
            # first or create fog_#{credential} keypair
            name = Fog.respond_to?(:credential) && Fog.credential || :default
            unless server.key_pair = service.key_pairs.get("fog_#{name}")
              server.key_pair = service.key_pairs.create(
                :name => "fog_#{name}",
                :public_key => server.public_key
              )
            end
          end
        
          security_group = service.security_groups.get(server.groups.first)
          if security_group.nil?
            raise Fog::Compute::QingCloud::Error, "The security group" \
              " #{server.groups.first} doesn't exist."
          end
          
          # make sure port 22 is open in the first security group
          authorized = security_group.ingress_rules.detect do |rule|
            rule.port_range == (22..22)
          end
          unless authorized
            security_group.add_rule(
              'protocol' => 'tcp',
              'priority' => 1,
              'action' => 'accept',
              'direction' => 0,
              'port_range' => 22,
              'name' => 'ssh',
              'auto_apply' => true
            )
          end

          server.save
          server.wait_for { ready? }
          server.setup(:key_data => [server.private_key])
          server
        end

        # Used to retrieve a server
        #
        # server_id is required to get the associated server information.
        #
        # You can run the following command to get the details:
        # QingCloud.servers.get("i-5c973972")

        def get(server_id)
          if server_id
            self.class.new(:service => service).all('instance-id' => server_id).first
          end
        rescue Fog::QingCloud::Errors::NotFound
          nil
        end

      end

    end
  end
end
