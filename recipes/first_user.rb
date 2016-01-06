
spacewalk_admin 'admin' do
  password 'admin1234'
  first_name 'Joe'
  last_name 'Blogs'
  db_user node['spacewalk']['server']['db']['user']
  db_password node['spacewalk']['server']['db']['password']
  db_schema node['spacewalk']['server']['db']['name']
end

# psqlscript = Chef::Config[:file_cache_path] + '/first_user.psql'
#
#  template psqlscript do
#    source 'first_user.psql.erb'
#    variables ({
#      :first_user_name => 'admin',
#      :first_user_password => '$5$Q2fxUTqBPoynaN9M$pptnmFj10UW3v2mNCfHJX5k4R9fmQd6kY0bX8Xrtb/6',
#      :first_user_prefix => 'Mr.',
#      :first_user_first_name => 'Joe',
#      :first_user_last_name => 'Blogs'
#      })
#  end
#
#  execute 'psql_script' do
#    command "export PGPASSWORD=#{node['spacewalk']['server']['db']['password']}; psql -1 -f " + psqlscript +" #{node['spacewalk']['server']['db']['name']} #{node['spacewalk']['server']['db']['user']}"
#  end
