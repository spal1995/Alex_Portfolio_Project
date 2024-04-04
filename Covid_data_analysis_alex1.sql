-- Data showing information of covide deaths sorted in ascending order
Select location,date,total_cases,new_cases,total_deaths,population from Portfolio.CovidDeaths
order by 1,2;

-- Finding the percentage of death per date
Select location,date,total_cases,new_cases,total_deaths,population, (total_deaths/total_cases)*100 as Death_percent from Portfolio.CovidDeaths
where [location] = 'India'
order by 1,2;

-- Finding the percentage of population having COVID per date
Select location,date,total_cases,new_cases,total_deaths,population, (total_cases/population)*100 as Covid_population_percent from Portfolio.CovidDeaths
where [location] = 'India'
order by 1,2;

--Country with the highest infection compared to population
Select location, population,max(total_cases) Highest_infection_count,Max((total_cases/population))*100 as Highest_percent_infection from Portfolio.CovidDeaths
--where [location] = 'India'
group by location,population
order by 4 DESC;


--Country with the highest death_count compared to population
Select location, population,max(total_deaths) Highest_death_count,Max((total_deaths/population))*100 as Highest_percent_death from Portfolio.CovidDeaths
--where [location] = 'India'
where continent is NOT NULL
group by location,population
order by 3 DESC;

--CONTINENT with the highest death_count compared to population
Select location, population,max(total_deaths) Highest_death_count,Max((total_deaths/population))*100 as Highest_percent_death from Portfolio.CovidDeaths
--where [location] = 'India'
where continent is NULL
and population is NOT NULL
group by location,population
order by 3 DESC;


-- Total cases as per day
select date, SUM(new_cases) new_cases_on_date,SUM(new_deaths) new_death_on_date,(SUM(new_deaths)/SUM(new_cases))*100 new_death_percent_on_date--(total_deaths/population) * 100 as Death_percent 
from Portfolio.CovidDeaths
where continent is NOT NULL
group by date
order by 1,2


-- Joining 2 tables
select *
from Portfolio.CovidDeaths pd
JOIN Portfolio.CovidVaccinations pv
on pd.[location]=pv.[location]
and pd.[date]=pv.[date]

select pd.continent, pd.location, pd.date, pd.population, pv.new_vaccinations
from Portfolio.CovidDeaths pd
JOIN Portfolio.CovidVaccinations pv
on pd.[location]=pv.[location]
and pd.[date]=pv.[date]
where pd.continent IS NOT NULL
order by 2,3

-- Rolling count of vaccinations each day
select pd.continent, pd.location, pd.date, pd.population, pv.new_vaccinations,
SUM(CONVERT(int,pv.new_vaccinations)) OVER (partition by pd.location order by pd.location,pd.date) as vaccines_each_day
from Portfolio.CovidDeaths pd
JOIN Portfolio.CovidVaccinations pv
on pd.[location]=pv.[location]
and pd.[date]=pv.[date]
where pd.continent IS NOT NULL
order by 2,3

-- If we want to do a percentage calculation with the  new value : vaccines_each_day we cant here
-- So we create a CTE table or temp table and proceed
-- Use CTE

With Calc_vaccines_each_day (Continent, Location, Date, Population, Vaccines, Vaccines_each_day)
AS
(
  select pd.continent, pd.location, pd.date, pd.population, pv.new_vaccinations,
SUM(CONVERT(int,pv.new_vaccinations)) OVER (partition by pd.location order by pd.location,pd.date) as vaccines_each_day
from Portfolio.CovidDeaths pd
JOIN Portfolio.CovidVaccinations pv
on pd.[location]=pv.[location]
and pd.[date]=pv.[date]
where pd.continent IS NOT NULL
--order by 2,3  
)
select *,(Vaccines_each_day/Population)*100 as Vaccines_percent_each_day from Calc_vaccines_each_day order by 2,3  

-- TEMP Table

DROP TABLE if EXISTS #Percent_calc_vaccines
Create TABLE #Percent_calc_vaccines
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccine NUMERIC,
Rolling_vaccine_count NUMERIC
)
Insert into #Percent_calc_vaccines
select pd.continent, pd.location, pd.date, pd.population, pv.new_vaccinations,
SUM(CONVERT(int,pv.new_vaccinations)) OVER (partition by pd.location order by pd.location,pd.date) as vaccines_each_day
from Portfolio.CovidDeaths pd
JOIN Portfolio.CovidVaccinations pv
on pd.[location]=pv.[location]
and pd.[date]=pv.[date]
where pd.continent IS NOT NULL;
--order by 2,3  

select *,(Rolling_vaccine_count/Population)*100 as Vaccines_percent_each_day from #Percent_calc_vaccines order by 2,3  


-- Creating View

CREATE VIEW death_percent_view AS
Select location, population,max(total_deaths) Highest_death_count,Max((total_deaths/population))*100 as Highest_percent_death from Portfolio.CovidDeaths
--where [location] = 'India'
where continent is NULL
and population is NOT NULL
group by location,population
--order by 3 DESC;

select * from death_percent_view;