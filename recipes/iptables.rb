#
# Cookbook Name:: spacewalk-server
# Recipe:: iptables
#
# Copyright (C) 2013 Opscode, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'iptables'

iptables_rule 'spacewalk'
