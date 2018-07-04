#!/usr/bin/env ruby
# encoding: UTF-8

require 'open3'
require 'json'

$VERBOSE=nil

begin
  app_ip, status = Open3.capture3("cd ../terraform/stage; terraform output app_external_ip;")
  db_ip, status = Open3.capture3("cd ../terraform/stage; terraform output db_external_ip;")
  if ARGV[0] == '--list'
    j = {app: {hosts: [app_ip.strip]}, db: {hosts: [db_ip.strip]},'_meta' => {'hostvars': {}}}
  else
    j = {app: {hosts: {appserver: {ansible_host: app_ip.strip}}}, db: {hosts: {dbserver: {ansible_host: db_ip.strip}}},'_meta' => {'hostvars': {}}}
  end 
  puts JSON.pretty_generate(j)
rescue
  p 'Error'
end
