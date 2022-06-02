Select *
From CovidDeaths$
WHERE continent is not null
ORDER BY 3,4;

-- Looking at Total Cases VS Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
ORDER BY 1,2;


-- Looking at Total Cases VS Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
FROM dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM dbo.CovidDeaths$
Group By location, population
ORDER BY PercentPopulationInfected desc;


-- Lets break it down by Continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Looking at Countries with Highest Death Count compared to Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
FROM CovidDeaths$ 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


SELECT *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


-- USE CTE
With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at Total Population VS Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated



-- Creating View to Store Date for Later Visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3;

Select *
From PercentPopulationVaccinated