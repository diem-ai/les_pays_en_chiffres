create or replace function get_country_stats(p_country varchar) 
	returns table (
		country_id integer,
		country_name varchar,
		population integer,
		yearly_change real,
		net_change integer,
		density smallint,
		land_area integer,
		migrants real,
		fert_rate real,
		med_age smallint,
		urban_pop real,
		world_share real,
		dt_creation timestamp
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
end;$$