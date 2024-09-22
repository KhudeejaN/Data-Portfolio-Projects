SELECT *
From [Portfolio Project]..CovidDeaths$
Where continent is not NULL 
order by 3,4

SELECT *
From [Portfolio Project]..CovidVaccinations$
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population 
From [Portfolio Project]..CovidDeaths$
Where continent is not NULL 
order by 1,2 


--glancing at the data 
--looking at Total Cases vs Total Deaths 
-- shows the likelihood of dying if you contract covid in your country


Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where continent is not NULL 
where location like '%Pakistan%'
order by 1,2 


-- Looking at the Total Cases vs The Population 

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [Portfolio Project]..CovidDeaths$
where location like '%Pakistan%'
order by 1,2 

--shows what percentage of population got covid 

-- all countries 

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [Portfolio Project]..CovidDeaths$
order by 1,2 

-- what countries have the highest infection rates acc to the population?
-- Looking at countries with Highest Infection Rate compared to Population 


Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as InfectedPercentage
From [Portfolio Project]..CovidDeaths$
Group by Location, Population
order by InfectedPercentage desc

--showing the countries with the highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like %states% or %pakistan% 
Where continent is not NULL 
Group by Location
order by TotalDeathCount desc

--- LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like %states% or %pakistan% 
Where continent is not NULL 
Group by continent
order by TotalDeathCount desc



-- Showing the continents with the highest death counts 


Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like %states% or %pakistan% 
Where continent is NULL 
Group by location
order by TotalDeathCount desc

-- drilling down with layers 
-- continent --> location etc 

--calculating everything across the entire world 
-- GLOBAL NUMBERS 

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$ 
where continent is not NULL 
Group by date
order by 1,2 



Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$ 
where continent is not NULL 
order by 1,2 

-- overall across the world, the death percentage was 2.11% 


-- Looking at Total Population vs Vaccinations 


Select *
From [Portfolio Project]..CovidDeaths$ dea 
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date

	
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,  
SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
 

 -- USE CTE 
 -- if no of columns in cte =/ number of columns in the selected thingy, it will give us an error

 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as 
 (
 Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,  
SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On  dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
-- (this can't be included here either) order by 2,3
)
 
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac
 


 -- TEMP TABLE 

 DROP TABLE IF exists #PercentPopulationVaccinated 
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
 Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,  
SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On  dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null 
-- (this can't be included here either) order by 2,3
 
 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated 
 

-- Creating View to store data for later visualizations 

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,  
SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On  dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentagePopulationVaccinated





