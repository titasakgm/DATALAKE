#!/usr/bin/ruby

require 'mysql2'

date = ARGV[0]
if date.nil?
  puts "usage: #{$0} <D_UPDATE>\n"
  exit(0)
end

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)
sql = "SELECT count(*) as count FROM person "
sql += "WHERE date_format(D_UPDATE,'%Y%m%d')='#{date}' "
res = con.query(sql)
con.close

puts sql
res.each do |rec|
  puts rec["count"]
end
