#!/usr/bin/ruby

#encoding: utf-8
require 'rubygems'
require 'mysql2'
require 'mongoid'
require 'pry-nav'

def update_mongo_d_max_update(hcode,date)
  file_data = ""
  replacement = "#{hcode}|#{date}"
  IO.foreach('MONGO-MAX-D-UPDATE') do |line|
    file_data += line.gsub(/^.*#{Regexp.quote(hcode)}.*$/, replacement)
  end

  # puts file_data

  File.open('MONGO-MAX-D-UPDATE', 'w') do |line|
    line.write file_data
  end
end

def padding(s)
  (0...13-s.length).each do |n|
    s = '0' + s
  end
  s
end

def insert_new_person(people,phr,alt_hashes,person_doc)
  # insert people
  people.insert_one(person_doc)

  # insert phr
  cid = person_doc['_id']
  dob = person_doc['dob']
  hash = %x! echo -n "#{cid}#{dob}" | multihash !.chomp[2..-1]
  phr_doc = {
    '_id' => hash,
    'ccaattmm' => person_doc['ccaattmm'],
    'opd' => [],
    'updated_at' => person_doc['updated_at']
  }
  phr.insert_one(phr_doc)

  # insert alt_hashes
  ccaattmm = person_doc['ccaattmm']
  alt_hash = {
    '_id' => hash,
    'ccaattmm' => ccaattmm,
    'hashes' => [hash],
    'updated_at' => person_doc['updated_at']
  }
  alt_hashes.insert_one(alt_hash)
end

def update_alt_hashes(alt_hashes,cid,old_dob,new_dob)
  origin_hash = %x! echo -n "#{cid}#{old_dob}" | multihash !.chomp[2..-1]
  new_hash = %x! echo -n "#{cid}#{new_dob}" | multihash !.chomp[2..-1]
  hash = alt_hashes.find({_id: /#{origin_hash}/})
  if hash.as_json != []
    h = hash.as_json.first
    if h.nil?
      old_hashes = []
    else
      old_hashes = h.hashes
    end
    new_hashes = old_hashes.push(new_hash)
  else
    new_hashes = [new_hash]
  end
  alt_hashes.find_one_and_replace( {'_id' => /#{origin_hash}/}, {'hashes' => new_hashes} )
end

def update_person(people,phr,alt_hashes,orig_person,person_doc)
  cid = person_doc['_id']
  orig_ccaattmm = orig_person['ccaattmm']
  orig_catms = orig_person['catms']
  orig_dob = orig_person['dob']
  orig_dobs = orig_person['dobs']
  orig_type = orig_person['typearea']
  orig_types = orig_person['types']

  new_ccaattmm = person_doc['ccaattmm']
  new_dob = person_doc['dob']
  new_type = person_doc['typearea']

  if !orig_catms.include?(new_ccaattmm) # this is new ccaattmm
    person_doc['catms'] = orig_catms.push(new_ccaattmm)
  end

  if !orig_dobs.include?(new_dob) # this is new dob
    person_doc['dobs'] = orig_dobs.push(new_dob)
    # must map new_hash with original_hash
    update_alt_hashes(alt_hashes,cid,orig_dob,new_dob)
  end

  if !orig_types.include?(new_type) # this is new typearea
    person_doc['types'] = orig_types.push(new_type)
  end

  # update PEOPLE
  people.find_one_and_replace({'_id' => cid}, person_doc)
end

hcode = ARGV[0]
date = ARGV[1]
if date.nil?
  puts "usage: #{$0} <HCODE> <D_UPDATE>\n"
  exit(0)
end

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)
 
Mongo::Logger.logger.level = Logger::FATAL

trang = Mongo::Client.new([ 'mongodb:27017' ],
  :database => 'trang',
  :user => 'admin',
  :password => 'datalake',
  :auth_source => 'admin'
)

people = trang[:people]
phr = trang[:phr]
alt_hashes = trang[:alt_hashes]

# SET encoding utf8
sql = "SET character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'"
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
WHERE HOSPCODE='#{hcode}'
AND date_format(D_UPDATE,'%Y%m%d')='#{date}'
ORDER BY CID
EOS

# puts sql

res = con.query(sql)

n = 0
d = []
cid = nil

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

  person_doc = {
    "_id" => cid,
    "ccaattmm" => d[1],
    "catms" => [d[1]],
    "dob" => d[2],
    "dobs" => [d[2]],
    "pid" => d[3],
    "hid" => d[4],
    "pre" => d[5],
    "fname" => d[6],
    "lname" => d[7],
    "hn" => d[8],
    "sex" => d[9],
    "hcode" => d[10],
    "hcodes" => [d[10]],
    "typearea" => d[11],
    "types" => [d[11]],
    "race" => d[12],
    "nation" => d[13],
    "religion" => d[14],
    "education" => d[15],
    "updated_at" => d[16] || Time.now.strftime("%Y%m%d")
  }

  # puts person_doc

  # check if cid exists?

  person = people.find({'_id' => cid})
  orig_person = person.as_json.first
  if orig_person.nil? # or person.as_json == []: CID not exist
    insert_new_person(people,phr,alt_hashes,person_doc)
  else # CID exists
    if person_doc != orig_person
      update_person(people,phr,alt_hashes,orig_person,person_doc)
    end
  end
end

# update MONGO-MAX-D-UPDATE
# replace new D_UPDATE for HCODE
update_mongo_d_max_update(hcode,date)

# SEND person_doc phr_doc alt_hash_doc VIA MQTT!!!
# PENDING!!!
