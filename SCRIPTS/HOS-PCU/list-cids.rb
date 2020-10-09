#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
num = c['num'].to_s.to_i

if num == 0
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input total CIDS as http://scripts/api/list-cids.rb?num=<NUMBER></h1>
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

n = 0
cids = []
people.find.each do |doc|
  n += 1
  cid = doc[:_id]
  cids.push(cid)
  break if n == num
end

json = {
  :cids => cids
}

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
