#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
hash = c['hash']
cid = c['cid']
dob = c['dob']

if hash == ''
  if cid.nil? && dob.nil?
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input HASH as http://scripts/api/get-phr-alt-hashes.rb?hash=<HASH></h1>
OR
<h1>Please input CID,DOB as http://scripts/api/get-phr-alt-hashes.rb?cid=<CID>&dob=<DOB></h1>
</body>
</html>
EOF
exit
  else
    hash = %x! echo -n #{cid}#{dob} | multihash !.chomp[2..45]
  end
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
alt_hashes = db['alt_hashes']

phr_doc = phr.find({'_id' => hash }).first
alt_hash_doc = alt_hashes.find({'_id' => hash }).first

json = {
  'phr_doc' => phr_doc,
  'alt_hash_doc' => alt_hash_doc
}

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
