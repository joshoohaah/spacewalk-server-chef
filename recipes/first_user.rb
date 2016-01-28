
spacewalk_firstuser node['spacewalk']['sync']['user'] do
  password node['spacewalk']['sync']['password']
  prefix 'Mr.'
  first_name 'Joe'
  last_name 'Blogs'
  db_user node['spacewalk']['server']['db']['user']
  db_password node['spacewalk']['server']['db']['password']
  db_schema node['spacewalk']['server']['db']['name']
  sensitive true
end
