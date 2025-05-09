--Covid 19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select * 
From [Portofolio Project.1]..CovidDeaths
Order by 3,4

--Select * 
--From [Portofolio Project.1]..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

-- Step 2: Select key COVID metrics per location and date
Select location, date, total_cases, new_cases, total_deaths, population 
From [Portofolio Project.1]..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you have covid in your country

-- Step 3: Calculate COVID death percentage by country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portofolio Project.1]..CovidDeaths
Where location like '%states%'
Order by 1,2

---Looking at Total Cases vs Total Deaths
--Shows what percentage of population got Covid

-- Step 4: Calculate percentage of population infected
Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [Portofolio Project.1]..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

-- Step 4: Calculate percentage of population infected
Select location, population, Max(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectedPercentage
From [Portofolio Project.1]..CovidDeaths
--Where location like '%states%'
--Where location = 'Greece'
Group By location, population
Order by InfectedPercentage desc

-- Step 6: Countries with highest total deaths (raw count)
--Showing Countries with Highest Death Count Per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portofolio Project.1]..CovidDeaths
Where continent is not null 
Group By location
Order by TotalDeathCount desc


--Breaking Things Down By Continent

-- Step 6: Countries with highest total deaths (raw count)
--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portofolio Project.1]..CovidDeaths
Where continent is not null 
-- Step 7: Total death count summarized by continent
Group By continent
Order by TotalDeathCount desc


-- Step 8: Calculate global case and death totals
--Global Numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portofolio Project.1]..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
Order by 1,2

--Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
from [Portofolio Project.1]..CovidDeaths dea
Join [Portofolio Project.1]..CovidVaccinations vac
       On dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
from [Portofolio Project.1]..CovidDeaths dea
Join [Portofolio Project.1]..CovidVaccinations vac
       On dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatio nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
from [Portofolio Project.1]..CovidDeaths dea
Join [Portofolio Project.1]..CovidVaccinations vac
       On dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition By dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
from [Portofolio Project.1]..CovidDeaths dea
Join [Portofolio Project.1]..CovidVaccinations vac
       On dea.location = vac.location
	   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated