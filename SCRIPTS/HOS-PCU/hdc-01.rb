#!/usr/bin/ruby

require 'rubygems'
require 'mysql2'

# example script to connect database:hdc (MySQL)
# user:pass = trang:datalake READ-ONLY for hdc

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)

sql = "SELECT count(*) as count "
sql += "FROM t_person_cid "
sql += "WHERE vhid LIKE '92%'"
puts sql

res = con.query(sql)
res.each do |rec|
  puts rec["count"]
end
