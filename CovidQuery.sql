Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select data that we need

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of death if you have covid in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where Location like 'Kenya'
Order by 1,2

--Total Cases vs Population
--Shows % of population that has covid

Select Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%States'
Order by 1,2

--Compares highest infection rate against population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%States'
Group by Population,location
Order by PercentPopulationInfected desc

--Highest death count against population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%States'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Break by continent
--Continent with Highest death count per population

/*Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%States'
Where continent is null
Group by location
Order by TotalDeathCount desc*/

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%States'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where Location like 'Kenya'
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where Location like 'Kenya'
Where continent is not null
--Group by date
Order by 1,2

--Total Pop vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)
From #PercentPopulationVaccinated

--Creating view to store data for visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated