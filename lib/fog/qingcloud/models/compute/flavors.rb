require 'fog/core/collection'
require 'fog/qingcloud/models/compute/flavor'

module Fog
  module Compute
    class QingCloud

      FLAVORS = [
        {
          :id                      => 'small_b',
          :name                    => 'Small Instance B',
          :cores                   => 1,
          :ram                     => 1024,
        },
        {
          :id                      => 'small_c',
          :name                    => 'Small Instance C',
          :cores                   => 1,
          :ram                     => 2048,
        },
        {
          :id                      => 'medium_a',
          :name                    => 'Medium Instance A',
          :cores                   => 2,
          :ram                     => 2048,
        },
        {
          :id                      => 'medium_b',
          :name                    => 'Medium Instance B',
          :cores                   => 2,
          :ram                     => 4096,
        },
        {
          :id                      => 'medium_c',
          :name                    => 'Medium Instance C',
          :cores                   => 2,
          :ram                     => 8192,
        },
        {
          :id                      => 'large_a',
          :name                    => 'Large Instance A',
          :cores                   => 4,
          :ram                     => 4096,
        },
        {
          :id                      => 'large_b',
          :name                    => 'Large Instance B',
          :cores                   => 4,
          :ram                     => 8192,
        },
        {
          :id                      => 'large_c',
          :name                    => 'Large Instance C',
          :cores                   => 4,
          :ram                     => 16384,
        }
        ]

      class Flavors < Fog::Collection

        model Fog::Compute::QingCloud::Flavor

        # Returns an array of all flavors that have been created
        #
        # QingCloud.flavors.all
        #
        # ==== Returns
        #
        # Returns an array of all available instances and their general information
        def all
          load(Fog::Compute::QingCloud::FLAVORS)
          self
        end

        # Used to retrieve a flavor
        # flavor_id is required to get the associated flavor information.
        # flavors available currently:
        def get(flavor_id)
          self.class.new(:service => service).all.detect {|flavor| flavor.id == flavor_id}
        end

      end

    end
  end
end
