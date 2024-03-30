-- Total cases vs Total deathes, DeathPercentage in China
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM covid_deaths
WHERE location = 'China'
ORDER BY 1, 2

-- Total cases vs population_density, InfectionRate in China
SELECT location, date, total_cases, population, (total_deaths/total_cases) * 100 as InfectionRate
FROM covid_deaths
WHERE location = 'China'
ORDER BY 1, 2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population
SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)) * 100 as PercentPopulationDeath
FROM covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationDeath DESC

-- break things down by continent, continent with the highest death conut
SELECT continent, MAX(total_deaths) as HighestDeathCount
FROM covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- continets with highest death count per population
SELECT continent, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)) * 100 as PercentPopulationDeath
FROM covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentPopulationDeath DESC

-- GLOBAL numbers 
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
from covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2  DESC

-- Total population vs new_vaccinations
SELECT cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
-- 	(RollingPeopleVaccinated/population) * 100
FROM covid_deaths cd
JOIN covid_vaccinations cv 
	ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not NULL
ORDER BY 2,3

--USE cte
with PopvsVac (Continent, Location,Date, Population, NewVaccinations,RollingPeopleVaccinated)
as 
(
SELECT cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
-- 	(RollingPeopleVaccinated/population) * 100
FROM covid_deaths cd
JOIN covid_vaccinations cv 
	ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not NULL
ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population) * 100
FROM PopvsVac

-- CREATE table
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent NVARCHAR(225),
Location NVARCHAR(225),
Date DATETIME, 
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated BIGINT
);
INSERT INTO PercentPopulationVaccinated
SELECT cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
-- 	(RollingPeopleVaccinated/population) * 100
FROM covid_deaths cd
JOIN covid_vaccinations cv 
	ON cd.location = cv.location and cd.date = cv.date;
-- WHERE cd.continent is not NULL
-- ORDER BY 2,3
SELECT *,(RollingPeopleVaccinated/population) * 100
FROM PercentPopulationVaccinated


-- CREATE VIEW TO STORE DATA FOR VISUALIZATION
DROP VIEW IF EXISTS PercentPopulationVaccinatedView;
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
-- 	(RollingPeopleVaccinated/population) * 100
FROM covid_deaths cd
JOIN covid_vaccinations cv 
	ON cd.location = cv.location and cd.date = cv.date;
WHERE cd.continent is not NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinatedView




