class QingCloud < Fog::Bin
  class << self

    def class_for(key)
      case key
      when :compute
        Fog::Compute::QingCloud
      else
        # @todo Replace most instances of ArgumentError with NotImplementedError
        # @todo For a list of widely supported Exceptions, see:
        # => http://www.zenspider.com/Languages/Ruby/QuickRef.html#35
        raise ArgumentError, "Unsupported #{self} service: #{key}"
      end
    end

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::Logger.warning("QingCloud[:compute] is not recommended, use Compute[:qingcloud] for portability")
          Fog::Compute.new(:provider => 'QingCloud')
        else
          raise ArgumentError, "Unrecognized service: #{key.inspect}"
        end
      end
      @@connections[service]
    end

    def services
      Fog::QingCloud.services
    end

  end
end
