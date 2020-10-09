#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'

Mongo::Logger.logger.level = Logger::FATAL

client = Mongo::Client.new([ ':27017' ],
  :database => 'trang',
  :user => 'backup',
  :password => 'datalake',
  :auth_source => 'admin'
)

db = client.database
people = db['people']

person = people.find({'_id': cid})

if person.as_json == []
  dob = 'NA'
else
  dob = person.as_json.first['dob']
end

json = {
  'cid' => cid,
  'dob' => dob
}

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
