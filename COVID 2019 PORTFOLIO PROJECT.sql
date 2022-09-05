
select*
From PortfolioProject..covidDeaths
Where continent is not null
order by 3,4

--select*
--From PortfolioProject..covidVaccination
--order by 3,4

-- Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeaths
Where continent is not null
order by 1,2

-- Look at total cases vs total deaths
-- show how likely you will die when affected in Niger

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
Where location like '%Niger%'
and continent is not null
order by 1,2


--Looking at Total cases vs Population
--show what percentage of population got covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
From PortfolioProject..covidDeaths
Where location like '%Niger%'
order by 1,2


--look at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covidDeaths
--Where location like '%states%'
Group by continent, population
order by PercentPopulationInfected desc


-- countries with the highest death count per population

Select Location, Max(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by Totaldeathcount desc

--Break things down by contient

Select continent , Max(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is null
Group by continent
order by Totaldeathcount desc


-- continent with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by Totaldeathcount desc


-- Global numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
--Where location like '%Niger%'
where continent is not null
Group by date
order by 1,2


-- total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use cte

with popvsVac (Continent,Location, Date , Population, New_Vaccinations,  RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select* , (RollingPeopleVaccinated/population)*100
From popvsVac

-- Temp table

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime
Population numeric
New_vaccinations numeric
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


select* , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select*
From #PercentPopulationVaccinated