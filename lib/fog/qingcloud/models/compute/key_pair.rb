require 'fog/qingcloud/model'

module Fog
  module Compute
    class QingCloud

      class KeyPair < Fog::QingCloud::Model

        identity  :id,        :aliases => 'keypair_id'

        attribute :name, :aliases => 'keypair_name'
        attribute :description
        attribute :private_key
        attribute :encrypt_method
        attribute :server_ids,   :aliases => 'instance_ids'
        attribute :created_at,   :aliases => 'create_time'
        attribute :public_key,   :aliases => 'pub_key'

        attr_accessor :public_key

        def destroy
          requires :id
          service.delete_key_pairs(id)
          true
        end

        def save
          if persisted?
            modify_attributes(name, description)
          else
            data = if public_key
              service.create_key_pair(name, 'user', 'ignore', public_key).body
            else
              service.create_key_pair(name, 'system', encrypt_method, 'ignore').body
            end
            merge_attributes('keypair_id' => data['keypair_id'], 'private_key' => data['private_key'])
            merge_attributes('public_key' => data['pub_key']) unless public_key
          end
          true
        end

        def write(path="#{ENV['HOME']}/.ssh/fog_#{Fog.credential.to_s}_#{id}.pem")

          if writable?
            split_private_key = private_key.split(/\n/)
            File.open(path, "w") do |f|
              split_private_key.each {|line| f.puts line}
              f.chmod 0400
            end
            "Key file built: #{path}"
          else
            "Invalid private key"
          end
        end

        def writable?
          !!(private_key && ENV.has_key?('HOME'))
        end

        def attach(server_id)
          requires :id
          service.attach_key_pairs(id, server_id)
          true
        end

        def detach(server_id)
          requires :id
          service.detach_key_pairs(id, server_id)
          true
        end

        def servers
          return nil unless server_ids && server_ids.any?
          service.servers.all('instance-id' => server_ids)
        end

      end

    end
  end
end
