Shindo.tests("Fog::Compute[:qingcloud] | security_group", ['qingcloud']) do
  sg_format = {
    'security_group_id' => String,
    'security_group_name' => Fog::Nullable::String,
    'is_applied' => Integer
  }

  describe_sg_format = {
    'action' => String,
    'total_count' => Integer,
    'security_group_set' => [sg_format]
  }

  sg_name = Fog::Mock.random_letters(10)
  service = Fog::Compute[:qingcloud]

  tests('success') do
    tests("#create_security_group(#{sg_name}") do
      data = service.create_security_group(sg_name).body
      returns(true) {data.has_key? 'security_group_id'}
      @sg_id = data['security_group_id']
    end

    tests("#describe_security_groups('goup-name' => '#{sg_name}')") do
      data = service.describe_security_groups('group-name' => sg_name).body
      data_matches_schema(describe_sg_format, {:allow_extra_keys => true}) {data}
    end

    tests("#modify__attributes('#{@sg_id}', 'test')") do
      data = service.modify_resource_attributes(@sg_id, 'security_group', 'test').body
      returns(0) {data['ret_code']}
    end

    tests("#delete_security_groups('#{@sg_id}')") do
      data = service.delete_security_groups(@sg_id).body
      returns(@sg_id) {data['security_groups'].first}
    end
  end

  tests('failure') do
    tests("#delete_security_groups('unknownsg')").raises(Fog::QingCloud::Errors::NotFound) do
      service.delete_security_groups('unknownsg')
    end
  end
end
