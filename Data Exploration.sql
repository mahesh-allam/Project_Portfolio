select * 
From PortfolioProject..CovidDeaths
order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2;

--Total cases vs Total Deaths
--Deathpercentage
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%state%'
Order by 1,2;

--Total cases Vs Population

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%india%'
Order by 1,2;

--Highest infection rate to Population.

Select location, population, Max(total_cases) as HighestInfectioncount, Max((total_cases/population))*100 as Percentpopulationinfected
From PortfolioProject.dbo.CovidDeaths
Group by location, population
Order by Percentpopulationinfected desc;

-- HIghest death

Select location, Max(cast(total_deaths as int)) as Highestdeathcount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
Order by Highestdeathcount desc;

--Let's break continent
--Showing continents with highest death counts
Select continent as Continenet, Max(cast(total_deaths as int)) as Highestdeathcount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
Order by Highestdeathcount desc;

--Global numbers

Select Sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%state%'
where continent is not null
--group by date
Order by 1,2;

--Total population vs vaccinations
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3;

--with pop vs Vac using CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over(partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
order by 2,3



--TEMP Table

Drop table if exists #percentPopulationvaccinated
Create table #percentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationvaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #percentPopulationvaccinated
order by 2,3


--Creating view to  store data for  later visualization

Create View percentPopulationvaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null

Select * 
From percentPopulationvaccinated
