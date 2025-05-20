create database if not exists Exploratory_Analysis_Covid_19;
Use Exploratory_Analysis_Covid_19;

/*  1st Table covid_deaths  */      select *from covid_deaths;


create table covid_deaths(
iso_code text,
continent text,
location text,
date text,
population bigint,
total_cases bigint,
new_cases bigint,
new_cases_smoothed float,
total_deaths bigint,
new_deaths bigint,
new_deaths_smoothed float,
total_cases_per_million bigint,
new_cases_per_million bigint,
new_cases_smoothed_per_million bigint,
total_deaths_per_million bigint,
new_deaths_per_million bigint,
new_deaths_smoothed_per_million float,
reproduction_rate bigint,
icu_patients bigint,
icu_patients_per_million bigint,
hosp_patients bigint,
hosp_patients_per_million bigint,
weekly_icu_admission bigint,
weekly_icu_admission_per_million bigint,
weekly_hosp_admissions bigint,
weekly_hosp_admission_per_million bigint
);



/* 2nd Table covid_Vaccination  */             select * from covid_vaccination;

create table covid_vaccination (
iso_code text,
continent text,
location text,
date text,
new_tests bigint,
total_tests bigint,
total_tests_per_thousand bigint,
new_tests_per_thousand bigint,
new_tests_smoothed bigint,
new_tests_smoothed_per_thousand float,
positive_rate float,
tests_per_case float,
tests_units bigint,
total_vaccinations bigint,
people_vaccinated bigint,
people_fully_vaccinated bigint,
new_vaccinations bigint,
new_vaccinations_smoothed bigint,
total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float,
people_fully_vaccinated_per_hundred float,
new_vaccinations_smoothed_per_million float,
stringency_index float,
population_density float,
median_age float,
aged_65_older float,
aged_70_older float,
gdp_per_capita float,
extreme_poverty float,
cardiovasc_death_rate float,
diabetes_prevalence float,
female_smokers float,
male_smokers float,
handwashing_facilities float,
hospital_beds_per_thousand float,
life_expectancy float,
human_development_index float,
excess_mortality float
);






/* LOAD DATA LOCAL INFILE 
'C:\Program Files\MySQL\MySQL Server 8.0\upload\covid_deaths.csv' 
INTO TABLE covid_deaths
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'; */

LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\covid_deaths.csv' 
INTO TABLE covid_deaths 
CHARACTER SET UTF8 FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\covid_vaccination.csv'
INTO TABLE covid_vaccination 
CHARACTER SET UTF8 FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES;

describe covid_vaccination;

/* How many lines does the dataset have?*/

 select count(*) from covid_deaths;
 select count(*) from covid_vaccination;
 
 /* Exploring some important columns of the dataset covid.deaths.csv*/
 
 SELECT date, continent, location, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date;


/* check Duplicate value table Deaths */

SELECT date, continent, location,
COUNT(*) as Checking_Dup
FROM covid_deaths
GROUP BY date, continent, location
HAVING Checking_Dup > 1;

/* check duplicate value table covid_vaccination */

SELECT date, continent, location,
COUNT(*) as Checking_Dup
FROM covid_vaccination
GROUP BY date, continent, location
HAVING Checking_Dup > 1;


/* Checking the quantity of continents and countries  */

SELECT COALESCE(continent, "Total") as Continent,
COUNT(continent) as Count
FROM(SELECT DISTINCT continent
FROM covid_deaths) as Subquery
GROUP BY continent with rollup
ORDER BY continent;


SELECT COUNT(location) as Qtt_Countries
FROM(SELECT DISTINCT location
FROM covid_deaths) as Subquery;

/* Average number of deaths by day (Continents and Countries) */

SELECT location,
ROUND(AVG(new_deaths)) AS Deaths_Average_Day
FROM covid_deaths
GROUP BY location
ORDER BY Deaths_Average_Day DESC;


/* Average of cases divided by the number of population of each country (TOP 10) */

SELECT continent, location,
ROUND(AVG((total_cases / population) * 100), 2) AS Percentage_Population
FROM covid_deaths
GROUP BY  continent, location
ORDER BY Percentage_Population DESC
LIMIT 10;


/* Considering the highest value of total cases, which countries have the highest rate of infection in relation to population? */
  
SELECT location,
MAX(total_cases) AS Max_of_Cases,
population,
ROUND(MAX(total_cases / population * 100), 2) AS Perc_Pop_Infected FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Perc_Pop_Infected DESC
LIMIT 10;


/*  Countries with the highest number of deaths */
select location,
max(total_deaths) as max_of_deaths
from covid_deaths 
where continent is not null
group by location
order by max_of_deaths desc;


/* Continents with the highest number of deaths */
SELECT continent,
MAX(total_deaths) as Highest_Death
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death DESC;


/* Number of new vaccinated and rolling average of new vaccinated over time by country on the European continent */

SELECT deaths.continent, deaths.location, deaths.date, vaccination.new_vaccinations,
AVG(vaccination.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.date) as RollingAvg_Vaccines
FROM covid_deaths  deaths
JOIN covid_vaccination vaccination
ON deaths.location = vaccination.location
AND deaths.date = vaccination.date
WHERE deaths.continent = 'Europe'
ORDER BY location, date;


/* Creating a view with the CTE */                 select * from percentage_vacvspop ;

select * from percentage_vacvspop;
CREATE OR REPLACE VIEW percentage_vacvspop AS
SELECT 
    deaths.continent,
    deaths.location,
    deaths.date,
    deaths.population,
    vaccination.new_vaccinations,
    SUM(vaccination.new_vaccinations) OVER (
        PARTITION BY deaths.location
        ORDER BY deaths.date
    ) AS RollingAvg_Vaccination,
    (SUM(vaccination.new_vaccinations) OVER (
        PARTITION BY deaths.location
        ORDER BY deaths.date
    ) / deaths.population) * 100 AS Percentage_1_Dose
FROM covid_deaths AS deaths
JOIN covid_vaccination AS vaccination
    ON deaths.location = vaccination.location
    AND deaths.date = vaccination.date;



/*Percentage of the population vaccinated with at least the first dose until 30/6/2021 (Top 3) */

SELECT *
FROM percentage_vacvspop
WHERE (location = 'United States'
OR location = 'Brazil'
OR location = 'india'
OR location = 'Mexico'
OR location = 'Peru')
AND DATE = '30/06/21'
ORDER BY Percentage_1_Dose DESC;

