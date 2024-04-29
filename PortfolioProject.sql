
--Selecting the needed Columns

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows the liklihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
AND continent IS NOT NULL
Order By 1,2 

-- Looking at the Total cases vs Population

SELECT location, date, population, total_cases, (CAST(total_cases AS FLOAT) / population)*100 AS AffectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2 

-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/population))*100 AS AffectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
Order By AffectedPercentage DESC

-- Showing Countries with Highest Death count per population

SELECT location, MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
Order By HighestDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location <> 'World' AND location <> 'International'
GROUP BY location
Order By HighestDeathCount DESC

-- Showing Continents with Highest Death Counts per Population

SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX((CAST(total_deaths AS FLOAT)/population))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location <> 'World' AND location <> 'International'
GROUP BY location, population
Order By HighestDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)*100 AS 
DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
Order By 1,2 

-- Total Cases and Total Deaths

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)*100 AS 
DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2 

-- Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

-- USING CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT)/Population)*100 as Vaccinated_Percentage
FROM PopvsVac

-- TEMP TABLES

DROP TABLE IF EXISTS #PercentagePeopleVaccinated

CREATE TABLE #PercentagePeopleVaccinated
(
Continent varchar(50), 
Location varchar(50), 
Date datetime, 
Population bigint, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage
FROM #PercentagePeopleVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.date) as RollingPeopleVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentagePopulationVaccinated
