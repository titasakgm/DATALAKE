#!/usr/bin/ruby

require 'json'

=begin
person_in = {
  "_id"=>"1234567890123",
  "ccaattmm"=>"92079999",
  "dob"=>"20000101",
  "pid"=>"000001",
  "hid"=>"0001",
  "pre"=>"น.ส.",
  "fname"=>"ณัฎฐนิชา",
  "lname"=>"บัวเกิด",
  "hn"=>"000001",
  "sex"=>"2",
  "hcode"=>"99999",
  "typearea"=>"9",
  "race"=>"099",
  "nation"=>"099",
  "religion"=>"01",
  "education"=>"02",
  "updated_at"=>"20200922",
  "dobs"=>["20000101", "20201111"],
  "catms"=>["92070116", "92079999"],
  "hcodes"=>["11111", "99999"],
  "types"=>["1", "9"]
}
=end

opd_statement = {
  "hcode" => "99999",
  "pid" => "000001",
  "cid" => "1234567890123",
  "hid" => "0001",
  "typearea" => "9",
  "ccaattmm" => "92079999",
  "hn" => "000001",
  "pre" => "น.ส.",
  "fname" => "ณัฎฐนิชา",
  "lname" => "บัวเกิด",
  "dob" => "20000101",
  "sex" => "2",
  "occupation" => "XX",
  "mstatus" => "xx",
  "religion" => "01",
  "race" => "099",
  "education" => "02",
  "fstatus" => "XX",
  "father" => "XX",
  "mother" => "XX",
  "couple" => "XX",
  "movein" => "XX",
  "discharge" => "XX",
  "ddischarge" => "XX",
  "updated_at" => "20200923" 
}

print <<EOF
Content-type: application/json

#{opd_statement.to_json}
EOF

