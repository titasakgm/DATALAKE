#!/usr/bin/ruby

require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
vn = c['vn']

if vn == ''
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input VN as http://scripts/api/get-phr-by-vn.rb?vn=<VN></h1>
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
phr = db['phr']

phr_doc = phr.find({'opd.vn' => vn }).first

print <<EOF
Content-type: application/json

#{phr_doc.to_json}
EOF
