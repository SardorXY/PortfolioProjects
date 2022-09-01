SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
Order By 3,4
-- Select data that we are goin to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 1,2

-- Exploring percentage of th death, Total deaths versus Total cases
-- Shows Likelihodd of dying if someone contracts covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deahthPersentage
FROM PortfolioProject..CovidDeaths
WHERE location Like '%Uzbekistan%' and continent is not null
Order By 1,2

-- Loking at Cases versus Population
-- Shows how many persentage of population got Covid
SELECT location, date,population, total_cases,(total_cases/population)*100 as CasePersentage
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%Uzbekistan%' 
Order By 1,2

-- Looking at Countries which has highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS MaxCase, MAX(total_cases/population)*100 as
	MaxCasePersentage
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%Uzbekistan%' 
Group By location, population
Order By 4 DESC

-- Countries which has highest death cases per population
SELECT location,population, MAX(CAST(total_deaths AS int)) AS Maxdeath, MAX((cast(total_deaths as int))/population)*100 as MaxPersentageDeath 
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%Uzbekistan%'
WHERE continent is not null
Group By location, population
Order By Maxdeath DESC

-- Exploring highest death cases by contitents
SELECT continent, MAX(CAST(total_deaths AS int)) AS Maxdeath, MAX((cast(total_deaths as int))/population)*100 as MaxPersentageDeath 
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%Uzbekistan%'
WHERE continent is not null
Group By continent
Order By Maxdeath DESC

-- Global numbers

SELECT SUM(cast(new_cases as int)) as CaseSum, SUM(cast(new_deaths as int)) AS DeathSum, SUM(cast(new_deaths as int))/SUM(new_cases )*100
	as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%Uzbekistan%'
WHERE continent is not null
--Group By date
Order By 1,2 DESC

-- Exploring total population versus vaccination

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order By a.location,
a.Date) as RolPeopleVaccinated 
--(RolPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
WHERE a.continent is not null
--and  dea.location Like '%Uzbekistan%'
--Order By 2,3


-- USE CTE for Exploring vaccinated population
WITH VacPopulation (Continent, location, date, population, new_vaccinations, RolPeopleVaccinated)
AS
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order By a.location,
a.Date) as RolPeopleVaccinated 
--(RolPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
WHERE a.continent is not null
)

SELECT *,  (RolPeopleVaccinated/population)*100 as VacPerPop
FROM VacPopulation

-- Temp Table
DROP TABLE if exists #VaccinationPerPopulation
CREATE TABLE #VaccinationPerPopulation
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RolPeopleVaccinated numeric,
)

INSERT INTO #VaccinationPerPopulation
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order By a.location,
a.Date) as RolPeopleVaccinated 
--(RolPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
--WHERE a.continent is not null

SELECT*, (RolPeopleVaccinated/population)*100
FROM #VaccinationPerPopulation

-- Creating view for vizualization

Create View PerPopulationVaccination as 
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order By a.location,
a.Date) as RolPeopleVaccinated 
--(RolPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	on a.location = b.location
	and a.date = b.date
WHERE a.continent is not null

SELECT *
FROM PerPopulationVaccination











