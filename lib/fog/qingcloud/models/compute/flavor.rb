require 'fog/qingcloud/model'

module Fog
  module Compute
    class QingCloud

      class Flavor < Fog::QingCloud::Model

        identity :id
        attribute :cores
        attribute :name
        attribute :ram

      end

    end
  end
end
