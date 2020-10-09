#!/usr/bin/ruby

require 'rubygems'
require 'mongoid'
require 'json'
require 'cgi'

c = CGI.new
cid = c['cid']
old_dob = c['old_dob']
new_dob = c['new_dob']
old_catm = c['old_catm']
new_catm = c['new_catm']

if cid=='' or old_dob=='' or new_dob=='' or old_catm=='' or new_catm==''
print <<EOF
<html>
<body>
<h1>Please input CID,OLD_DOB,NEW_DOB,OLD_CATM,NEW_CATM 
as http://scripts/api/get-phr-alt-hashes.rb?cid=<CID>&old_dob=<OLD_DOB>
&new_dob=<NEW_DOB>&old_catm=<OLD_CATM>&new_catm=<NEW_CATM></h1>
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
phr = db['phr']
alt_hashes = db['alt_hashes']

p_doc = phr.find({'_id' => hash0 }).first
p_doc['ccaattmm'] = new_catm
p_doc['updated_at'] = today

a_doc = alt_hashes.find({'_id' => hash0 }).first
a_doc['ccaattmm'] = new_catm
a_doc['hashes'].push(hash1)
a_doc['updated_at'] = today

json = {
  'phr_doc' => p_doc,
  'alt_hash_doc' => a_doc
}

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
