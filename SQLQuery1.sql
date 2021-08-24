SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4



--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDDeaths
WHERE continent is not null
ORDER BY 1,2


	--Looking at Total Cases vs Total Deaths
	-- Shows likelihood of death if COVID is contracted in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..COVIDDeaths
WHERE location = 'united states'
ORDER BY 1,2

-- Looking at Total_cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 As Total_Cases_Populations 
FROM PortfolioProject..COVIDDeaths
WHERE location = 'united states'
ORDER BY 1,2


--Looking at Countries w/ Highest Infection Rate compared to population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..COVIDDeaths
--Where location like 'united states'
WHERE continent is not null
GROUP By population, location
ORDER BY PercentPopulationInfected desc

--Looking at Countries with the highest death count per population


SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Population
FROM PortfolioProject..COVIDDeaths
--Where location like 'united states'
WHERE continent is not null
GROUP By location
ORDER BY Total_Death_Population desc

--LET'S BREAK THING DOWN BY CONTINENT 


--Showing continent with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Location
FROM PortfolioProject..COVIDDeaths
--Where location like 'united states'
WHERE continent is not null
GROUP By continent
ORDER BY Total_Death_Location desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..COVIDDeaths
--WHERE location = 'united states'
where continent is not null
--Group by date
ORDER BY 1,2

--USE CTE

;With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 


--Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3