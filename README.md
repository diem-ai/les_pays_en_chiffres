# Les pays en chiffres

## Description
The project is based on countries population dataset. The dataset is provided in CSV file.

The project requirements and objectives include:
- the use of PostgreSql with SaaS ElephantSQL free plan to create the countries population database (and the table)
- a country search function returning a TABLE
- a procedure for adding new country
- a trigger updating the country record creation date on INSERT
- a function/procedure returning the countries grouped by 4 dentsity values

### Notes on support for stored procedure in ElephantSQL free plan
PostgreSql support for procedure started at version 11 of PostgreSql.
With SaaS ElephantSQL free plan (Tiny Turtle), it is not possible to select PostgreSql version.
In the creation of the db instance, there is the choice of the cloud Region. Some Regions only have the version 9.x.y. I had to try out many Regions to obtain the version 11.x.y on US-East-1 (Northen Virginia) in AWS cloud.

### Notes on tools
To test my DDL code/script on the remote db in ElephantSQL, I use the tool PSQL (psql). The tool is packaged with PostgreSql. To have it I installed PostgreSQL (12.0) on my PC. The PostgreSql website is here https://www.enterprisedb.com/downloads/postgres-postgresql-downloads.

I also use the tool pgAdmin to create the db objects and to do the testing in the development phase. The pgAdmin website is here https://www.pgadmin.org/.


## Deliverables
- the documentation : this ***readme*** file

- the DDL file : the file ***country_stats_dll.sql***

- a country search function returning a TABLE : function ***get_country_stats(p_country varchar)***

- a procedure for adding new country : procedure ***add_country(p_country character varying)***

- a function/procedure returning the countries grouped by 4 dentsity values : function ***group_country_by_density()***

- a function updating the current datetime on the current triggered record : function ***trigg_funct_update_creation_dt()***

- a trigger updating the country record creation date on INSERT : trigger ***trigg_update_creation_dt()***


## Deployment

### Prerequisite
1) You have to install psql tool on your PC. You can install [PostgreSql](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads) 12.0 to have it

Note: you have to add posgresql into PATH environment variable</br>
<code>
set POSTPRESQL = C:\projets\pgsql\bin
</code>
</br>
<code>
set PATH=%PATH%;%POSTPRESQL%
</code>

2) You have to create an account in SaaS [ElephanSQL](https://www.elephantsql.com)

3) You have to create [an instance](https://www.elephantsql.com/plans.html) with the free plan (Tiny Turle) of PostgreSql with the version PostgreSQL 11 (or higher). The version 11.x.y is available in the Region US-East-1 (Northen Virginia)


### Execute the DDL file 
1) Clone the project and uncompress
- git clone https://github.com/diem-ai/les_pays_en_chiffres.git
-  Unzip and go to the root folder and do the following steps:
1) Connect to your posgresql instance on Elephantsql using psql on windows console</br>
<code>
psql postgres://user_name:pass_word@kandula.db.elephantsql.com:5432/database_name
</code>
<br/>
2) Execute the DDL file to create tables/functions/procedures and import the data from csv file</br>
<code>
psql \i country_stats_ddl.sql
</code>

### Issues
<i>Some issues you may encounter while using psql on console/terminal or pgAdmin in Windows 10</i>
1) The incompatibility of encoding between posgres and windows. You can find full explanation on [stackoverflow](https://stackoverflow.com/questions/20794035/postgresql-warning-console-code-page-437-differs-from-windows-code-page-125)</br>
<b>Solution:</b> :
- Start -> Run -> regedit
- Go to [HKEY_LOCAL_MACHINE\Software\Microsoft\Command Processor]
- Add new string value named "Autorun" with value "chcp 1252"
- Then reopen the console/terminal
2) Acces permission denied to database with PgAddmin</br>
<b>Solution</b>
- Add the below line in <code>pg_hba.conf</code> file:</br>
host    all             all             .db.elephantsql.com            trust
- It authorizes all connections from db.elephantsql.com address


## Some tests
1. List top 5 first countries in the database</br>
![](/images/test_select_top_first_5_rows.png)
2. Find a country existing in the database</br>
![](/images/test_func_get_country.png)
3. Add a new country with random data</br>
![](images/test_func_add_country.png)
4. Group the countries by their population density </br>
![](images/test_group_countries_by_density.png)


