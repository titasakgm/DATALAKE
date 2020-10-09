#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'net/ping'

def up?(host)
    check = Net::Ping::External.new(host)
    check.ping?
end

Mongo::Logger.logger.level = Logger::FATAL

online = up?('mongodb')
if !online
  host = '127.0.0.1'
else
  host = 'mongodb'
end

puts "HOST: #{host}"

client = Mongo::Client.new([ "#{host}:27017" ],
  :database => 'trang',
  :user => 'backup',
  :password => 'datalake',
  :auth_source => 'admin'
)

db = client.database
people = db['people']

puts "people.find({ccaattmm:/^92/}).count"
puts people.find({ccaattmm:/^92/}).count
