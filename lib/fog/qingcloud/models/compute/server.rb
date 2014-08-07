require 'fog/compute/models/server'
require 'ostruct'
require 'base64'

module Fog
  module Compute
    class QingCloud

      class Server < Fog::Compute::Server
        extend Fog::Deprecation
        identity  :id,           :aliases => 'instance_id'

        attribute :name,         :aliases => 'instance_name'
        attribute :description
        attribute :flavor_id,    :aliases => 'instance_type'
        attribute :image_id
        attribute :memory_current
        attribute :status
        attribute :vxnet_ids
        attribute :volume_ids
        attribute :keypair_ids
        attribute :security_group
        attribute :zone
        attribute :last_modified, :alias => 'status_time'
        attribute :transition_status
        attribute :userdata_type
        attribute :userdata_value
      
        # Used to store the NIC information of the described instance.
        attribute :vxnets


        def initialize(attributes={})
          prepare_service_value(attributes)
          self.image_id   ||= 'centos64x64a'
          super
        end

        def addresses
          requires :id
          service.addresses(:server => self)
        end

        def destroy
          requires :id
          service.terminate_instances(id)
          true
        rescue Fog::QingCloud::Errors::PermissionDenied => e
          raise e unless e.message =~ /has already been deleted/i
          true
        end

        remove_method :flavor_id
        def flavor_id
          @flavor && @flavor.id || attributes[:flavor_id]
        end

        def flavor=(new_flavor)
          @flavor = new_flavor
        end

        alias_method :instance_type, :flavor_id
        alias_method :instance_type=, :flavor_id=

        def flavor
          @flavor ||= service.flavors.all.detect {|flavor| flavor.id == flavor_id}
        end

        def key_pair
          requires :keypair_ids
          service.key_pairs.all(keypair_ids).first
        end

        def key_pair=(key_id)
          keypair_ids << key_id
        end

        def ready?
          status == 'running'
        end

        def reboot(wait = false)
          requires :id
          service.reboot_instances(id)
          wait_for { status == 'running' } if wait
          true
        end

        def save
          if persisted?
            modify_attributes(name, description)
          else
            requires :image_id
            requires :flavor_id

            options = {
              'instance_type'     => flavor_id,
              'login_keypair'     => [*keypair_ids].first,
              'login_mode'        => 'keypair',
              'security_group'    => security_group,
              'instance_name'     => name,
              'vxnets'            => vxnet_ids
            }

            if userdata_value 
              if userdata_type == 'plain'
                options['userdata_value'] = Base64.encode64(userdata_value)
              elsif userdata_type == 'tar'
                attachment_id = service.upload_userdata_attachment(
                  'attachment_content' => Base64.encode64(userdata_value),
                  'attachment_name' => 'userdata-tar'
                ).body['attachment_id']
                options['userdata_value'] = attachment_id
              end
              options['need_userdata'] = 1
              options['userdata_type'] = userdata_type
            end

            self.id = service.run_instances(image_id, 1, options).body['instances'].first
            wait_for {ready?}
          end
          true
        end

        def join_vxnet(vxnet)
          vxnet_id = vxnet.respond_to?(:id) ? vxnet : service.vxnets.get(vxnet)
          vxnet_ids ||= []
          if persisted?
            service.join_vxnet(vxnet_id, id)
            @modified = true
          end
          vxnet_ids |= [vxnet_id]
        end

        def leave_vxnet(vxnet)
          vxnet_id = vxnet.respond_to?(:id) ? vxnet.id : vxnet
          vxnet_ids ||= []
          if persisted?
            service.leave_vxnet(vxnet_id, id)
            @modified = true
          end
          vxnet_ids.delete(vxnet_id)
        end

        def resize(target_instance_type = nil, cpu = nil, memory = nil)
          requires :id
          service.resize_instances(id, target_instance_type, cpu, memory)
          reload
          true
        end

        def reset
          requires :id
          service.reset_instances(id)
          true
        end

        def setup(credentials = {})
          requires :ssh_ip_address, :username
          require 'net/ssh'

          commands = [
            %{mkdir .ssh},
            %{passwd -l #{username}},
            %{echo "#{Fog::JSON.encode(Fog::JSON.sanitize(attributes))}" >> ~/attributes.json}
          ]
          if public_key
            commands << %{echo "#{public_key}" >> ~/.ssh/authorized_keys}
          end

          # wait for qingcloud to be ready
          wait_for { sshable?(credentials) }

          Fog::SSH.new(ssh_ip_address, username, credentials).run(commands)
        end

        def start(wait = false)
          requires :id
          service.start_instances(id)
          wait_for { status == 'running' } if wait
          true
        end

        def stop(wait = false, force = false)
          requires :id
          service.stop_instances(id, force)
          wait_for { status == 'stopped' } if wait
          true
        end

        def volumes
          requires :id
          service.volumes(:server => self)
        end

        def security_groups
          requires :id
          service.security_groups(:server => self)
        end

        def image
          requires :id
          service.images.get(image_id)
        end
        
        def nics
          requires :id
          reload if @modified
          vxnets.map {|x| OpenStruct.new(x)}
        end

        def mac_addresses
          requires :id
          nics.map { |x| x.nic_id }
        end

        def private_ips
          requires :id
          nics.map{|x| x.private_ip}
        end

        def wait_for(&block)
          wait_policy = lambda { |retries| retries < 8 ? 9 - retries : 1 }
          super(Fog::QingCloud.wait_timeout, wait_policy, &block)
        end
        
        def modify_attributes(name, description)
          requires :id
          raise Fog::QingCloud::Errors::CommonClientError, "name or description must be specified" unless name || description
          service.modify_resource_attributes(id, 'instance', name, description)
          merge_attributes('instance_name' => name, 'description' => description)
          true
        end

      end

    end
  end
end
