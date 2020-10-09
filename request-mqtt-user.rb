#!/usr/bin/ruby

require 'rubygems'
require 'mqtt'

anydesk_id = %x! anydesk --get-id !.chomp

# Publish MQTT/PASSWD message: user-id and anydesk ID
MQTT::Client.connect(
  host: '203.157.230.21',
  port: 1883,
  username: 'admin',
  password: 'datalake') do |c|
  c.publish('MQTT/PASSWD', "ID:UUUU, AD_ID: #{anydesk_id}")
end
