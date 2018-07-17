#!/usr/bin/env ruby
# encoding: UTF-8

require 'open3'
require 'json'

$VERBOSE=nil

begin
  f = File.dirname(__FILE__)
  if f.include?("environments/prod")
    env = 'prod'
  elsif f.include?("environments/stage")
    env = 'stage'
  end

  app_ip, stderr_str, status = Open3.capture3("cd ~/kumite73_infra/terraform/#{env}; terraform output app_external_ip;")
  db_ip,  stderr_str, status = Open3.capture3("cd ~/kumite73_infra/terraform/#{env}; terraform output db_external_ip;")
  j = {app: {hosts: [app_ip.strip]}, 
        db:  {hosts: [db_ip.strip]},
        '_meta' => {'hostvars': {}}
      }
  puts JSON.pretty_generate(j)
rescue
  p 'Error'
end
