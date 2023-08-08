-- My Portfolio Project

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that I will be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- This doesn't run at first, so I had to change the data type from nvarchar to float

EXEC sp_help 'PortfolioProject..CovidDeaths'

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases Float
             
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths Float

-- Now, run it again
-- This shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- This shows percentage of population got covid

SELECT Location, date,Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Nigeria%'
GROUP BY Location, Population
ORDER BY 4 desc

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

-- Showing the continents with the highest death counts

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_deaths float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_cases float

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Now, remove the date column

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

ALTER TABLE PortfolioProject..CovidVaccinations
ALTER COLUMN new_vaccinations float

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
