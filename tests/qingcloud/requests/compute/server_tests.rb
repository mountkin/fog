Shindo.tests("Fog::Compute[:qingcloud] | server", ['qingcloud']) do
  service = Fog::Compute[:qingcloud]
  image_id = 'centos65x64'
  instance_type = 'small_a'

  tests('success') do
    tests('#run_instances') do
      @kid = service.create_key_pair.body['keypair_id']
      @sg_id = service.create_security_group.body['security_group_id']
      data = service.run_instances(image_id, 1, 'login_keypair' => @kid, 'security_group' => @sg_id, 'instance_type' => instance_type).body
      @server_id = data['instances'].first
      returns(0) {data['ret_code']}

      server2 = service.run_instances(image_id, 1, 'login_keypair' => @kid, 'security_group' => @sg_id, 'instance_type' => instance_type).body
      @server_id2 = server2['instances'].first
    end

    tests("#describe_instances") do
      data = service.describe_instances('instance-id' => @server_id).body['instance_set']
      returns(1) {data.length}
      returns(@server_id) {data.first['instance_id']}
      
      data = service.describe_instances('search_word' => @server_id).body['instance_set']
      returns(1) {data.length}
      returns(@server_id) {data.first['instance_id']}
    end

    tests('#terminate_instances') do
      [@server_id, @server_id2].each do |id|
        unless Fog.mocking?
          Fog.wait_for(60, 2) do 
            data = service.describe_instances('instance-id' => id).body['instance_set'].first
            data['status'] == 'running'
          end
        end

        # Terminate an instance immediately after creation will fail with an error message 
        # 'PermissionDenied, resource [i-51mtvnkc] lease info not ready yet, please try later'
        begin
          ret_code = service.terminate_instances(id).body['ret_code']
        rescue Fog::QingCloud::Errors::PermissionDenied => e
          if e.message =~ /lease info not ready/
            sleep(2)
            retry
          end
        end
        returns(0) {ret_code}
      end
      returns(0) {service.delete_key_pairs(@kid).body['ret_code']}
      returns(0) {service.delete_security_groups(@sg_id).body['ret_code']}
    end
  end
end
