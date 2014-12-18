node.default['yum']['epel-testing']['enabled'] = true
node.default['yum']['epel-testing']['managed'] = true
include_recipe 'yum-epel'

directory "/opt/spacewalk" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# install scripts/crons for repo sync
remote_file "/opt/spacewalk/spacewalk-debian-sync.pl" do
  owner "root"
  group "root"
  mode "0755"
  source "https://raw.githubusercontent.com/stevemeier/spacewalk-debian-sync/master/spacewalk-debian-sync.pl"
end

# fixes the missing compression lzma in python-debian-0.1.21-10.el6
# see https://bugzilla.redhat.com/show_bug.cgi?id=1021625
cookbook_file "/usr/lib/python2.6/site-packages/debian/debfile.py" do
  source "debfile.py"
  owner "root"
  group "root"
  mode "0644"
end

package "gcc" do
  action :install
end

include_recipe "cpanminus::default"
cpan_module 'WWW::Mechanize'

node['spacewalk']['sync']['channels'].each do |name, url|
 cron "sw-repo-sync_#{name}" do
   hour "2"
   minute "0"
   command "/opt/spacewalk/spacewalk-debian-sync.pl --username '#{node['spacewalk']['sync']['user']}' --password '#{node['spacewalk']['sync']['password']}' --channel '#{name}' --url '#{url}'"
 end
end

# install scripts/crons for errata import
if node['spacewalk']['server']['errata']
  %w(errata-import.pl parseUbuntu.py).each do |file|
    remote_file "/opt/spacewalk/#{file}" do
      owner "root"
      group "root"
      mode "0755"
      source "https://raw.githubusercontent.com/philicious/spacewalk-scripts/master/#{file}"
    end
  end

  template "/opt/spacewalk/spacewalk-errata.sh" do
    source "spacewalk-errata-ubuntu.sh.erb"
    owner "root"
    group "root"
    mode "0755"
    variables({
      :user => node['spacewalk']['sync']['user'],
      :pass => node['spacewalk']['sync']['password'],
      :server => node['spacewalk']['hostname'],
      :exclude => node['spacewalk']['sync']['channels']['exclude']
    })
  end

  directory "/opt/spacewalk/errata" do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
end