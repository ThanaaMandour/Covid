SELECT *
FROM coviddeaths.coviddeaths
LIMIT 10;


-- total cases vs population
SELECT location, date, total_cases, 
population, (total_cases/population)*100 AS percentage_of_cases
FROM coviddeaths.coviddeaths
WHERE location LIKE '%Egypt%';



-- what the country have the highest infiction rate
SELECT location,population, max(total_cases) AS highest_infiction
FROM coviddeaths.coviddeaths
group by 1,2
order by highest_infiction desc;


-- what the country have the highest death rate
SELECT location,max(cast(total_deaths as UNSIGNED)) AS highest_death
FROM coviddeaths.coviddeaths
group by 1
order by highest_death desc;


SELECT continent,max(cast(total_deaths as UNSIGNED)) AS highest_death
FROM coviddeaths.coviddeaths
group by 1
order by highest_death desc;

SELECT str_to_date(date, '%m/%d/%y') as date,SUM(new_cases),
 SUM(CAST(new_deaths AS UNSIGNED))
FROM coviddeaths.coviddeaths
GROUP BY 1;


SELECT str_to_date(date, '%m/%d/%y') as date,SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths,SUM(new_cases) AS total_cases,
(SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases))*100 AS percentage_of_new_deaths
FROM coviddeaths.coviddeaths
GROUP BY 1
ORDER BY 1;



-- let's work on covidvaccinations

 SELECT *
 FROM coviddeaths.covidvaccinations;
 
 
 
-- looking at total population vs vaccination 

SELECT death.location, population,death.continent, 
death.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
	OVER (PARTITION BY death.location
    ORDER BY death.location,death.date) AS vacs_by_location
FROM coviddeaths.coviddeaths AS death
JOIN coviddeaths.covidvaccinations AS vac
	ON death.location = vac.location 
	AND death.date = vac.date
ORDER BY vacs_by_location desc;

WITH popvsvac (date, continent, location, population, new_vaccinations, vacs_by_location)
as
(
SELECT death.date, death.continent, death.location, population, 
 vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
	OVER (PARTITION BY death.location
    ORDER BY death.location,death.date) AS vacs_by_location
FROM coviddeaths.coviddeaths AS death
JOIN coviddeaths.covidvaccinations AS vac
	ON death.location = vac.location 
	AND death.date = vac.date
)
    
SELECT *, (vacs_by_location/population)*100
FROM popvsvac;




use coviddeaths;
CREATE TABLE percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population float8,
new_vaccinations float8,
vacs_by_location float8
);

INSERT INTO percentpopulationvaccinated
SELECT cast(death.date as date), death.continent, death.location, population, 
 vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float8)) 
	OVER (PARTITION BY death.location
    ORDER BY death.location,death.date) AS vacs_by_location
FROM coviddeaths.coviddeaths AS death
JOIN coviddeaths.covidvaccinations AS vac
	ON death.location = vac.location 
	AND death.date = vac.date;

SELECT *, (vacs_by_location/population)*100
FROM percentpopulationvaccinated;






