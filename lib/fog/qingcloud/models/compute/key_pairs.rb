require 'fog/core/collection'
require 'fog/qingcloud/models/compute/key_pair'

module Fog
  module Compute
    class QingCloud

      class KeyPairs < Fog::Collection

        attribute :filters
        attribute :key_name

        model Fog::Compute::QingCloud::KeyPair

        # Used to create a key pair.  There are 4 optional arguments.  
        # You can generate a new key_pair as follows:
        # QingCloud.key_pairs.create(key_name = '', mode = 'system', encrypt_method = 'ssh-rsa', public_key = '')
        # The key_pair can be retrieved by running QingCloud.key_pairs.get("kp-keyid").  See get method below.
        #

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        # Returns an array of all key pairs that have been created
        #
        # QingCloud.key_pairs.all
        
        def all(filters = filters)
          self.filters = filters
          data = service.describe_key_pairs(filters).body
          load(data['keypair_set'])
        end

        # Used to retrieve a key pair that was created with the QingCloud.key_pairs.create method.
        # The name is required to get the associated key_pair information.
        #
        # You can run the following command to get the details:
        # QingCloud.key_pairs.get("kp-deadbeef")

        def get(key_id)
          if key_id
            self.class.new(:service => service).all('keypair-id' => key_id).first
          end
        end

      end

    end
  end
end
