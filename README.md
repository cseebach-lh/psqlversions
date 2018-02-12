# Psqlversions

Does maintaining the right database state when you're attempting to reproduce or fix a production problem get you down?

Me too. I built this gem to help manage lots of Postgres databases a little more easily. Here's a use case:

```bash
# you get a request for production support on issue 123
# you have a dump of relevant production data
# you have a development database
# what are all of them called again?
:~ cseebach$ psqlversions list
+---------------------------+------------+
| Database                  | Protected? |
+---------------------------+------------+
| data_dump_2018_02_08      | protected  |
| development_dev           |            |
+---------------------------+------------+
#
# that's right, I have a dump from Feb 9. that will be my starting point
:~ cseebach$ psqlversions drop development_dev
:~ cseebach$ psqlversions copy data_dump_2018_02_08 development_dev
#
# run any migration steps to bring your schema current, then checkpoint
:~ cseebach$ psqlversions checkpoint development_dev issue_123
:~ cseebach$ psqlversions list
+---------------------------+------------+
| Database                  | Protected? |
+---------------------------+------------+
| data_dump_2018_02_08      | protected  |
| development_dev           |            |
| issue_123-001             |            |
+---------------------------+------------+
# 
# bring your database state into the next state you want to test
# test it
# checkpoint
:~ cseebach$ psqlversions checkpoint development_dev issue_123
:~ cseebach$ psqlversions list
+---------------------------+------------+
| Database                  | Protected? |
+---------------------------+------------+
| data_dump_2018_02_08      | protected  |
| development_dev           |            |
| issue_123-001             |            |
| issue_123-002             |            |
+---------------------------+------------+
```

That's how it works right now. If that's interesting to you, installation is quick and easy.

# Installation

`gem install psqlversions`

# Other commands

See `psqlversions help` for more information about available commands, in addition to the below.

### Protect and Unprotect

If you're like me, you forget about which databases are important not to delete. psqlversions allows you to set flags
that it can follow when you use it to manage your databases.

```bash
:~ cseebach$ psqlversions list
+---------------------------+------------+
| Database                  | Protected? |
+---------------------------+------------+
| data_dump_2018_02_08      | protected  |
| development_dev           |            |
| issue_123-001             |            |
| issue_123-002             |            |
+---------------------------+------------+
#
# try dropping an unprotected database
:~ cseebach$ psqlversions drop issue_123-002
:~ cseebach$ psqlversions list
+---------------------------+------------+
| Database                  | Protected? |
+---------------------------+------------+
| data_dump_2018_02_08      | protected  |
| development_dev           |            |
| issue_123-001             |            |
+---------------------------+------------+
#
# try dropping a protected database
:~ cseebach$ psqlversions drop data_dump_2018_02_08
data_dump_2018_02_08 is protected and I won't drop it.
# 
# try protecting a database
# try unprotecting a database
:~ cseebach$ psqlversions protect development_dev
:~ cseebach$ psqlversions unprotect data_dump_2018_02_08
:~ cseebach$ psqlversions list
+---------------------------+------------+
| Database                  | Protected? |
+---------------------------+------------+
| data_dump_2018_02_08      |            |
| development_dev           | protected  |
| issue_123-001             |            |
+---------------------------+------------+
```
