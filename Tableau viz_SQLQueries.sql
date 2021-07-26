--1. Total DeathPercentage - global
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
where continent is not null 
--Group By date
order by 1,2

--2. Continent-wise DeathPercentage - excluding 'world', 'EU' and 'International to remove ambiguity
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3. country-wise Infected counts and Percentage of population infected
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
Group by Location, Population
order by PercentPopulationInfected desc

--4. 
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths$
--Where location like 'India'
Group by Location, Population, date
order by PercentPopulationInfected desc