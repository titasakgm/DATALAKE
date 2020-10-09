#!/usr/bin/ruby

require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
catm = c['catm']
limit = c['limit'].to_s.to_i

if catm == ''
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input CCAATTMM as http://scripts/api/get-people-from-catm.rb?catm=<CCAATTMM></h1>
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

if limit > 0
  docs = people.find({'ccaattmm': /^#{catm}/ }).limit(limit)
else
  docs = people.find({'ccaattmm': /^#{catm}/ })
end

print <<EOF
Content-type: application/json

#{docs.to_json}
EOF

