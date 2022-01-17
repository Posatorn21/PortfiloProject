Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..Vaccinations
--Order by 3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where Location like '%Thai%'
and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where Location like '%Thai%'
Where continent is not null
Order by 1,2

-- Looking at Contries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where Location like '%Thai%'
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%Thai%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Showing Continents with Highest death per Population
-- LET'S BREAK THINGS DOWN BY CONTINENT 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%Thai%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Number
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where Location like '%Thai%'
Where continent is not null
Order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store date for later visualization
Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated2