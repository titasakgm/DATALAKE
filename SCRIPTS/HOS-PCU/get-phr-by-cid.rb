#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'
require 'cgi'

def calc_hash(cid,dob)
  hash = %x! echo -n #{cid}#{dob} | multihash !.chomp[2..-1]
end

c = CGI.new
cid = c['cid']

if cid == ''
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input CID as http://scripts/api/get-phr-by-cid.rb?cid=<CID></h1>
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
phr = db['phr']

person_doc = people.find({'_id' => cid }).first

if !person_doc.nil?
  cid = person_doc[:_id]
  dob = person_doc[:dob]
  hash = calc_hash(cid,dob)
  phr_doc = phr.find({'_id' => hash }).first

  json = {
    'phr_doc' => phr_doc
  }
else
  json = {
    'phr_doc' => 'NA'
  }
end

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
