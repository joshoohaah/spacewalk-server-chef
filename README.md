# Spacewalk Server Cookbook #
<B>WORK IN PROGRESS</B>

This cookbook installs and configures a node as a [Spacewalk](http://spacewalk.redhat.com/)
server.
It also sets up Errata support if you like.

Will also install Spacecmd which is a tool that can be used to create Channels using the command line.
For this it will expect a user to be created called admin with password admin1234 on the channel.
Working on automatic creation of that user now.


### Requirements ###
* RHEL / CentOS  > 7

Updated repos means that the installation is a lot smoother now and requires less customization.

### Recipes ###

Include `spacewalk-server::default` for basic Spacewalk installation.

Include `spacewalk-server::ubuntu` for setting up repo-sync and errata import for Ubuntu channels.

Include `spacewalk-server::rhel` for setting up repo-sync and errata import for CentOS/RHEL channels. ( write this recipe and PR please )

Include `spacewalk-server::iptables` to configure iptables for Spacewalk.

### Attributes ###

```
default['spacewalk']['server']['db']['type'] = 'postgres'
default['spacewalk']['server']['errata'] = true # configure errata import scripts+crons
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

# ::ubuntu configuration
# login for Spacewalk
default['spacewalk']['sync']['user'] = 'admin'
default['spacewalk']['sync']['password'] = 'admin'
# the channels to be synced. need to manually create them in Spacewalk for the crons to work
default['spacewalk']['sync']['channels'] = {'precise' => 'http://de.archive.ubuntu.com/ubuntu/dists/precise/main/binary-amd64/',
                                            'precise-updates' => 'http://de.archive.ubuntu.com/ubuntu/dists/precise-updates/main/binary-amd64/',
                                            'precise-security' => 'http://de.archive.ubuntu.com/ubuntu/dists/precise-security/main/binary-amd64/'
                                           }
# when should repo sync be run. should be AFTER errata import
default['spacewalk']['sync']['cron']['h'] = '7'
default['spacewalk']['sync']['cron']['m'] = '0'
# channels to be excluded from errata, like base which doesnt have updates
default['spacewalk']['errata']['exclude-channels'] = "'precise'" # multiple = "'precise','trusty'"
# when should errata be imported. should be AFTER 4:30 GMT+1 because mailinglist gzip gets updaten then
default['spacewalk']['errata']['cron']['h'] = '6'
default['spacewalk']['errata']['cron']['m'] = '0'
```


### Author ###

Phil Schuler http://devops-blog.net

Based on https://github.com/yacn/spacewalk-server-chef by "Yet Another Clever Name" (<admin@yacn.pw>)
