#
# Cookbook Name:: spacewalk-server
# Recipe:: default
#
# Copyright (C) 2013 Yet Another Clever Name
#
# All rights reserved - Do Not Redistribute
#

# Add required YUM repos
include_recipe 'yum-epel' if platform_family?('rhel')
include_recipe 'yum-fedora' if platform_family?('fedora')

python_runtime '2'

python_package 'six' do
  version '1.10.0'
end

yum_repository 'jpackage-generic' do
  url 'http://mirrors.dotsrc.org/pub/jpackage/5.0/generic/free/'
  mirrorlist 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0'
  description 'JPackage Generic'
  gpgkey 'http://www.jpackage.org/jpackage.asc'
  enabled true
  action :add
end

remote_file "#{Chef::Config[:file_cache_path]}/spacewalk-repo.rpm" do
  source node['spacewalk']['server']['repo_url']
  action :create
end

package 'spacewalk-repo' do
  source "#{Chef::Config[:file_cache_path]}/spacewalk-repo.rpm"
  action :install
end

%w(spacewalk-setup-postgresql spacewalk-postgresql).each do |p|
  package p do
    action :install
  end
end

template "#{Chef::Config[:file_cache_path]}/spacewalk-answers.conf" do
  source 'spacewalk-answers.conf.erb'
  mode 0755
  action :create
end

execute 'spacewalk-setup' do
  command "spacewalk-setup --non-interactive --skip-db-diskspace-check --disconnected --answer-file=#{Chef::Config[:file_cache_path]}/spacewalk-answers.conf"
  action :run
  creates '/var/log/rhn/rhn_installation.log'
  only_if { node['spacewalk_installed'].nil? }
end

ohai_hint 'spacewalk_installed' do
  content Hash[:installed, true]
end

link '/etc/init.d/spacewalk-service' do
  to '/usr/sbin/spacewalk-service'
  action :create
end

# RedHat init script doesn't support chkconfig. Imagine that...
service 'spacewalk-service' do
  supports status: true, reload: true, restart: true
  action :start
end

#Installing the spacecmd tool
package 'spacecmd' do
  action :install
end

