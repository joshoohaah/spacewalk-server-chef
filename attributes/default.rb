
default['spacewalk']['server']['db']['type'] = 'postgres'
default['spacewalk']['server']['errata'] = true
default['spacewalk']['hostname'] = node['hostname']

# Answer file configuration
default['spacewalk']['server']['admin_email'] = 'root@localhost'
default['spacewalk']['server']['ssl']['org'] = 'Spacewalk Org'
default['spacewalk']['server']['ssl']['org_unit'] = 'spacewalk'
default['spacewalk']['server']['ssl']['city'] = 'My City'
default['spacewalk']['server']['ssl']['state'] = 'My State'
default['spacewalk']['server']['ssl']['country'] = 'US'
default['spacewalk']['server']['ssl']['password'] = 'spacewalk'
default['spacewalk']['server']['ssl']['email'] = 'root@localhost'
default['spacewalk']['server']['ssl']['config_vhost'] = 'Y'
default['spacewalk']['server']['enable_tftp'] = 'Y'

arch = node['kernel']['machine'] == 'x86_64' ? 'x86_64' : 'i386'

case node['platform_family']
when 'rhel'
  platform_major = node['platform_version'][0]
  default['spacewalk']['server']['repo_url'] = "http://spacewalk.redhat.com/yum/2.2/RHEL/#{platform_major}/#{arch}/spacewalk-repo-2.2-1.el#{platform_major}.noarch.rpm"
when 'fedora'
  default['spacewalk']['server']['repo_url'] = "http://spacewalk.redhat.com/yum/2.2/Fedora/#{node['platform_version']}/#{arch}/spacewalk-repo-2.2-1.fc#{node['platform_version']}.noarch.rpm"
end

case node['spacewalk']['server']['db']['type']
when 'postgres'
  default['spacewalk']['server']['db']['backend'] = 'postgresql'
  default['spacewalk']['server']['db']['name'] = 'spaceschema'
  default['spacewalk']['server']['db']['user'] = 'spaceuser'
  default['spacewalk']['server']['db']['password'] = 'spacepw'
  default['spacewalk']['server']['db']['host'] = 'localhost'
  default['spacewalk']['server']['db']['port'] = 5432
when 'oracle'
  default['spacewalk']['server']['db']['backend'] = 'oracle'
  default['spacewalk']['server']['db']['name'] = 'xe'
  default['spacewalk']['server']['db']['user'] = 'spacewalk'
  default['spacewalk']['server']['db']['password'] = 'spacewalk'
  default['spacewalk']['server']['db']['host'] = 'localhost'
  default['spacewalk']['server']['db']['port'] = 1521
end

# ::ubuntu configuration
default['spacewalk']['sync']['user'] = 'admin'
default['spacewalk']['sync']['password'] = 'admin'
default['spacewalk']['sync']['channels'] = { 'precise' => 'http://de.archive.ubuntu.com/ubuntu/dists/precise/main/binary-amd64/',
                                             'precise-updates' => 'http://de.archive.ubuntu.com/ubuntu/dists/precise-updates/main/binary-amd64/',
                                             'precise-security' => 'http://de.archive.ubuntu.com/ubuntu/dists/precise-security/main/binary-amd64/'
                                           }
default['spacewalk']['errata']['exclude-channels'] = 'precise'

# config for sudo needed for cookbook/cpanminus to work properly
node.default['authorization']['sudo']['sudoers_defaults'] = ['!visiblepw', 'env_reset', 'env_keep = "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS"', 'env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"', 'env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"', 'env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"', 'env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"', 'env_keep += "HOME"', 'always_set_home', 'secure_path = /sbin:/bin:/usr/sbin:/usr/bin']
