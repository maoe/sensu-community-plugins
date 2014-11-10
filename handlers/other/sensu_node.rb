#!/usr/bin/env ruby

require 'timeout'
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'

class SensuNode < Sensu::Handler

  def filter; end

  def handle
    if sensu_client_exists?
      delete_sensu_client!
    end
    puts "[Sensu Node]"
  end

  # Check if the sensu client exists on another sensu server.
  def sensu_client_exists?
    other_sensu_servers.any? do |server|
      response = api_request_for(:GET, '/clients/' + @event['client']['name'])
      response.code == '200'
    end
  end

  def other_sensu_servers
    @other_sensu_servers ||= begin
      settings['sensu']['servers'].reject do |server|
        options['api']['host'] == server['host'] &&
          options['api']['port'] == server['port']
      end
    end
  end

  def api_request_for(server, method, path, payload)
    if server['user'] && server['password']
      req.basic_auth(server['user'], server['password'])
    end
    unless payload.nil?
      req.body = payload
    end
    http.request(req)
  end

  def delete_sensu_client!
    response = api_request(:DELETE, '/clients/' + @event['client']['name'])
    case response.code
    when '202'
      puts "[Sensu Node] 202: Successfully deleted Sensu client: #{node}"
    when '404'
      puts "[Sensu Node] 404: Unable to delete #{node}, doesn't exist!"
    when '500'
      puts "[Sensu Node] 500: Miscellaneous error when deleting #{node}"
    else
      puts "[Sensu Node] #{res}: Completely unsure of what happened!"
    end
  end

end
