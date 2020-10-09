#!/usr/bin/ruby

require 'json'

person_in = {
  "_id" => "1234567890123",
  "ccaattmm" => "92070116",
  "dob" => "20000101",
  "pid" => "000001",
  "hid" => "0001",
  "pre" => "น.ส.",
  "fname" => "ณัฎฐนิชา",
  "lname" => "บัวเกิด",
  "hn" => "000001",
  "sex" => "2",
  "hcode" => "11111",
  "typearea" => "1",
  "race" => "099",
  "nation" => "099",
  "religion" => "01",
  "education" => "02",
  "updated_at" => "20200101"
}

print <<EOF
Content-type: application/json

#{person_in.to_json}
EOF

