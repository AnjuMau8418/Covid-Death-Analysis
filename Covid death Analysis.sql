Select *
From Project1..CovidDeaths
Where continent is not null
ORDER BY 3,4

--Select *
--From Project1..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be use

Select Location, date, total_cases, new_cases, total_deaths, population
From Project1..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
From Project1..CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at the total cases Vs Population
-- shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100  as PercentPopulation
From Project1..CovidDeaths
-- Where location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfactionCount, Max((total_cases/population))*100  as PercentPopulationInfected
From Project1..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Showing the countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.Date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Order By 2, 3


--Use CTE

with PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.Date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
-- Order By 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

--DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






