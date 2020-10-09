#!/usr/bin/ruby

#encoding: utf-8
require 'rubygems'
require 'mongoid'
require 'pry'

# USAGE:
# cat /home/hdc_data/per_aa | ruby -n insert-person-to-mongodb.rb
# PROCESS: 100,000 records in 30 minutes
# ADD BLANK LINE to per_aa .. per_aj
# ruby -n NOT PROCESS first line!!!

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

n = 0
while line = gets()
  d = line.chomp.split('|')
  cid = d[0]
  person_doc = {
    "_id" => d[0],
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
  n += 1 
  if n % 1000 == 0
    puts "#{Time.now.strftime("%H:%M:%S")}: #{n}" 
  end
end
