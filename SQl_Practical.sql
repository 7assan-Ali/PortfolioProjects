select *
from CovidDeaths



select location ,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 6

update CovidDeaths
set new_cases=0
where total_deaths is null

--looking at total cases vs total deabth
-- sheets likelihood of dying if you contract in your country
select location ,date,total_cases,total_deaths,  (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT),0))*100 as deabth_percentage
from CovidDeaths
where location like'%Egypt%'
order by 3


-- looking at total cases vs Population
-- Sheets what percentage og population got covid
select location ,date,total_cases,population, max(CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT),0))*100 as deabth_percentage
from CovidDeaths
where location like'%Egypt%'
order by 1,2

--looking at countries with highest rate compared to population
select location ,population,MAX(total_cases) as highestinfectioncount ,max(CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT),0))*100 as Percentagepopulationinfected
from CovidDeaths
--where location like'%Egypt%'
group by location, population
order by Percentagepopulationinfected desc


-- showing countries with highest deabth count per population
select location,MAX(cast(total_deaths as int)) as TotalDeabthcount
from CovidDeaths
group by location
order by TotalDeabthcount desc

--let's break things down by continent
select continent,MAX(cast(total_deaths as int)) as TotalDeabthcount
from CovidDeaths
where continent is not null  --not display null value
group by continent
order by TotalDeabthcount desc

select location,MAX(cast(total_deaths as int)) as TotalDeabthcount
from CovidDeaths
where continent is null  --not display null value
group by location
order by TotalDeabthcount desc


--showing contintents with the highest deabth count per population
select location,MAX(cast(total_deaths as int)) as TotalDeabthcount
from CovidDeaths
where continent is not null  --not display null value
group by location
order by TotalDeabthcount desc


-- GLOBAL NUMBERS

SELECT 
    SUM(CAST(new_cases AS INT)) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(CAST(new_cases AS INT)),0) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

--select 
--		sum(new_cases)as total_cases
--		,sum(cast(new_deaths as int))as total_deaths
--		,sum(cast(new_deaths as int))
--		/NULLIF(sum(cast(new_cases as int)),0)*100
--		as DeathsPercentage
--from CovidDeaths
--where continent is not null

select date,sum(CAST(new_cases as int)) WorldRatingDays,sum(CAST(new_deaths as int)) WorldRatingDaysdeaths,sum(cast(new_deaths as float))/SUM(cast(new_cases  as float))*100 as percentagerating --,total_deaths,  (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT),0))*100 as deabth_percentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2


--day rating
select date,sum(CAST(total_cases as int)) WorldRatingDays
		,sum(CAST(new_deaths as float)) WorldRatingDaysdeaths
		,sum(cast(new_deaths as float))/SUM(cast(new_cases  as int))*100 as percentagerating 
		--,total_deaths,  (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT),0))*100 as deabth_percentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2


----------------------------------------------------
SELECT    *
  FROM [PortifolioProject].[dbo].[CovidVaccinations] as vac
----------------------------------------------------
--looking at population vs vaccinations
select dea.continent,dea.location,
		dea.date,dea.population,
		vac.new_vaccinations,sum(cast (vac.new_vaccinations as int))
		over (partition by dea.location,dea.date) 
		as RollingPeopleVaccinations
from PortifolioProject..CovidDeaths dea
join [PortifolioProject].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3


---------USE CTE
with PopVsVac (
	continent,location,date,
	population,new_vaccinations,RollingPeopleVaccinations 
)
as (
  
select dea.continent,dea.location,
		dea.date,dea.population,
		vac.new_vaccinations,sum(cast (vac.new_vaccinations as int))
		over (partition by dea.location,dea.date) 
		as RollingPeopleVaccinations
from PortifolioProject..CovidDeaths dea
join [PortifolioProject].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3

) 
select *,(RollingPeopleVaccinations/population)*100 as persent
from PopVsVac

-----temp table

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinations numeric

)

insert into #percentPopulationVaccinated  
select dea.continent,dea.location,
		dea.date,dea.population,
		vac.new_vaccinations,sum(cast (vac.new_vaccinations as int))
		over (partition by dea.location,dea.date) 
		as RollingPeopleVaccinations
from PortifolioProject..CovidDeaths dea
join [PortifolioProject].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date=vac.date
--where dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccinations/population)*100 as persent
from #percentPopulationVaccinated


--create view to store data for later visuallizations
CREATE OR ALTER VIEW percentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    TRY_CAST(vac.new_vaccinations AS INT) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS INT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date 
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select *
from percentPopulationVaccinated
