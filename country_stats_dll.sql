-- Start drop tables , functions, procedures , triggers if they exist

DROP TABLE IF EXISTS TEMP_COUNTRY;
DROP TABLE IF EXISTS COUNTRY_STATS;
DROP FUNCTION IF EXISTS trigg_funct_clean_data();
DROP FUNCTION IF EXISTS get_country_stats(varchar);
DROP FUNCTION IF EXISTS get_world_population();
DROP FUNCTION IF EXISTS group_country_by_density();
DROP PROCEDURE IF EXISTS add_country(varchar);
DROP TRIGGER IF EXISTS clean_data_before_insert ON TEMP_COUNTRY;
DROP TRIGGER IF EXISTS trigg_update_creation_dt ON COUNTRY_STATS;

-- 1) database creation
-- create 2 tables temp_country and country_stats
-- temp_country is a temporary table who stores the data imported from csv file. Data is cleaned before inserting
-- country_stats is a table who stores the clean data sent from temporary_table

CREATE TABLE TEMP_COUNTRY(
COUNTRY_ID serial 
, COUNTRY_NAME varchar
, POPULATION varchar
, YEARLY_CHANGE varchar
, NET_CHANGE varchar
, DENSITY varchar
, LAND_AREA varchar
, MIGRANTS varchar
, FERT_RATE varchar
, MED_AGE varchar
, URBAN_POP varchar
, WORLD_SHARE varchar
);

CREATE TABLE COUNTRY_STATS(
COUNTRY_ID SERIAL
, COUNTRY_NAME VARCHAR NOT NULL
, POPULATION BIGINT NULL
--, YEARLY_CHANGE NUMERIC(2,2) NULL
, YEARLY_CHANGE NUMERIC (5,2) NULL
-- net_change => net variation of the population
, NET_CHANGE BIGINT NULL
, DENSITY SMALLINT NULL
, LAND_AREA BIGINT NULL
--, MIGRANTS REAL NULL
, MIGRANTS INTEGER NULL
-- fert_rate is fertility rate. It represents % and the values are low. Max is 100 (%) but no country in the world has fert_rate> 6%
--, FERT_RATE NUMERIC(2,2) NULL
, FERT_RATE NUMERIC (5,2) NULL
-- med_age = Medium Age. Max age of a person in the world <120 years => smallint
, MED_AGE SMALLINT NULL
-- urban pop represents the share (%) of the population who lives in cities. Maximum is 100 (%) => numeric (3,2)
--, URBAN_POP NUMERIC (3,2) NULL
, URBAN_POP NUMERIC (5,2) NULL
-- world_share is %. Maximum is 100 (%) => numeric (2,2)
--, WORLD_SHARE NUMERIC (2,2)
, WORLD_SHARE NUMERIC (5,2) NULL
, DT_CREATION TIMESTAMP NULL
, PRIMARY KEY(COUNTRY_ID)
, UNIQUE (COUNTRY_NAME)	
);

-- 2) create a clean_data() function who takes out % and N.A.
-- start the transsction of trigg_funct_clean_data() function creation

CREATE OR REPLACE FUNCTION trigg_funct_clean_data()
RETURNS TRIGGER
LANGUAGE PLPGSQL AS
$BODY$
DECLARE

	V_POPULATION VARCHAR;
	V_YEARLY_CHANGE VARCHAR;
	V_NET_CHANGE VARCHAR;
	V_DENSITY VARCHAR;
	V_LAND_AREA VARCHAR;
	V_MIGRANTS VARCHAR;
	V_FERT_RATE VARCHAR;
	V_MED_AGE VARCHAR;
	V_URBAN_POP VARCHAR;
	V_WORLD_SHARE VARCHAR;

BEGIN
	
	V_POPULATION = CAST(NEW.POPULATION AS VARCHAR);
	IF (POSITION('N.A.' IN V_POPULATION) > 0) THEN
		NEW.POPULATION = NULL;
	END IF;
	
	V_YEARLY_CHANGE = CAST(NEW.YEARLY_CHANGE AS VARCHAR);
	IF (POSITION('N.A.' IN V_YEARLY_CHANGE) > 0) THEN
		NEW.YEARLY_CHANGE = NULL;
	ELSIF (POSITION('%' IN V_YEARLY_CHANGE) > 0) THEN
		NEW.YEARLY_CHANGE = TRIM(REPLACE(V_YEARLY_CHANGE, '%',''));
	END IF;
	
	V_NET_CHANGE = CAST(NEW.NET_CHANGE AS VARCHAR);					 
	IF (POSITION('N.A.' IN V_NET_CHANGE) > 0) THEN
		NEW.NET_CHANGE = NULL;
	END IF;

	V_DENSITY = CAST(NEW.DENSITY AS VARCHAR);					 
	IF (POSITION('N.A.' IN V_DENSITY) > 0) THEN
		NEW.DENSITY = NULL;
	END IF;
	
	V_LAND_AREA = CAST(NEW.LAND_AREA AS VARCHAR);						 
	IF (POSITION('N.A.' IN V_LAND_AREA) > 0) THEN
		NEW.LAND_AREA = NULL;
	END IF;
	
	V_MIGRANTS = CAST(NEW.MIGRANTS AS VARCHAR);				
	IF (POSITION('N.A.' IN V_MIGRANTS) > 0) THEN
		NEW.MIGRANTS = NULL;
	END IF;
	
	V_FERT_RATE = CAST(NEW.FERT_RATE AS VARCHAR);
	IF (POSITION('N.A.' IN V_FERT_RATE) > 0) THEN
		NEW.FERT_RATE = NULL;
	END IF;
	
	V_MED_AGE = CAST(NEW.MED_AGE AS VARCHAR);						 
	IF (POSITION('N.A.' IN V_MED_AGE) > 0) THEN
		NEW.MED_AGE = NULL;
	END IF;
	
	V_URBAN_POP = CAST(NEW.URBAN_POP AS VARCHAR);
	IF (POSITION('N.A.' IN V_URBAN_POP) > 0) THEN
		NEW.URBAN_POP = NULL;
	ELSIF (POSITION('%' IN V_URBAN_POP) > 0) THEN
		NEW.URBAN_POP = TRIM(REPLACE(V_URBAN_POP,'%',''));
	END IF;
	
	V_WORLD_SHARE = CAST(NEW.WORLD_SHARE AS VARCHAR);
	IF (POSITION('N.A.' IN V_WORLD_SHARE) > 0) THEN
		NEW.WORLD_SHARE = NULL;
	ELSIF (POSITION('%' IN V_WORLD_SHARE) > 0) THEN
		NEW.WORLD_SHARE = TRIM(REPLACE(V_WORLD_SHARE, '%', ''));
	END IF;
	
	RETURN NEW;
END
$BODY$;

-- 3) create a trigger on tempary_country with trigg_funct_clean_data() function

CREATE TRIGGER clean_data_before_insert 
BEFORE INSERT OR UPDATE ON TEMP_COUNTRY
FOR EACH ROW EXECUTE PROCEDURE trigg_funct_clean_data();

-- creation of trigg_funct_update_creation_dt()
CREATE OR REPLACE FUNCTION trigg_funct_update_creation_dt()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	UPDATE COUNTRY_STATS 
	SET dt_creation = now() 
	WHERE COUNTRY_ID = NEW.COUNTRY_ID;
	RETURN NEW;
END
$BODY$;


CREATE TRIGGER trigg_update_creation_dt
    AFTER INSERT
    ON COUNTRY_STATS
    FOR EACH ROW
    EXECUTE PROCEDURE trigg_funct_update_creation_dt();


\COPY TEMP_COUNTRY(COUNTRY_NAME, POPULATION, YEARLY_CHANGE, NET_CHANGE, DENSITY, LAND_AREA, MIGRANTS, FERT_RATE, MED_AGE, URBAN_POP, WORLD_SHARE) FROM 'population_by_country_2020.csv' DELIMITER ',' CSV HEADER;

-- 5) copy data from temp_country to country_stats
INSERT INTO COUNTRY_STATS (
	COUNTRY_NAME
	, POPULATION
	, YEARLY_CHANGE
	, NET_CHANGE
	, DENSITY
	, LAND_AREA
	, MIGRANTS
	, FERT_RATE
	, MED_AGE
	, URBAN_POP
	, WORLD_SHARE)
SELECT COUNTRY_NAME
, CAST (POPULATION AS BIGINT)
, CAST (YEARLY_CHANGE AS NUMERIC)
, CAST (NET_CHANGE AS BIGINT)
, CAST (DENSITY AS SMALLINT)
, CAST (LAND_AREA AS BIGINT)
, CAST(CAST (MIGRANTS AS NUMERIC) AS INTEGER)
, CAST (FERT_RATE AS NUMERIC)
, CAST(MED_AGE AS SMALLINT)
, CAST(URBAN_POP AS NUMERIC)
, CAST(WORLD_SHARE AS NUMERIC)
FROM TEMP_COUNTRY;

create or replace function get_world_population() 
returns bigint
language plpgsql  
as $$
declare
	i_res bigint;
begin
	select sum(population) into i_res
	from country_stats;
	
	return i_res;
	
end
$$;

CREATE OR REPLACE PROCEDURE add_country(p_country character varying)
LANGUAGE 'plpgsql'
AS $BODY$
declare
		rand1 int;
		rand2 int; -- a randomized 2 digits number
begin
	-- generate a radomized number with at least 2 digits before the decimal dot 
	select (random()*10000000)::int into rand1; -- it should have at least 2 digits before the decimal dot
	select rand1/power(10, floor(log(10, rand1))-1)::int into rand2; -- the randomized 2 digits number
	
	-- select randomly an existing record to use as a base for calculation of the values of the new record
	insert into country_stats (country_name
								   , population
								   , net_change
								   , land_area
								   , migrants
								   , fert_rate
								   , med_age
								   , urban_pop)
	select p_country, 
	      	-- population + the randomized 2 digits percentage
			(population + population*rand2/100)::bigint, 
			-- net_change + the randomized 2 digits percentage
			(net_change + net_change*rand2/100)::bigint, 
			-- land_area + the randomized 2 digits percentage
			(land_area + land_area*rand2/100)::bigint, 
			-- migrants + the randomized 2 digits percentage
			(migrants + migrants*rand2/100)::integer, 
			-- fert_rate + the randomized 2 digits percentage
			(fert_rate + fert_rate*rand2/100)::numeric (5,2), 
			-- med_age + the randomized 2 digits percentage
			(med_age + med_age*rand2/100)::smallint, 
			-- urban_pop + the randomized 2 digits percentage, limited to 100(%)
			least((urban_pop + urban_pop*rand2/100)::numeric (5,2), 100)
	from country_stats
	order by random() limit 1; -- this is how to select randomly an existing record
	
	-- calculate yearly_change from population and net_change (= net_change*100/population)
	-- calculate density from population and land_area (= population / land_area)
	-- calculate world_share from population and world population (= population / world population)
	update country_stats
	set yearly_change = trunc(net_change*100.0/100.0/population*100, 2),
		density = population / land_area
		, world_share = trunc(population*100.0/100.0/get_world_population()*100, 2)
	where lower(country_name) = lower(p_country);
	
	-- calculate world_share from population and world population (= population / world population)
	/*
	update country_stats
	set world_share = trunc(population*100.0/100.0/get_world_population()*100, 2);
	*/
    commit;
end
$BODY$;

create or replace function get_country_stats(p_country varchar) 
	returns table (
		country_id integer
		, country_name varchar
		, population bigint
		, yearly_change numeric (5,2)
		, net_change bigint
		, density smallint
		, land_area bigint
		, migrants integer
		, fert_rate numeric (5,2)
		, med_age smallint
		, urban_pop numeric (5,2)
		, world_share numeric (5,2)
		, dt_creation timestamp
	)
	language plpgsql  
as $$
begin
	return query
			select 
				cs.country_id, 
				cs.country_name, 
				cs.population,
				cs.yearly_change,
				cs.net_change,
				cs.density,
				cs.land_area,
				cs.migrants,
				cs.fert_rate,
				cs.med_age,
				cs.urban_pop,
				cs.world_share,
				cs.dt_creation
			from country_stats as cs
			where upper(cs.country_name) = upper(p_country);
end
$$;

-- Start the creation of group_country_by_density()
create or replace function group_country_by_density() 
	returns table (
		country_id integer,
		country_name varchar,
		population bigint,
		yearly_change numeric (5,2),
		net_change bigint,
		density smallint,
		land_area bigint,
		migrants integer,
		fert_rate numeric (5,2),
		med_age smallint,
		urban_pop numeric (5,2),
		world_share numeric (5,2),
		group_by_density integer
	)
	language plpgsql  
as $$
begin
	return query
			select 
				cs.country_id, 
				cs.country_name, 
				cs.population,
				cs.yearly_change,
				cs.net_change,
				cs.density,
				cs.land_area,
				cs.migrants,
				cs.fert_rate,
				cs.med_age,
				cs.urban_pop,
				cs.world_share
				, ntile(4) over (
				   order by cs.density
				) as group_by_density
			from country_stats cs;
			
end
$$;