#!/usr/bin/ruby

#encoding: utf-8
require 'mongoid'

def delete_max_d_update()
  fn = "/tmp/MONGO-MAX-D-UPDATE"
  if File.exists?(fn)
    File.delete(fn)
  end
end

def save(hc,max)
  fp = open("/tmp/MONGO-MAX-D-UPDATE","a")
  fp.write("#{hc}|#{max}\n")
  fp.close
end

# get 146 hcodes
hcs = []
src = open("HCODES-146").readlines
src.each do |line|
  hc = line.chomp
  hcs.push hc if hc.length == 5
end

# delete old MONGO-MAX-D-UPDATE
delete_max_d_update()

Mongo::Logger.logger.level = Logger::FATAL

client = Mongo::Client.new([ "localhost:27017" ],
  :database => 'trang',
  :user => 'backup',
  :password => 'datalake',
  :auth_source => 'admin'
)

db = client.database
people = db['people']

hcs.each do |hc|
  doc = people.find({hcode:hc}).sort({updated_at:-1}).limit(1)
  max = doc.as_json[0]['updated_at']
  save(hc,max)
end
