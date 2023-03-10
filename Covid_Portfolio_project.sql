use PortfolioPorject

select * from CovidDeaths
Order By 3,4
select * from CovidVaccinations
Order By 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


-- Looking at the total_cases vs total_deaths 
-- Shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths
where location like 'India'
order by 1,2

-- Looking at the total_cases vs population 
-- Percentage of population got Covid

select Location, date, population, total_cases,(total_cases/population) * 100 
from CovidDeaths
--where location like 'India'
order by 1,2


--- Looking at Countries with highest infection rates compared to Population

select Location, population, max(total_cases) as Highest_Infection_Count,Max((total_cases/population)) * 100
as Percentage_population_Infected
from CovidDeaths
--where location like 'India'
Group by Location, population
order by Percentage_population_Infected desc


-- Showing Countries with the Highest Death Count per Population 

select Location, Max(cast(Total_deaths as int)) as Total_Death_Count
from CovidDeaths
--where location like 'India'
where continent is not null
Group by Location
order by Total_Death_Count desc

--- Global Numbers 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage
from CovidDeaths
--where location like 'India'
where continent is not null
Group By date
order by 1,2

 
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage
from CovidDeaths
--where location like 'India'
where continent is not null
--Group By date
order by 1,2



---Looking at total population vs vaccination

select a.continent, a.location, a.date, a.population,
b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over(partition by a.location Order by a.location,a.date)
as Rolling_people_vaccincated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
where a.continent is not null
order by 2,3


--Use CTE

with popvsvac(Continent, Location, date, Population,New_vaccination,  Rolling_people_vaccincated) 
as
(
select a.continent, a.location, a.date, a.population,
b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over(partition by a.location Order by a.location,a.date)
as Rolling_people_vaccincated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
where a.continent is not null

)
select *,(Rolling_people_vaccincated/population) * 100 from popvsvac


---Temp Table 

Drop Table if exists #PercentPopuationVaccincated
Create Table #PercentPopuationVaccincated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccination numeric,
Rolling_people_vaccincated numeric
)

Insert into #PercentPopuationVaccincated
select a.continent, a.location, a.date, a.population,
b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over(partition by a.location Order by a.location,a.date)
as Rolling_people_vaccincated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
--where a.continent is not null

select *,(Rolling_people_vaccincated/population) * 100 
from #PercentPopuationVaccincated


--Creating view to store data for later visualization

create view PercentPopulationVaccincated as
select a.continent, a.location, a.date, a.population,
b.new_vaccinations, sum(cast(b.new_vaccinations as int)) over(partition by a.location Order by a.location,a.date)
as Rolling_people_vaccincated
from CovidDeaths as a
join CovidVaccinations as b
on a.location = b.location and a.date = b.date
where a.continent is not null


select * from PercentPopulationVaccincated