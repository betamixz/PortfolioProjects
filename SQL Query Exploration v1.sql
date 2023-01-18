Select * 
From PortfolioProject..Covid_Deaths
Where continent IS NOT NULL
order by 3,4

--Select * 
--From PortfolioProject..Covid_Vaccinations
--order by 3,4

-- Select Data to be used

Select location, date,total_cases,new_cases,total_deaths,population
From PortfolioProject..Covid_Deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from COVID in Indonesia
Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..Covid_Deaths
Where location like 'Indonesia' and continent IS NOT NULL
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
Select location, date, population, total_cases, (total_cases/population)*100 as Pops_Percentage_Infected
From PortfolioProject..Covid_Deaths
Where location like 'Indonesia' and continent IS NOT NULL
order by 1,2


-- Looking at countries with highest infection rate compared to Pops
Select location, population, max(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as Pops_Percentage_Infected
From PortfolioProject..Covid_Deaths
-- Where location like 'Indonesia'
Where continent IS NOT NULL
Group by location, population
order by Pops_Percentage_Infected desc

-- Showing Countries with Highest Death Count per Pops
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
-- Where location like 'Indonesia'
Where continent IS NOT NULL
Group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT	

-- Showing continents with highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
-- Where location like 'Indonesia'
Where continent IS NULL
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..Covid_Deaths
-- Where location like 'Indonesia' 
Where continent IS NOT NULL
Group by date
order by 1,2

-- Total Global Cases/Deaths/DeathPercentage
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..Covid_Deaths
-- Where location like 'Indonesia' 
Where continent IS NOT NULL
--Group by date
order by 1,2

--Select * 
--FROM PortfolioProject..Covid_Deaths dea
--Join PortfolioProject..Covid_Vaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date

-- Looking at Total Pops vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopsVacc
	-- , (RollingPopsVacc/population) * 100
FROM PortfolioProject..Covid_Deaths dea
Join  PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- using CTE

WITH PopvsVacc (Continent, Location, Date, Population, New_vaccinations, RollingPopsVacc)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopsVacc
	-- , (RollingPopsVacc/population) * 100
FROM PortfolioProject..Covid_Deaths dea
Join  PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPopsVacc/Population) * 100
FROM PopvsVacc

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopsVacc
CREATE TABLE #PercentPopsVacc
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPopsVacc numeric
) 

INSERT INTO #PercentPopsVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopsVacc
	-- , (RollingPopsVacc/population) * 100
FROM PortfolioProject..Covid_Deaths dea
Join  PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPopsVacc/Population) * 100
FROM #PercentPopsVacc


-- Create View to Store Data for Visualization
USE PortfolioProject
GO
Create View PercentPopsVacc as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopsVacc
	-- , (RollingPopsVacc/population) * 100
FROM PortfolioProject..Covid_Deaths dea
Join  PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 -- ORDER BY 2,3

 Select * 
 From PercentPopsVacc
