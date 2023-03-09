Select *
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project].dbo.CovidVaccinations
--order by 3,4

-- Select the data I am going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project].dbo.CovidDeaths
order by 1,2
--Looking at the total cases vs total deaths
--Demonstrating the chance or probability of dying if one is infected by COVID
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatio
From [Portfolio Project].dbo.CovidDeaths
Where location like 'Afghanistan'
order by 1,2

--Now we look at the total cases vs Population
-- Shows what percentage of population of covid
Select Location, date, population, total_cases, (total_cases/population)*100 as COVIDPercentage
From [Portfolio Project].dbo.CovidDeaths
Where location like 'Afghanistan'
order by 1,2

-- Looking at countries with largest infection rate compared to population
	Select Location, population, MAX(total_cases) as highestinfectedcountry, MAX((total_cases/population))*100 as COVIDPercentage	
	From [Portfolio Project].dbo.CovidDeaths
	Group by Location, population
	order by COVIDPercentage desc

-- Now, I show the countries with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group by continent
order by totaldeathcount desc	

--We can do that for location like this
Select location, MAX(cast(total_deaths as int)) as totaldeathcount
From [Portfolio Project].dbo.CovidDeaths
Where continent is null
Group by location
order by totaldeathcount desc
--Showing continent with the highest death counts per population
Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
From [Portfolio Project].dbo.CovidDeaths
Where continent is null
Group by continent
order by totaldeathcount desc

-- Now, I will check the figures and analysis for the entire globe
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathRatio --total_deaths	, (total_deaths/total_cases)*100 as DeathRatio
	From [Portfolio Project].dbo.CovidDeaths
	--Where location like 'Afghanistan'
	where continent is not null
	-- Group by date
	order by 1,2

-- Looking at the Total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP Table

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
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
USE [Portfolio Project]
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
FROM PercentPopulationVaccinated

