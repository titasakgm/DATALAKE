#!/usr/bin/ruby

require 'rubygems'
require 'mysql2'

# count records from hdc
# input hcode and date

hcode = ARGV[0]
date = ARGV[1]
if date.nil?
  puts "usage: #{$0} <HCODE> <LAST DATE>\n"
  exit
end

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)

sql = "SELECT count(*) as count "
sql += "FROM t_person_cid "
sql += "WHERE HOSPCODE='#{hcode}' AND cast(D_UPDATE as date) > '#{date}'"
puts sql

res = con.query(sql)
res.each do |rec|
  puts rec["count"]
end
