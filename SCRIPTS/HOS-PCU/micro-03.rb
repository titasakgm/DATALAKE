#!/usr/bin/ruby

#######################################
# SCRIPT: micro-03.rb
# DEVELOPER: drtoon
# DATE: 20200913
# PURPOSE: get LATEST D_UPDATE from hdc
# OUTPUT: /tmp/HDC-MAX-D-UPDATE
#######################################

require 'rubygems'
require 'cgi'
require 'mysql2'

# This script should RUN DAILY at 01:00

def delete_hdc_max_d_update()
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
sql = "SET character_set_results = 'utf8', \
character_set_client = 'utf8', \
character_set_connection = 'utf8', \
character_set_database = 'utf8', \
character_set_server = 'utf8'"
res = con.query(sql)

# get 146 hcodes to hcs
hcs = []
src = open("/opt/API/HCODES-146").readlines
src.each do |line|
  hc = line.chomp
  hcs.push hc if hc.length == 5
end

# delete old HDC-MAX-D-UPDATE and prepare to WRITE a new file
delete_hdc_max_d_update()

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
  # append to file: HDC-MAX-D-UPDATE
  save(hc,max)
end

print <<EOF
Content-type: text/html

Success
EOF
