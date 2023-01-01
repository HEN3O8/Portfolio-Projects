/*

Queries for Tableau using COVID-19 Project dataset

*/


--1) 


SELECT SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY state
ORDER BY 'Total Cases', 'Total Deaths'


--2)
-- We take these out as they are not included in the above queries and want to stay consistent
-- Eurpoean Union is part of Europe


SELECT Location, SUM(CAST(new_deaths AS INT)) AS 'Total Death Count'
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NULL
AND Location NOT IN ('World', 'European Union', 'International')
GROUP BY Location
ORDER BY 'Total Death Count' DESC


--3)


SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--4)


SELECT Location, Population, Date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC