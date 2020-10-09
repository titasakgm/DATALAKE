#!/usr/bin/ruby

require 'mongoid'

Mongo::Logger.logger.level = Logger::FATAL

trang = Mongo::Client.new([ 'mongodb:27017' ],
  :database => 'trang',
  :user => 'admin',
  :password => 'datalake',
  :auth_source => 'admin'
)

people = trang[:people]
people.delete_many({})

phr = trang[:phr]
phr.delete_many({})

alt_hashes = trang[:alt_hashes]
alt_hashes.delete_many({})
