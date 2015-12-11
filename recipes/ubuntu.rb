directory '/opt/spacewalk' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# install scripts/crons for repo sync
cookbook_file '/opt/spacewalk/debianSync.py' do
  source 'debianSync.py'
  owner 'root'
  group 'root'
  mode '0755'
end

# fixes the missing compression lzma in python-debian-0.1.21-10.el6
# see https://bugzilla.redhat.com/show_bug.cgi?id=1021625
cookbook_file '/usr/lib/python2.7/dist-packages/debian/debfile.py' do
  source 'debfile.py'
  owner 'root'
  group 'root'
  mode '0644'
end

node['spacewalk']['sync']['channels'].each do |name, url|
  cron "sw-repo-sync_#{name}" do
    hour node['spacewalk']['sync']['cron']['h']
    minute node['spacewalk']['sync']['cron']['m']
    command "/opt/spacewalk/debianSync.py --username '#{node['spacewalk']['sync']['user']}' --password '#{node['spacewalk']['sync']['password']}' --channel '#{name}' --url '#{url}'"
  end
end

# install scripts/crons for errata import
if node['spacewalk']['server']['errata']
  cookbook_file '/opt/spacewalk/parseUbuntu.py' do
    source 'parseUbuntu.py'
    owner 'root'
    group 'root'
    mode '0755'
  end

  template '/opt/spacewalk/errata-import.py' do
    source 'errata-import.py.erb'
    owner 'root'
    group 'root'
    mode '755'
    variables(user: node['spacewalk']['sync']['user'],
              pass: node['spacewalk']['sync']['password'],
              server: node['spacewalk']['hostname'],
              exclude: node['spacewalk']['errata']['exclude-channels'])
  end

  template '/opt/spacewalk/spacewalk-errata.sh' do
    source 'spacewalk-errata-ubuntu.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  cron 'sw-errata-import' do
    hour node['spacewalk']['errata']['cron']['h']
    minute node['spacewalk']['errata']['cron']['m']
    command '/opt/spacewalk/spacewalk-errata.sh'
  end

  directory '/opt/spacewalk/errata' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end
