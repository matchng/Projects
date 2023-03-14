SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

SELECT * FROM PortfolioProject..CovidVaccinations
ORDER BY location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Show the probability of mortality upon contracting COVID-19 in the United Kingdom

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY location, date;


--Looking at Total Cases vs Population
--Show the percentage of the popluation that has contracted Covid 

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- Which Countries with Top 5 highest infection rate compare to population

SELECT Top 5 location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


--Showing the countries with highest death count per population
SELECT location , MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;


-- Showing total death count of each Continent 
SELECT continent , MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Total Cases per year
SELECT Year(date) as Yr, SUM(new_cases) TotalCase
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY YEAR(date)
ORDER BY Yr;


-- Global Numbers
SELECT SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1;


-- Looking at Total Population vs Vaccinations with 1st Vaccine Dose

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
 SUM(CAST(vac.new_people_vaccinated_smoothed AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RunningTotalVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_people_vaccinated_smoothed IS NOT NULL  
ORDER BY 2,3


-- Using CTE

WITH PopvsVac ( Continent, Location, Date, Population, NewPeopleVaccinated, RunningTotalVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
 SUM(CAST(vac.new_people_vaccinated_smoothed AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RunningTotalVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT Continent , Location, Population, MAX(RunningTotalVaccinated/Population)*100 as  PercentagePeopleVaccinated
FROM PopvsVac
GROUP BY Continent, Location, Population
ORDER BY PercentagePeopleVaccinated 


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_people_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
 SUM(CAST(vac.new_people_vaccinated_smoothed AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RunningTotalVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT * FROM #PercentPopulationVaccinated;

--Create View

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
 SUM(CAST(vac.new_people_vaccinated_smoothed AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RunningTotalVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 


SELECT * 
FROM PercentPopulationVaccinated
