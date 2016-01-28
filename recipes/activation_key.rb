spacewalk_activation_key 'Default activation key' do
  spacewalk_server 'dl-spacewalk-server'
  spacewalk_login node['spacewalk']['sync']['user']
  spacewalk_password node['spacewalk']['sync']['password']
  generated_key proc {|key| node.default['spacewalk']['reg']['key'] = key}
end
