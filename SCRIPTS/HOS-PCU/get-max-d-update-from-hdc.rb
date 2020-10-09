#!/usr/bin/ruby

#encoding: utf-8
require 'mysql2'
require 'mongoid'
require 'pry'

# This script should RUN DAILY after 00:00

def delete_max_d_update()
  fn = "/tmp/HDC-MAX-D-UPDATE"
  if File.exists?(fn)
    File.delete(fn)
  end
end

def save(hc,max)
  fp = open("/tmp/HDC-MAX-D-UPDATE","a")
  fp.write("#{hc}|#{max.tr('-','')}\n")
  fp.close
end

# connect to MySQL: hdc
con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)
 
# set encoding to utf8
sql = "SET character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'"
res = con.query(sql)

# get 146 hcodes to hcs
hcs = []
src = open("HCODES-146").readlines
src.each do |line|
  hc = line.chomp
  hcs.push hc if hc.length == 5
end

# delete old HDC-MAX-D-UPDATE and prepare to WRITE a new file
delete_max_d_update()

# get LATEST D_UPDATE for each HCODE
hcs.each do |hc|
  sql = "SELECT max(cast(D_UPDATE AS date)) as max_d_update "
  sql += "FROM t_person_cid "
  sql += "WHERE HOSPCODE='#{hc}' "
  res = con.query(sql)
  max = nil
  res.each do |rec|
    max = rec['max_d_update']
  end
  # and append to file: HDC-MAX-D-UPDATE
  save(hc,max)
end

# find hcodes with CHANGED D_UPDATE
old = File.readlines('/tmp/MONGO-MAX-D-UPDATE', chomp: true)
new = File.readlines('/tmp/HDC-MAX-D-UPDATE', chomp: true)

# result will be Array
diff = new-old

diff.each do |kv|
  hcode = kv.split('|').first
  date = kv.split('|').last

  # update people for this HCODE on this DATE
  update_people = %x! ./update-people-daily.rb #{hcode} #{date} & !  
end

