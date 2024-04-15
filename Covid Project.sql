select * 
from ProjectSQL..CovidDeaths
where continent is not null


-- Total Cases VS Total Deaths 

SELECT Location, Date, total_cases, total_deaths, 
       CONVERT(float, Total_Deaths) / CONVERT(float, Total_Cases)*100 AS Death_Rate
FROM ProjectSQL..CovidDeaths
where continent is not null
order by 1,2 Asc


-- Percentage of Population who got Covid by country

SELECT Location, Date, Total_Cases, Total_Deaths, total_cases/population *100 AS Covid_Rate
FROM ProjectSQL..CovidDeaths
where continent is not null
ORDER BY 1,2 Desc

-- Countries with highest infection rate compared to the population

SELECT Location, Population, MAX(total_cases) as Highest_Infection_count, MAX((total_cases/population))*100 AS Infection_rate
from ProjectSQL..CovidDeaths
where continent is not null
group by Location, population
order by Infection_rate Desc

-- Countries with highest death rate per population

SELECT Location, population, Max(cast(total_deaths as int)) as Highest_Death_Count
from ProjectSQL..CovidDeaths
where continent is not null
group by location, population
order by Highest_Death_Count desc

-- Continents with highest death rate for Continent

SELECT Continent, Max(cast(total_deaths as int)) as Highest_Death_Count_Continent
from ProjectSQL..CovidDeaths
where continent is not null 
      and
      Continent NOT LIKE '%income%'
group by Continent
order by Highest_Death_Count_Continent desc

-- Global Numbers by date

Select SUM(new_cases) as Total_cases , Sum(Cast(new_deaths as int)) as Total_deaths, Sum(Cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From ProjectSQL..CovidDeaths
where continent is not null --and new_deaths !=0
Order By 1,2 desc

--Total Population vs Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
       SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) AS Total_Vaccinations, 
	   Total_Vaccinations/Dea.population*100 as Vaccination_Percentage
from ProjectSQL..CovidDeaths Dea
Join ProjectSQL..CovidVaccinations Vac
     on Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is NOT NULL 
      and new_vaccinations is NOT NULL
Order by 1,2,3	


-- Summary of Vaccinations

WITH VaccinationSummary AS (
    SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
        SUM(CONVERT(BIGINT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.date) AS Total_Vaccinations
    FROM ProjectSQL..CovidDeaths Dea
    JOIN ProjectSQL..CovidVaccinations Vac
    ON Dea.location = Vac.location AND Dea.date = Vac.date
    WHERE Dea.continent IS NOT NULL 
          AND Vac.new_vaccinations IS NOT NULL
)
SELECT continent, location, date, population, new_vaccinations, Total_Vaccinations, (Total_Vaccinations / population * 100) AS Vaccination_Percentage,
       ROUND(Total_Vaccinations / population * 100,0) AS Rounded_Vaccination_Percentage
FROM 
    VaccinationSummary
ORDER BY 
    1,2,3;


-- Creating View to store date for Visualizations

CREATE VIEW TotalPeopleVaccinated AS
SELECT 
    Dea.continent, 
    Dea.location, 
    Dea.date, 
    Dea.population, 
    Vac.new_vaccinations,
    SUM(CONVERT(BIGINT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.date) AS Total_Vaccinations 
    --Total_Vaccinations / Dea.population * 100 AS Vaccination_Percentage
FROM 
    ProjectSQL..CovidDeaths Dea
JOIN 
    ProjectSQL..CovidVaccinations Vac
ON 
    Dea.location = Vac.location
    AND Dea.date = Vac.date
WHERE 
    Dea.continent IS NOT NULL 
    AND Vac.new_vaccinations IS NOT NULL;


-- View Stored data

Select *
From TotalPeopleVaccinated