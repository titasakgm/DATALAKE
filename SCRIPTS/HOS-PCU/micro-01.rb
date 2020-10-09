#!/usr/bin/ruby

########################################
# SCRIPT: micro-01.rb
# DEVELOPER: drtoon
# DATE: 20200913
# PURPOSE get unique 146 hcodes from hdc
# OUTPUT: /opt/SCRIPTS/HCODES-146
########################################

require 'rubygems'
require 'mysql2'

def delete_hcodes_146()
  fn = "/opt/SCRIPTS/HCODES-146"
  if File.exists?(fn)
    File.delete(fn)
  end
end

def save(hc)
  fp = open("/opt/SCRIPTS/HCODES-146","a")
  fp.write("#{hc}\n")
  fp.close
end

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)
 
# SET encoding utf8
sql = "SET character_set_results = 'utf8', \
character_set_client = 'utf8', \
character_set_connection = 'utf8', \
character_set_database = 'utf8', \
character_set_server = 'utf8'"
res = con.query(sql)

sql = "SELECT DISTINCT HOSPCODE as hcode "
sql += "FROM t_person_cid "
sql += "ORDER BY HOSPCODE"
res = con.query(sql)

# delete old HCODES-146
delete_hcodes_146()

res.each do |rec|
  hcode = rec['hcode']
  save(hcode)
end
