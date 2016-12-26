# djangdeifir
A bash script for fast creation of Django virtual environments with PostgreSQL

- Script creates a development directory in ~/dev_env
- Requests Project Name, Database Name, Database User and Database Password
- Then installs virtualenv, Django, Postgres and dependencies
- Auto updates ~dev_env/\<project_name\>/\<project_name\>/settings.py with correct PostgreSQL settings

<strong>sudo bash djangdeifir.sh</strong> to run

Bonus: 'deifir' is the Irish word for 'haste' and is pronounced djeffer
