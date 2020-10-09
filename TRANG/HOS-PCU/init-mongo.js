db.createUser({
  user: "admin",
  pwd: "datalake",
  roles: [
    "readWriteAnyDatabase",
    "userAdminAnyDatabase",
    "dbAdminAnyDatabase"
  ]
});

db.createUser({
  user: "backup",
  pwd: "datalake",
  roles: [
    "readAnyDatabase"
  ]
});
