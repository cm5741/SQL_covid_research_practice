-- Shows likelihood of dying if you contract covid in your country
SELECT Location,date,total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_rate
FROM practice..CovidDeaths 
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Total cases vs Population
SELECT Location,date,total_cases, Population, (total_cases / Population)*100 AS infected_rate
FROM practice..CovidDeaths 
--WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Countries that have the highest infection rate vs Population
SELECT Location,MAX(total_cases) as highest_infection_count, Population, MAX((total_cases / Population))*100 AS percent_population_infected
FROM practice..CovidDeaths
GROUP BY Location, Population
ORDER BY percent_population_infected DESC

--Countries that have the highest Death Count per Population
SELECT Location,MAX(total_deaths) as Total__Death_Count
FROM practice..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total__Death_Count DESC

 --Continent Total mortal count
SELECT continent ,MAX(total_deaths) AS Total_Death_Count
FROM practice..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY Total_Death_Count DESC;

--Total Death Rate
SELECT SUM(total_deaths) AS Total_Death, SUM(total_cases) AS Total_Case, SUM(total_deaths)/SUM(total_cases)*100 AS Total_death_rate
FROM practice..CovidDeaths

--newly vaccination by day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations)OVER
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS total_newly_vacc
FROM practice..CovidDeaths dea 
JOIN practice..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 ;

--Use CTE(Common Table Expression) for the alias using PARTITION BY)
WITH PopsVac(continent, date,location,population,new_vaccinations,total_newly_vacc)
AS(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations)OVER
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS total_newly_vacc
FROM practice..CovidDeaths dea 
JOIN practice..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL)
SELECT *,(total_newly_vacc/population)*100 AS new_vacc_rate FROM PopsVac;

--Temp Table for the alias using PARTITION BY
DROP TABLE IF EXISTS temp_PopsVac
CREATE TABLE temp_PopsVac
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
total_newly_vacc numeric
)
INSERT INTO temp_PopsVac 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations)OVER
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS total_newly_vacc
FROM practice..CovidDeaths dea 
JOIN practice..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
SELECT *,(total_newly_vacc/population)*100 AS new_vacc_rate FROM temp_PopsVac 

-- Create VIEWs for later visualization use
CREATE VIEW  view_PopsVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations)OVER
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS total_newly_vacc
FROM practice..CovidDeaths dea 
JOIN practice..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;