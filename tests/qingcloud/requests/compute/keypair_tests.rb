Shindo.tests("Fog::Compute[:qingcloud] | keypair requests", ['qingcloud']) do

  keypair_format = {
    'pub_key' => String,
    'keypair_id' => String,
    'keypair_name' => Fog::Nullable::String
  }

  create_keypair_format = {
    'keypair_id' => String,
  }

  describe_keypair_format = {
    'keypair_set' => [keypair_format],
    'total_count' => Integer
  }

  attach_keypair_format = {
    'job_id' => String
  }

  detach_keypair_forormat = attach_keypair_format
  key_name = Fog::Mock.random_letters(10)
  service = Fog::Compute[:qingcloud]

  tests('success') do
    tests("#create_key_pair(#{key_name})") do
      data = service.create_key_pair(key_name).body
      @key_id = data['keypair_id']
      data_matches_schema(create_keypair_format, {:allow_extra_keys => true}) {data}
    end

    tests("#describe_key_pairs") do
      data = service.describe_key_pairs.body
      data_matches_schema(describe_keypair_format, {:allow_extra_keys => true}) {data}
    end

    tests("#delete_key_pairs(#{@key_id})") do
      data = service.delete_key_pairs(@key_id).body
      returns(0) {data['ret_code']}
    end
  end

  tests('failure') do
    tests("#delete_key_pairs('unknownkey')").raises(Fog::QingCloud::Errors::NotFound) do
      service.delete_key_pairs('unknownkey')
    end
  end

end
