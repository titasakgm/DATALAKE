#!/usr/bin/ruby

#encoding: utf8

###############################################
# SCRIPT: micro-05.rb
# DEVELOPER: drtoon
# DATE: 20200913
# PURPOSE: get person from hdc (hcode,d_update)
# OUTPUT: person_doc
###############################################

require 'rubygems'
require 'mysql2'
require 'mongoid'
require 'cgi'

def send_json(json)
print <<EOF
Content-type: application/json

#{json.to_json}
EOF
end

def padding(s)
  (0...13-s.length).each do |n|
    s = '0' + s
  end
  s
end

c = CGI::new
hcode = c['hcode']
updated_at = c['updated_at']

if hcode.to_s.length == 0
  exit
end

if updated_at.length == 0
print <<EOF
Content-type: text/html

Please INPUT hcode and updated as http://scripts/api/micro-05.rb?hcode=<HCODE>&updated_at=<UPDATED_AT>
hcode: [#{hcode}]
updated_at: [#{updated_at}]
EOF
exit
end

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)

Mongo::Logger.logger.level = Logger::FATAL

client = Mongo::Client.new([ "mongodb:27017" ],
  :database => 'trang',
  :user => 'backup',
  :password => 'datalake',
  :auth_source => 'admin'
)

db = client.database
people = db['people']

sql = "SET character_set_results = 'utf8', \
character_set_client = 'utf8', \
character_set_connection = 'utf8', \
character_set_database = 'utf8', \
character_set_server = 'utf8'"

sql = "SET NAMES utf8"
res = con.query(sql)

sql =<<EOS
SELECT CID as _id,
vhid as ccaattmm,
date_format(BIRTH,'%Y%m%d') as dob,
PID as pid,
HID as hid,
c.PRENAME as pre,
NAME as fname,
LNAME as lname,
HN as hn,
t.SEX as sex,
HOSPCODE as hcode,
TYPEAREA as typearea,
RACE as race,
NATION as nation,
RELIGION as religion,
EDUCATION as education,
date_format(D_UPDATE,'%Y%m%d') as updated_at
FROM t_person_cid t
LEFT OUTER JOIN cprename c ON (c.id_prename=t.PRENAME)
WHERE vhid LIKE '92%'
AND HOSPCODE='#{hcode}'
AND date_format(D_UPDATE,'%Y%m%d')='#{updated_at}'
ORDER BY CID
EOS

res = con.query(sql)

n = 0
d = []
pp = []
cid = nil

client = Mongo::Client.new([ "mongodb:27017" ],
  :database => 'trang',
  :user => 'backup',
  :password => 'datalake',
  :auth_source => 'admin'
)

db = client.database
people = db['people']
person_doc = nil

old_dob = nil
old_catm = nil
old_hcode = nil
old_type = nil

res.each do |rec|
  cid = padding(rec['_id'].to_s)
  d[0] = cid
  d[1] = rec['ccaattmm']
  d[2] = rec['dob']
  d[3] = rec['pid']
  d[4] = rec['hid']
  d[5] = rec['pre']
  d[6] = rec['fname']
  d[7] = rec['lname']
  d[8] = rec['hn']
  d[9] = rec['sex']
  d[10] = rec['hcode']
  d[11] = rec['typearea']
  d[12] = rec['race']
  d[13] = rec['nation']
  d[14] = rec['religion']
  d[15] = rec['education']
  d[16] = rec['updated_at']

  px = people.find({'_id' => cid}).as_json

  if px.count == 0 # This is new CID
    old_dob = nil
    dobs = [d[2]]
    old_catm = nil
    catms = [d[1]]
    old_hcode = nil
    hcodes = [d[10]]
    old_type = nil
    types = [d[11]]
  else
    old_dob = px[0]['dob']
    dobs = px[0]['dobs']
    old_catm = px[0]['ccaattmm']
    catms = px[0]['catms']
    old_hcode = px[0]['hcode']
    hcodes = px[0]['hcodes']
    old_type = px[0]['typearea']
    types = px[0]['types']
  end

  person_doc = {
    "_id" => cid,
    "ccaattmm" => d[1],
    "catms" => catms,
    "old_catm" => old_catm,
    "dob" => d[2],
    "dobs" => dobs,
    "old_dob" => old_dob,
    "pid" => d[3],
    "hid" => d[4],
    "pre" => d[5],
    "fname" => d[6],
    "lname" => d[7],
    "hn" => d[8],
    "sex" => d[9],
    "hcode" => d[10],
    "hcodes" => hcodes,
    "old_hcode" => old_hcode,
    "typearea" => d[11],
    "types" => types,
    "old_type" => old_type,
    "race" => d[12],
    "nation" => d[13],
    "religion" => d[14],
    "education" => d[15],
    "updated_at" => d[16] || Time.now.strftime("%Y%m%d")
  }
  pp.push(person_doc)
end

print <<EOF
Content-type: application/json

#{pp.to_json}
EOF

