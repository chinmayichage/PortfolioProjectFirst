SELECT iso_code, continent, "location", "date", population, total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million
FROM public.coviddeaths;

--(____________________________________________________________________________________________________________________________)
--selecting basic data 
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths 
where continent is not null
order by 1,2


create view selectbasicdata as 
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths 
where continent is not null
order by 1,2



--(____________________________________________________________________________________________________________________________)
-- Basic data view
SELECT location, date, total_cases, new_cases, population
FROM coviddeaths
WHERE location ILIKE '%india%'
ORDER BY 1, 2



create view selectbasicdataindia as 
SELECT location, date, total_cases, new_cases, population
FROM coviddeaths
WHERE location ILIKE '%india%'
ORDER BY 1, 2


--(____________________________________________________________________________________________________________________________)
-- Death percentage
SELECT location, date, total_cases, total_deaths, 
       (total_deaths::float / total_cases) * 100 as deathpercent
FROM coviddeaths
WHERE location ILIKE '%india%'
ORDER BY 1, 2;


create view deathpercentageind as 
SELECT location, date, total_cases, total_deaths, 
       (total_deaths::float / total_cases) * 100 as deathpercent
FROM coviddeaths
WHERE location ILIKE '%india%'
ORDER BY 1, 2;


--(____________________________________________________________________________________________________________________________)
-- Highest infection rate by location
SELECT location, population, MAX(total_cases) as highinfects, 
       MAX((total_cases::float / population)) * 100 as highestinfectionpercent
FROM coviddeaths
WHERE population IS NOT NULL AND total_cases IS NOT NULL
GROUP BY location, population
ORDER BY highestinfectionpercent DESC;


create view highestinfectrate as 
SELECT location, population, MAX(total_cases) as highinfects, 
       MAX((total_cases::float / population)) * 100 as highestinfectionpercent
FROM coviddeaths
WHERE population IS NOT NULL AND total_cases IS NOT NULL
GROUP BY location, population
ORDER BY highestinfectionpercent DESC;


--(____________________________________________________________________________________________________________________________)
--total deaths 
select location, max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by location
having max(total_deaths) is not null
order by totaldeathcount desc;



create view totaldeathselect as 
select location, max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by location
having max(total_deaths) is not null
order by totaldeathcount desc;


--(____________________________________________________________________________________________________________________________)
-- BREAK THINGS DOWN BY CONTINENT
SELECT continent, SUM(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM (
    SELECT continent, location, MAX(total_deaths) AS total_deaths
    FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
) AS subquery
GROUP BY continent
ORDER BY TotalDeathCount DESC;



create view continenttotaldeath as 
SELECT continent, SUM(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM (
    SELECT continent, location, MAX(total_deaths) AS total_deaths
    FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
) AS subquery
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--(____________________________________________________________________________________________________________________________)
-- showing the continents with high death
select location, max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by location
having max(total_deaths) is not null
order by totaldeathcount desc;


create view continentwithmostdeath as 
select location, max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by location
having max(total_deaths) is not null
order by totaldeathcount desc;



--(____________________________________________________________________________________________________________________________)
--global paitents vs deaths
select date, sum(new_cases), sum(new_deaths)
from coviddeaths 
where continent is not null 
group by date 
order by 1,2


create view gpaitentvsdeath as
select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths
from coviddeaths
where continent is not null
group by date
order by 1,2;




--(____________________________________________________________________________________________________________________________)
--deathratio%
select date, sum(new_cases) as totalcases , sum(new_deaths) as totaldeaths , (sum(new_deaths)::float / NULLIF(sum(new_cases), 0)) * 100 as deathratio
from coviddeaths 
where continent is not null 
group by date 
order by 1,2


create view gdeathratio as
select date, sum(new_cases) as totalcases , sum(new_deaths) as totaldeaths , (sum(new_deaths)::float / NULLIF(sum(new_cases), 0)) * 100 as deathratio
from coviddeaths 
where continent is not null 
group by date 
order by 1,2





--(____________________________________________________________________________________________________________________________)
select * 
from covidvaccinations;



--(____________________________________________________________________________________________________________________________)
--joining both the tables

select * 
from coviddeaths dth
join covidvaccinations vac
	on dth."location" = vac."location" 
	and dth."date" = vac."date" 
--(____________________________________________________________________________________________________________________________)
--total population vs vaccination

select dth.continent ,dth."location" , dth."date" , dth.population ,vac.new_vaccinations 
from coviddeaths dth
join covidvaccinations vac
	on dth."location" = vac."location" 
	and dth."date" = vac."date" 
where dth.continent is not null 
order by 2,3


create view tpopulationvsvaccin as 
select dth.continent ,dth."location" , dth."date" , dth.population ,vac.new_vaccinations 
from coviddeaths dth
join covidvaccinations vac
	on dth."location" = vac."location" 
	and dth."date" = vac."date" 
where dth.continent is not null 
order by 2,3


--(____________________________________________________________________________________________________________________________)
--for calculating vaccinations using rolling count

select dth.continent, dth."location", dth."date", dth.population, 
       vac.new_vaccinations, 
       sum(CAST(NULLIF(vac.new_vaccinations, '') AS bigint)) 
           over (partition by dth."location" order by dth."location", dth."date") 
           as totalvaccinationrolling
from coviddeaths dth
join covidvaccinations vac
    on dth."location" = vac."location"
    and dth."date" = vac."date"
where dth.continent is not null
order by 2,3;



create view vaccinrollingcount as
select dth.continent, dth."location", dth."date", dth.population, 
       vac.new_vaccinations, 
       sum(CAST(NULLIF(vac.new_vaccinations, '') AS bigint)) 
           over (partition by dth."location" order by dth."location", dth."date") 
           as totalvaccinationrolling
from coviddeaths dth
join covidvaccinations vac
    on dth."location" = vac."location"
    and dth."date" = vac."date"
where dth.continent is not null
order by 2,3;


--(____________________________________________________________________________________________________________________________)
--using CTE 
with populvsvacci (continent, location, date, population, new_vaccinations, totalvaccinationrolling ) 
as (
select dth.continent, dth."location", dth."date", dth.population, vac.new_vaccinations, sum(CAST(NULLIF(vac.new_vaccinations, '') AS bigint)) over (partition by dth."location" order by dth."location", dth."date") as totalvaccinationrolling
from coviddeaths dth
join covidvaccinations vac
    on dth."location" = vac."location"
    and dth."date" = vac."date"
where dth.continent is not null
)
select * , (totalvaccinationrolling/population)*100 as percentvaccipublic
from populvsvacci ;


create view vaccincte as 
with populvsvacci (continent, location, date, population, new_vaccinations, totalvaccinationrolling ) 
as (
select dth.continent, dth."location", dth."date", dth.population, vac.new_vaccinations, sum(CAST(NULLIF(vac.new_vaccinations, '') AS bigint)) over (partition by dth."location" order by dth."location", dth."date") as totalvaccinationrolling
from coviddeaths dth
join covidvaccinations vac
    on dth."location" = vac."location"
    and dth."date" = vac."date"
where dth.continent is not null
)
select * , (totalvaccinationrolling/population)*100 as percentvaccipublic
from populvsvacci ;


--(____________________________________________________________________________________________________________________________)
--TEMP Table
-- Drop if exists
drop table if exists publicpercentvaccin;

-- Create and populate in one go
create table publicpercentvaccin as
select dth.continent, dth."location", dth."date", dth.population, vac.new_vaccinations, 
       sum(CAST(NULLIF(vac.new_vaccinations, '') AS bigint)) over (partition by dth."location" order by dth."location", dth."date") as totalvaccinationrolling
from coviddeaths dth
join covidvaccinations vac
    on dth."location" = vac."location"
    and dth."date" = vac."date"
where dth.continent is not null;

-- Query the percentage
select *, (totalvaccinationrolling::float/population)*100 as percentvaccipublic
from publicpercentvaccin;

--(____________________________________________________________________________________________________________________________)
--finally creating view for later visualtions

create view publicpercentvaccins as
select dth.continent, dth."location", dth."date", dth.population, vac.new_vaccinations, 
       sum(CAST(NULLIF(vac.new_vaccinations, '') AS bigint)) over (partition by dth."location" order by dth."location", dth."date") as totalvaccinationrolling
from coviddeaths dth
join covidvaccinations vac
    on dth."location" = vac."location"
    and dth."date" = vac."date"
where dth.continent is not null;

select * 
from publicpercentvaccins


--(____________________________________________________________________________________________________________________________)
























