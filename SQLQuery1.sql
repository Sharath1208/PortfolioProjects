Select * 
From PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

--looking at total cases vs total deaths
--Shows likely hood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location = 'India'
 AND continent is not null
 ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT Location, date, total_cases, population, (Total_cases/population)*100 AS PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 ORDER BY 1,2

 --Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS Highestinfectioncount, MAX((Total_cases/population))*100 AS PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 GROUP BY location, population
 ORDER BY PercentPopulationInfected desc

 --Showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 WHERE continent is not null
 GROUP BY location, population
 ORDER BY TotalDeathCount desc

 --LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 WHERE continent is null
 GROUP BY location
 ORDER BY TotalDeathCount desc

 -- Showing continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 WHERE continent is not null
 GROUP BY continent
 ORDER BY TotalDeathCount desc

 -- GLOBAL NUMBERS
SELECT  date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2

 --Total Global Death Percentage
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location = 'India'
 WHERE continent is not null
 --GROUP BY date
 ORDER BY 1,2


 --Looking at total population vs vaccinations
 Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
   

--USE CTE

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationVccinated
Create Table #PercentPopulationVccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeople numeric
)


Insert into #PercentPopulationVccinated
Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3


Select *, (RollingPeople/population)*100
From #PercentPopulationVccinated


--Creating View to store data for later Visualizations

Create View PercentPopulationVccinated as
Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
  From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVccinated