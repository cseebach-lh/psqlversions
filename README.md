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

# License

This gem is available under the terms of the GPL v3.0 - see `LICENSE` - but it linked against two libraries available 
under the MIT license, Terminal Table (for pretty tables) and Daybreak (for protection persistence). Those dependency 
licenses are included below.

`https://github.com/tj/terminal-table`
```text
The MIT License (MIT)

Copyright (c) 2008-2017 TJ Holowaychuk <tj@vision-media.ca>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

`http://propublica.github.io/daybreak/`
```text
Copyright (c) 2012 - 2013 ProPublica

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```


