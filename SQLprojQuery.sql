Select * from PortfolioProject..CovidDeaths
where continent is not null
order By 3,4

Select * from PortfolioProject..CovidVaccinations
order By 3,4

--Select Data that we are going to be using

--Select location, date, total_cases, new_cases, total_deaths, population 
--from PortfolioProject..CovidDeaths
--where continent is not null
--order By 1,2

---- Looking at Total case vs Total Deaths
-- Shows what percentage of population got covid

--Select location, date, total_cases, population, new_cases, total_deaths, cast(ROUND((total_cases/population)*100,3) AS float) as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--and continent is not null
--order By 1,2

----Looking at country with Highest Infection Rate compared to population

--Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where continent is not null
--Group by location, population 
--order by DeathPercentage desc

----Countries with Highest Death count per Population

  

---- LET'S BREAK THINKS DOWN BY CONTINENTS


----Showing the continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
--Death Percentage accross the world 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2

--Total Cases and death percentage accross the World
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group By date
order by 1,2


--Locking fot total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- Here we want to Use RollingPeopleVaccinated and then we have to divide it by population simply we cannot do it we'll use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE

with popvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- Here we want to Use RollingPeopleVaccinated and then we have to divide it by population simply we cannot do it we'll use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from popvsVac 


--Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- Here we want to Use RollingPeopleVaccinated and then we have to divide it by population simply we cannot do it we'll use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated


--Creating view to store data for later Visualization

DROP VIEW IF EXISTS PercentPopulationVaccinated;
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- Here we want to Use RollingPeopleVaccinated and then we have to divide it by population simply we cannot do it we'll use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Go

Select * From PercentPopulationVaccinated