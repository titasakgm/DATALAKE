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

if cid.nil?
print <<EOF
Content-type: text/html

<html>
<body>
<h1>Please input CID as http://scripts/api/get-phr.rb?cid=<CID></h1>
</body>
</html>
EOF
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

doc = people.find({'_id' => "#{cid}" }).first

if !doc.nil?
  id = doc[:_id]
  catm = doc[:ccaattmm]
  catms = doc[:catms]
  pre = doc[:pre]
  fn = doc[:fname]
  ln = doc[:lname]
  dob = doc[:dob]
  dobs = doc[:dobs]
  sex = (doc[:sex] == '1') ? 'Male' : 'Female'
  hc = doc[:hcode]
  hcs = doc[:hcodes]
  pid = doc[:pid]
  type = doc[:typearea]
  types = doc[:types]
  d_update = doc[:updated_at]

  race = doc[:race]
  nation = doc[:nation]
  rel = doc[:religion]
  edu = doc[:education]

  hash = calc_hash(cid,dob)
  phr_doc = phr.find({'_id' => "#{hash}" }).first
  if !phr_doc.nil?
    phr_id = phr_doc[:_id]
    opd = phr_doc[:opd]
  else
    phr_id = 'NA'
    opd = 'NA'
  end

  json = {
    :_id => id,
    :ccaattmm => catm,
    :catms => catms,
    :name => "#{pre}#{fn} #{ln}",
    :dob => dob,
    :sex => sex,
    :hcode => hc,
    :hcodes => hcs,
    :pid => pid,
    :typearea => type,
    :types => types,
    :race => race,
    :nation => nation,
    :religion => rel,
    :education => edu,
    :d_update => d_update, 
    :phr_id => phr_id,
    :opd => opd
  }
else
  json = 'NA'
end

print <<EOF
Content-type: application/json

#{json.to_json}
EOF
