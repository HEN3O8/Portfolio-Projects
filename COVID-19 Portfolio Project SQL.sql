SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY Location, Date


--Covid Vaccinations

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY Location, Date


SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location, Date


-- Total Cases vs Total Deaths per location
-- Death Percentage is percentage chance of contracting Covid-19


SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS [Death Percentage]
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%vietnam%' AND continent IS NOT NULL
ORDER BY Location, Date


-- Total Cases vs Population 
-- Represents the percentage of population with Covid-19 


SELECT Location, Date, Population, total_cases, (total_cases/population)*100 AS [Covid-19 Percentage]
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%' AND continent IS NOT NULL
ORDER BY Location, Date


-- Countries with highest infection rate compared to population 


SELECT Location, Population, MAX(total_cases) AS [Highest Infection Count], MAX((total_cases/population))*100 AS [Population Infected Percentage]
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%' AND continent IS NOT NULL
GROUP BY Location, Population
ORDER BY [Population Infected Percentage] DESC


-- Countries with highest death count per population


SELECT Location, MAX(CAST(total_deaths AS INT)) AS [Total Death Count]
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY [Total Death Count] DESC


-- Continents with the highest death count per population 


-- (correct numbers)

--SELECT Location, MAX(cast(total_deaths AS int)) AS [Total Death Count]
--FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%states%' 
--WHERE continent IS NULL
--GROUP BY Location
--ORDER BY [Total Death Count] DESC

-- Data by Continent 
-- Numbers from dataset are not accurately computed for continents (ex: North America does not include numeric data from Canada)
-- Better suited for Tableau usage

SELECT continent, MAX(CAST(total_deaths AS INT)) AS [Total Death Count]
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY [Total Death Count] DESC


-- Global Numbers


SELECT Date, SUM(new_cases) AS [Total Cases], SUM(CAST(new_deaths AS INT)) AS [Total Deaths], (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS [Death Percentage]
FROM PortfolioProject..CovidDeaths
-- WHERE Location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

-- Total Cases, Total Deaths, Death Percentage Globally Summed

SELECT SUM(new_cases) AS [Total Cases], SUM(CAST(new_deaths AS INT)) AS [Total Deaths], (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS [Death Percentage]
FROM PortfolioProject..CovidDeaths
-- WHERE Location LIKE '%states%' 
WHERE continent IS NOT NULL
--GROUP BY Date
ORDER BY 1,2


-- Total Population vs Vaccinations


SELECT cd.continent, cd.Location, cd.Date, cd.Population, cvac.new_vaccinations AS [New Vaccinations], SUM(CONVERT(INT, cvac.new_vaccinations)) 
OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.Date) AS [Rolling People Vaccinated] --,([Rolling People Vaccinated]/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cvac
	ON cd.Location = cvac.Location 
	AND cd.Date = cvac.Date 
WHERE cd.continent IS NOT NULL
ORDER BY cd.Location, cd.Date


-- USE CTE


WITH PopvsVac (continent, Location, Date, Population, new_vaccinations, [Rolling People Vaccinated])
AS
(
SELECT cd.continent, cd.Location, cd.Date, cd.Population, cvac.new_vaccinations AS [New Vaccinations], SUM(CONVERT(INT, cvac.new_vaccinations)) 
OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.Date) AS [Rolling People Vaccinated] --,([Rolling People Vaccinated]/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cvac
	ON cd.Location = cvac.Location 
	AND cd.Date = cvac.Date 
WHERE cd.continent IS NOT NULL
-- ORDER BY cd.Location, cd.Date
)
SELECT *, ([Rolling People Vaccinated]/Population)*100 
FROM PopvsVac


-- TEMP TABLE


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
[Rolling People Vaccinated] numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.Location, cd.Date, cd.Population, cvac.new_vaccinations AS [New Vaccinations], SUM(CONVERT(INT, cvac.new_vaccinations)) 
OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.Date) AS [Rolling People Vaccinated] --,([Rolling People Vaccinated]/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cvac
	ON cd.Location = cvac.Location 
	AND cd.Date = cvac.Date 
WHERE cd.continent IS NOT NULL
-- ORDER BY cd.Location, cd.Date

SELECT *, ([Rolling People Vaccinated]/Population)*100 
FROM #PercentPopulationVaccinated 


-- CREATE VIEW to store data for visualization


-- 1) Percent of population vaccinated 

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.Location, cd.Date, cd.Population, cvac.new_vaccinations AS [New Vaccinations], SUM(CONVERT(INT, cvac.new_vaccinations)) 
OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.Date) AS [Rolling People Vaccinated] --,([Rolling People Vaccinated]/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cvac
	ON cd.Location = cvac.Location 
	AND cd.Date = cvac.Date 
WHERE cd.continent IS NOT NULL
-- ORDER BY cd.Location, cd.Date

-- 2) Total death count per country/location

USE PortfolioProject
GO
CREATE VIEW TotalDeathCountPerCountry AS
SELECT Location, MAX(CAST(total_deaths AS INT)) AS [Total Death Count]
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY Location
--ORDER BY [Total Death Count] DESC

