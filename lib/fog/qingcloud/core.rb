require 'fog/core'

module Fog
  module QingCloud
    extend Fog::Provider
    service(:compute,         'Compute')

    def self.indexed_param(key, values)
      params = {}
      unless key.include?('%d')
        key << '.%d'
      end
      [*values].each_with_index do |value, index|
        if value.respond_to?('keys')
          k = format(key, index + 1)
          value.each do | vkey, vvalue |
            params["#{k}.#{vkey}"] = vvalue
          end
        else
          params[format(key, index + 1)] = value
        end
      end
      params
    end

    def self.camelcase_string(str)
      str.split('_').map{|x| x.capitalize}.join('')
    end

    def self.underscore_string(str)
      if ('A'..'Z').include? str[0] 
        str.gsub(/([A-Z])/){|c| '_' + c.downcase}.sub(/^_/, '')
      else
        str.gsub(/([A-Z])/){|c| '_' + c.downcase}
      end
    end

    def self.serialize_keys(key, value, options = {})
      case value
      when Hash
        value.each do | k, v |
          options.merge!(serialize_keys("#{key}.#{k}", v))
        end
        return options
      when Array
        value.each_with_index do | it, idx |
          options.merge!(serialize_keys("#{key}.member.#{(idx + 1)}", it))
        end
        return options
      else
        return {key => value}
      end
    end

    def self.indexed_request_param(name, values)
      idx = -1
      Array(values).inject({}) do |params, value|
        params["#{name}.#{idx += 1}"] = value
        params
      end
    end

    def self.escape(string)
      unless @unf_loaded_or_warned
        begin
          require('unf/normalizer')
        rescue LoadError
          Fog::Logger.warning("Unable to load the 'unf' gem. Your QingCloud strings may not be properly encoded.")
        end
        @unf_loaded_or_warned = true
      end
      string = defined?(::UNF::Normalizer) ? ::UNF::Normalizer.normalize(string, :nfc) : string
      string.gsub(/([^a-zA-Z0-9_.\-~]+)/) {
        "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase
      }
    end
    

    def self.signed_params(params, options = {})
      params.merge!({
        'access_key_id'    => options[:qingcloud_access_key_id],
        'signature_method'   => options[:signature_method],
        'signature_version'  => options[:signature_version],
        'time_stamp'         => Time.now.utc.strftime("%FT%TZ"),
        'version'           => options[:version],
        'zone'  => options[:zone] || 'pek1'
      }).reject!{|k, v| v.nil?}

      query_string = ''
      for key in params.keys.sort
        query_string << "#{key}=#{escape(params[key].to_s)}&"
      end

      string_to_sign = "GET\n#{options[:path]}\n" << query_string.chop
      signed_string = Base64.encode64(options[:hmac].sign(string_to_sign))
      params['signature'] = signed_string.gsub(/\n/, '')
      params
    end

    class Mock

      def self.zone(region)
        "pek1"
      end

      def self.image
        {
          'status' => 'available',
          'processor_type' => '64bit',
          'image_id' => image_id,
          'sub_code' => 1,
          'transition_status' => '',
          'recommended_type' => 'small_b',
          'image_name' => '',
          'visibility' => 'private',
          'platform' => 'linux',
          'create_time' => '2013-08-07T18:16:32Z',
          'os_family' => 'centos',
          'provider' => 'self',
          'owner' => 'usr-1234abcd',
          'status_time' => '2013-08-17T08:16:33Z',
          'size' => 20,
          'description' => nil
        }
      end

      def self.image_id
        "img-#{Fog::Mock.random_hex(8)}"
      end

      def self.mac
        Fog::Mock.random_hex(12).scan(/.{2}/).join(':')
      end

      def self.instance_id
        "i-#{Fog::Mock.random_hex(8)}"
      end

      def self.ip_address
        Fog::Mock.random_ip
      end

      def self.address_id
        "eip-#{Fog::Mock.random_hex(8)}"
      end

      def self.job_id
        "j-#{Fog::Mock.random_hex(8)}"
      end

      def self.private_ip_address
        "192.168.1.#{Fog::Mock.random_numbers(2)}"
      end

      def self.key_material
        OpenSSL::PKey::RSA.generate(1024).to_s
      end

      def self.public_key
      <<-EOS
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5w3Cr/6b3lDQpX3XukEu0pM6vbMdfEWhoWTdiLpU4Gl7P+PyKlFqv528eU8/XIBqEIRBw/WCHAtY5mE7eo6ZxHvUWf/i3Mzy/3/xWHqkKjyTdZDP86xGmP0cQcN4xZ4oNgVu3bChFXvCxUj3X0EQHhED090ePQOQYPPw+sAKLngilaPAYGfzX30HXknRYWzCo/ucn8bl/k3lYEyjSb8orD4HeW/lhv0fUVgbbrvYBd3RVuQVNzso/gN7p/7O3BApkWdufq7iWPi84iQgYkeNFH4bWT4wl4NEkd23gymWF3IwvM0/JOjOdlzLnbhko9Q6eiY400d2/tcsNlf5qLGaz starrysky@sky
      EOS
      end

      def self.volume_id
        "vol-#{Fog::Mock.random_hex(8)}"
      end

      def self.security_group_id
        "sg-#{Fog::Mock.random_hex(8)}"
      end

      def self.vxnet_id
        "vxnet-#{Fog::Mock.random_hex(8)}"
      end

      def self.key_id
        "kp-#{Fog::Mock.random_hex(8)}"
      end

      def self.security_group_rule_id
        "sgr-#{Fog::Mock.random_hex(8)}"
      end

    end

    def self.parse_security_group_options(group_name, options)
      options ||= Hash.new
      if group_name.is_a?(Hash)
        options = group_name
      elsif group_name
        if options.key?('GroupName')
          raise Fog::Compute::QingCloud::Error, 'Arguments specified both group_name and GroupName in options'
        end
        options = options.clone
        options['GroupName'] = group_name
      end
      name_specified = options.key?('GroupName') && !options['GroupName'].nil?
      group_id_specified = options.key?('GroupId') && !options['GroupId'].nil?
      unless name_specified || group_id_specified
        raise Fog::Compute::QingCloud::Error, 'Neither GroupName nor GroupId specified'
      end
      if name_specified && group_id_specified
        options.delete('GroupName')
      end
      options
    end

    module Errors
      class TryLater < Fog::Errors::Error
      end

      class NotEnoughResource < Fog::Errors::Error
      end

      class ServiceUnavailable < Fog::Errors::Error
      end

      class InternalServerError < Fog::Errors::Error
      end

      class QuotaExceeded < Fog::Errors::Error
      end

      class PermissionDenied < Fog::Errors::Error
      end

      class AuthFailed < Fog::Errors::Error
      end

      class CommonClientError < Fog::Errors::Error
      end

      class NotFound < Fog::Errors::Error; end
      class NotEnoughMoney < Fog::Errors::Error; end

    end
  end
end
