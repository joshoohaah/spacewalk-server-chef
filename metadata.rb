name             'spacewalk-server'
maintainer       'Phil Schuler'
maintainer_email 'the.cypher@gmail.com'
license          'MIT'
description      'Installs/Configures a Spacewalk Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

%w[fedora redhat centos].each do |os|
  supports os
end

depends 'ohai'
depends 'iptables'
depends 'yum', '> 3.0.0'
depends 'yum-epel'
depends 'yum-fedora'
depends 'perl'
depends 'cpanminus'
