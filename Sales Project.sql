-- Displaying data

select *
from Projectsales..salesdata

-- Top Sales for each product

select Product, MAX(Units) AS Max_Units, Unit_price, MAX(Units) * Unit_price AS Topsales
from Projectsales..salesdata
group by Product, Unit_price
order by Topsales desc;

-- Total Units for each product purchased in each city

select Product, Sum(Units) as Total_Units , City
from Projectsales..salesdata
group by Product, City
order by Total_Units Desc

-- Total Units sold for all products in each city

select distinct City, Sum(Units) AS All_Units
from Projectsales..salesdata
group by City
order by All_Units desc

-- Top Sales for each city

select distinct  City, Product, MAX(Units) AS Max_Units, Unit_price, MAX(Units) * Unit_price AS Topsales
from Projectsales..salesdata
Where City IN (Select Distinct City from Projectsales..salesdata)
group by Product, Unit_price, City
order by City, Max_Units desc