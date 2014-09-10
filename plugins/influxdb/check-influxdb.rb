#!/usr/bin/env ruby
#
# Check if /ping endopoint is responding
# ===
#
# Copyright (C) 2014, Mitsutoshi Aoe <maoe@foldr.in>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'influxdb'

class CheckInfluxDB < Sensu::Plugin::Check::CLI

  option :host,
    :short => '-h HOST',
    :long => '--host HOST',
    :default => 'localhost'

  option :port,
    :short => '-p PORT',
    :long => '--port PORT',
    :proc => Proc.new {|s| s.to_i },
    :default => 8086

  def run
    influxdb = InfluxDB::Client.new(config)
    begin
      status = influxdb.ping
      ok status.to_s
    rescue => e
      critical e.to_s
    end
  end

end
