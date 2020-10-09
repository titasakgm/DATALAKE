#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
cid = c['cid']
old_dob = c['old_dob']
new_dob = c['new_dob']

if cid == '' or old_dob == '' or new_dob == ''
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input CID,OLD_DOB,NEW_DOB as http://scripts/api/get-phr-alt-hashes.rb?cid=<CID>&old_dob=<OLD_DOB>&new_dob=<NEW_DOB></h1>
</body>
</html>
EOF
exit
end

hash0 = %x! echo -n #{cid}#{old_dob} | multihash !.chomp[2..-1]
hash1 = %x! echo -n #{cid}#{new_dob} | multihash !.chomp[2..-1]
today = Time.now.strftime("%Y%m%d")

Mongo::Logger.logger.level = Logger::FATAL

client = Mongo::Client.new([ 'mongodb:27017' ],
  :database => 'trang',
  :user => 'backup',
  :password => 'datalake',
  :auth_source => 'admin'
)

db = client.database
alt_hashes = db['alt_hashes']

doc = alt_hashes.find({'_id' => hash0 }).first
doc['hashes'].push(hash1)
doc['updated_at'] = today

json = {
  'alt_hash_doc' => doc
}

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
