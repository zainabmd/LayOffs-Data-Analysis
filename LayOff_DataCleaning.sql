-- DATA CLEANING
-- 1. remove duplicates
-- 2. standardize data
-- 3. null values or blank values
-- 4. remove any columns (if irrelevant)
select * from layoffs;
select * from layoff_staging;

-- creating layoff duplicate table -- shouldnt work on raw data
create table layoff_staging like layoffs;

-- inserting into layoff staging table
insert into layoff_staging select * from layoffs;

-- looking for and removing duplicate rows, by row numbers and partition by
select *, row_number() over(
partition by company, location,industry, total_laid_off,
percentage_laid_off,`date`, stage, country, funds_raised
) as row_num
from layoff_staging;

with duplicate_cte as (
select *, row_number() over(
partition by company, location,industry, total_laid_off,
percentage_laid_off,`date`, stage, country, funds_raised
) as row_num
from layoff_staging
)
select * from duplicate_cte
where row_num>1;
select * from layoff_staging where company='Cazoo';

CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_staging2
select *, row_number() over(
partition by company, location,industry, total_laid_off,
percentage_laid_off,`date`, stage, country, funds_raised
) as row_num
from layoff_staging;

delete from layoff_staging2
where row_num>1;
select * from layoff_staging2
where row_num>1;

-- 2. STANDARDIZING DATA finding issues in data and fixing them
update layoff_staging2
set company=trim(company); -- removing whitespaces from company names
select company from layoff_staging2;

select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoff_staging2 ;

alter table layoff_staging2
modify column `date` date;

-- 3. removing blankk and null values
select * from layoff_staging2
where total_laid_off is null or
 total_laid_off ='';
 
select * from layoff_staging2 t1
join layoff_staging2 t2
	on t1.company=t2.company
    and t1.location=t2.location
where (t1.industry is null or t1.industry='') 
and t2.industry is not null;

-- turning blank into null value to remove
update layoff_staging2 
set industry = null where industry ='';

select * from  layoff_staging2 where percentage_laid_off='' or percentage_laid_off is null;

update layoff_staging2 
set percentage_laid_off = null where percentage_laid_off ='';
update layoff_staging2 
set percentage_laid_off = null where percentage_laid_off ='';

-- deleting null columns
delete from layoff_staging2
where total_laid_off is null and percentage_laid_off is null;
select * from layoff_staging2;
-- delete column row_num 
alter table layoff_staging2
drop column row_num;

-- DATA CLEANING FINISHED
