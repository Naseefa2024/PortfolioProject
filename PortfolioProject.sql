select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..['covid deaths$']
order by 1,2


--select *
--from [Portfolio Project]..['covid vaccinations$']
--order by 3,4


--looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage

From [Portfolio Project]..['covid deaths$']
where location like 'India'

order by 1,2

--looking at total cases vs population
Select location, date, population, total_cases,  (total_cases/population) * 100 as percentpopulationinfected

From [Portfolio Project]..['covid deaths$']

where location like '%states'
order by 1,2


--countries with highest infection rate

Select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)) * 100 as percentpopulationinfected

From [Portfolio Project]..['covid deaths$']

--where location like '%states'
group by population, location
order by percentpopulationinfected desc

select location, MAX(cast(Total_Deaths as int)) as	TotalDeathCount
From [Portfolio Project]..['covid deaths$']
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things by continent

select continent, MAX(cast(Total_Deaths as int)) as	TotalDeathCount
From [Portfolio Project]..['covid deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc


select location, MAX(cast(Total_Deaths as int)) as	TotalDeathCount
From [Portfolio Project]..['covid deaths$']
where continent is null
group by location
order by TotalDeathCount desc


--showing continents with the highest death count

select continent, MAX(cast(Total_Deaths as int)) as	TotalDeathCount
From [Portfolio Project]..['covid deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases)as total_cases, SUM(new_deaths)as total_deaths, SUM(new_Deaths)/SUM(new_cases)*100 as Deathpercentage
From [Portfolio Project]..['covid deaths$']
--where location like 'India'
--where continent is not null
--group by date
order by 1,2

--Looking at Total population vs Total Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations AS bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths$'] dea
join [Portfolio Project]..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE
with popvsvac ( continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations AS bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths$'] dea
join [Portfolio Project]..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--TEMP TABLE
Drop table if exists #percentpopulationvaccinated
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #PERCENTPOPULATIONVACCINATED
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations AS bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths$'] dea
join [Portfolio Project]..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PERCENTPOPULATIONVACCINATED

--creating view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations AS bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid deaths$'] dea
join [Portfolio Project]..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

select *
from percentpopulationvaccinated