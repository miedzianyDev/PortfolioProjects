
-- This project aims to analyse covid data presenting various trends and comparisons nationaly and globaly


-- Comparing Total Cases vs Population to obtain infection percentage and also comparing Total Deaths vs Total Cases to  obtain death percentage of population that was infected
-- Presents percentage of population that got infected in given country and percentage of infected people that died due to infection

Select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as Infection_Percentage, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%poland%'
and continent is not null
Order by 1,2

-- Comparing countries with highest infection count vs population to find countries with highest probabylity of geting infected

Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Of_Population_Infected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by Percent_Of_Population_Infected DESC

-- Presentation of Countries with highest death count

Select location, population, MAX(cast(total_deaths as int)) as Total_Death_Count 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by Total_Death_Count DESC

-- Presentation of Continent with highest death count per population

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by Total_Death_Count DESC

-- Presentation of daily infection count, death count and death percentage globaly

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Presentation of total infection count, death count and death percentage globaly

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null

-- Comparing Total Population vs Vaccination presenting vaccination rolout in given country
-- Joining two tables for corelation of information that other talbe don't poses

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.location like '%poland%'
Order by 2,3

-- Presenting Vaccination Rollout and percentage of population vaccinated
-- TEMP Table created in order to make percentage calculation possible

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100 as Percentage_Of_RPV
From #PercentPopulationVaccinated
Where Location like '%poland%'