# Les pays en chiffres

## Description

## Deployment
### Prerequisite
1) [Postgresql](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads) <= 12.0 is installed
2) An account is available [ElephanSQL](https://www.elephantsql.com)
3) [An instance](https://www.elephantsql.com/plans.html) of Postgresql with Free plan should be created. 
### Create environment variable
1) Add posgresql into PATH environment variable
<code>
set POSTPRESQL = C:\projets\pgsql\bin
</code>
<br/>
<code>
set PATH=%PATH%;%POSTPRESQL%
</code>

### Execute DLL file 
1) Clone the project and uncompress
- git clone
-  Unzip and go to the root folder and do the following steps:
1) Connect to your posgresql instance on Elephantsql using psql on windows console
<code>
> psql postgres://<username>:wi_CMm1f7QCFAdKPEyP4V1d-SSHwgfiJ@kandula.db.elephantsql.com:5432/<database name>
</code>
<br/>
2) Execute the DLL file to create tables/functions/procedures and import the data from csv file
<code>
psql \i country_stats_dll.sql
</code>

### Issues
<i>Some issues you may encounter while using psql on console/terminal or pgAdmin in Windows 10</i>
1) The incompatibility of encoding between posgres and windows. You can find full explanation on [stackoverflow](https://stackoverflow.com/questions/20794035/postgresql-warning-console-code-page-437-differs-from-windows-code-page-125)
<b>Solution:</b> :
- Start -> Run -> regedit
- Go to [HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor]
- Add new string value named "Autorun" with value "chcp 1252"
- Then reopen the console/terminal
2) Acces permission denied to database with PgAddmin
<b>Solution</b>
- Add the below line in <code>pg_hba.conf</code> file:
host    all             all             .db.elephantsql.com            trust
- It authorizes all connections from db.elephantsql.com address

## Some tests
1. Find a country existing in the database



