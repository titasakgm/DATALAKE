#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
cid = c['cid']

if cid.nil?
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input CID as http://scripts/api/get-phr.rb?cid=<CID></h1>
</body>
</html>
EOF
exit
end

Mongo::Logger.logger.level = Logger::FATAL

client = Mongo::Client.new([ 'mongodb:27017' ],
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
