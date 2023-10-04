-- Random Data check

--SELECT COUNT(*)
--FROM CovidDeaths;

--SELECT COUNT(*)
--FROM CovidVaccinations;

--SELECT * 
--FROM CovidDeaths
--ORDER BY 3,4;

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4;

-- Select: data that are going to use
SELECT 
	location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2;

-- Total Cases VS Total Deaths
-- Shows rough estimate of dying if you gete covid in your country - SRI LANKA
SELECT 
	location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE location like '%Lanka%'
ORDER BY 1,2;

-- Total Cases VS Population
-- Shows what precentage of population got Covid
SELECT 
	location, date, population, total_cases, 
	(total_cases/population)*100 AS InfectedPercentagePerPop
FROM CovidDeaths
WHERE location like '%Lanka%'
ORDER BY 1,2;

-- Countries with highest infection rate compared to Population
SELECT 
	location, population, MAX(total_cases) as MaxInfectionCount,
	(MAX(total_cases)/population)*100 as MaxCasesPerPop
FROM CovidDeaths
GROUP BY location, population
ORDER BY MaxCasesPerPop DESC;

-- Countries with highest death count
SELECT 
	location, MAX(cast(total_deaths AS INT)) as MaxDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeathCount DESC;

-- Break in to Continent:

-- Continent with highest death count
SELECT 
	continent, MAX(cast(total_deaths AS INT)) as MaxDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeathCount DESC;

-- Global Nubers
-- Death precentage by date
SELECT 
	date, SUM(new_cases) AS TotCases,
	SUM(CAST(new_deaths AS INT)) AS TotDeaths,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPrecentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Death precentage all over the WORLD
SELECT 
	SUM(new_cases) AS TotCases,
	SUM(CAST(new_deaths AS INT)) AS TotDeaths,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPrecentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- ---------------------------------------------------
SELECT *
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date;

-- Total vaccination VS Population

SELECT 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- CTE

WITH CovidVaccPop (Continent, Location, Date, Population, New_vaccinations, VaccinatedRollingSum)
AS
(SELECT 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinatedRollingSum
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL)

--SELECT * 
--FROM CovidVaccPop;

Select *, (VaccinatedRollingSum/Population)*100 AS VaccinatedRollingSumPrecentage
From CovidVaccPop;

--  TEMP Table

DROP Table if exists #Temp_CovidVaccPop;
Create Table #Temp_CovidVaccPop
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	VaccinatedRollingSum numeric
);

Insert into #Temp_CovidVaccPop
SELECT 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinatedRollingSum
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location
	AND cd.date = cv.date;

Select *, (VaccinatedRollingSum/Population)*100 AS VaccinatedRollingSumPrecentage
From #Temp_CovidVaccPop;


-- Creating View

CREATE VIEW View_CovidVaccPop AS 
SELECT 
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VaccinatedRollingSum
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

Select *
From View_CovidVaccPop;
