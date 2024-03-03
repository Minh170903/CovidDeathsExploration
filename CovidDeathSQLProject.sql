Select*
From PortfolioProject..CovidDeaths$
order by 3,4;

--Select*
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Total cases vs total deaths
-- Likelihood of dying if get infected in Australia
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location Like '%australia%'
order by 1,2

-- Total cases vs population
-- Percentage that got covid
Select Location, date, total_cases, population,(total_cases/population)*100 as PercentPopulation
From PortfolioProject..CovidDeaths$
Where location Like '%australia%'
order by 1,2

-- COuntry with highest infection rate
Select Location, population, MAX(total_cases) as HighestInfection, Max((total_cases/population))*100 as
PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location Like '%australia%'
Group by population, location
order by PercentPopulationInfected desc


-- countries with highes death count per population

Select Location, MAX(cast(total_deaths as INT)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
--Where location Like '%australia%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Break things down by continent
-- Showing the continent with the highest death count

Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
--Where location Like '%australia%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
Select date, SUM(new_cases) as totalCases, sum(cast(new_deaths as INT)) 
as totaldeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location Like '%australia%'
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccination



-- Using CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER(Partition by dea.Location Order by dea.location
,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVacinated/Population)*100
From PopvsVac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER(Partition by dea.Location Order by dea.location
,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for visualisation
Create View PercentVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER(Partition by dea.Location Order by dea.location
,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
from PercentVaccinated