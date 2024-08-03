select * from dbo.CovidVccinations

select * from dbo.CovidDeaths

Select *
From  [PortfolioProject]..CovidDeaths
Where continent is not null 
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject]..CovidDeaths
Where continent is not null 
order by 1,2



--FINDING TOTAL CASES vs TOTAL DEATHS IN A COUNTRY 
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From  [PortfolioProject]..CovidDeaths
Where location like '%India%'
and continent is not null 
order by 1,2
--DEATH PRCENTAGE OF US DUE TO COVID IS AROUND 1.78%

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From  [PortfolioProject]..CovidDeaths
Where location like '%India%'
and continent is not null 
order by 1,2
-- DEATH PERCENTAGE OF INDIA DUE TO COVID  WAS AROUND 1.105%


--Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From  [PortfolioProject]..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc
--US HAS HIGHEST DEATH COUNT WITH 576232 DEATHS FOLLOWED BY BRAZIL,MEXICO,INDIA


--Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From  [PortfolioProject]..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc
--NA CONTINENT HAD MOST DEATH 576232 AMONG ALL THE CONTINENTS WHILE OCEAANIA HAD LEAST DEATHS


--FINDING what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From  [PortfolioProject]..CovidDeaths 
Where location like '%India%'
and continent is not null
order by 1,2
--AROUND 1.4 % POPULATION OF INDIA GOT INFECTED WITH COVID 


--Finding Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  [PortfolioProject]..CovidDeaths
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc
--ANDORRA HAD THE HIGHEST INFECTION RATE 

--Global numbers on covid 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From  [PortfolioProject]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
--DEATH PERCWENTAGE ACROSS THWE WORLD IS AROUND 2.1%


--JONING THE TWO TABLES TOGETHER
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [PortfolioProject]..CovidDeaths dea 
Join [PortfolioProject]..CovidVccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
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
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



CREATE VIEW [TotalDeathCount] AS
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From  [PortfolioProject]..CovidDeaths
Where continent is not null 
Group by Location

CREATE VIEW PercentPopulationInfected AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  [PortfolioProject]..CovidDeaths
Where continent is not null 
Group by Location, Population
--order by PercentPopulationInfected

CREATE VIEW DeathPercentage AS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From  [PortfolioProject]..CovidDeaths
Where location like '%states%'
and continent is not null 
Group By date
