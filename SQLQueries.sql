
Select *
From PortfolioProjects..CovidDeaths$
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths$


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where location like 'India'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths$ 
Where continent is not null 
--Where location like 'India'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths$
Where location like 'India'  
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--eliminate the continent=Null entires
Select *
From PortfolioProjects..CovidDeaths$
where continent is not NULL 
order by 3,4

--showing continents with highest death counts
--Breaking things down by continents
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Numbers are not that accurate. North America seems to include only the numbers from USA.

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
Where continent is null 
Group by location
order by TotalDeathCount desc

--gives a more accurate result. (redo all queries with continents, and group by continents)

--GLOBAL STATS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2

--USING COVID VACCINATIONS

Select *
From PortfolioProjects..CovidVaccinations$
order by 3,4

--joining CovidDeaths and CovidVaccinations on location and date.

select *
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location=vac.location and dea.date = vac.date 

--looking at total population vs total vaccinations
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location=vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3

select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,

from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location=vac.location and dea.date = vac.date 
where dea.continent is not null --and vac.new_vaccinations is not null
order by 2,3

--using a CTE

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProjects..CovidDeaths$ dea
--Join PortfolioProjects..CovidVaccinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3
--)

--select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

--Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacci
from PortfolioProjects..CovidDeaths$ dea join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

--create view to visualise on tableau

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacci
from PortfolioProjects..CovidDeaths$ dea join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

