Covid 19 Data Exploration 

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths,
--Shows likelihood of dying if you contract covid in your country

Select cast(total_deaths AS INT)
From PortfolioProject..CovidDeaths

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths float
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_cases float

Select Location, date, total_cases,total_deaths,case when total_cases=0 then 0 else round((total_deaths/total_cases)*100,2) end as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Egypt%'
and continent is not null 
order by 1,2

SELECT Location, Date, Total_Cases, Total_Deaths, 
       (CASE WHEN Total_Cases = 0 THEN 0 
             ELSE round((Total_Deaths/Total_Cases)*100,2) 
        END) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%' AND Continent IS NOT NULL 
ORDER BY Location, Date;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN population float
Select Location, date, Population, total_cases, case when population=0 then 0 else(total_cases/population)*100 end as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Egypt%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population,MAX(total_cases) as HighestInfectionCount,Population,case when population=0 then 0 else Max(total_cases)/population*100 end as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

SELECT TOP(20) Location, Population, MAX(total_cases) as HighestInfectionCount,
       CASE WHEN Population = 0 THEN 0 
            ELSE MAX(total_cases) / Population * 100 
       END AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(cast(new_cases as int)) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- GLOBAL NUMBERS

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,case when population=0 then 0 else(RollingPeopleVaccinated/population)*100 end
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, case when population=0 then 0 else (RollingPeopleVaccinated/Population)*100 end
From PopvsVac
