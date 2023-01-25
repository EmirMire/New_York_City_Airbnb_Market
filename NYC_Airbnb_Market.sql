
-- First step is to create a database and import real-world data from Kaggle.

CREATE DATABASE newyork_airbnb;

USE newyork_airbnb;


-- After importing our New York City Airbnb Market real-world data, some adjustments will be made in one of the tables.

UPDATE airbnb_price
SET price = REPLACE(price, 'dollars', ' ')
WHERE price IS NOT NULL;

ALTER TABLE airbnb_price MODIFY price INT NOT NULL;


-- Now we can start analyzing the data.

# DATA ANALYTICS

-- 1. What is the average price, per night, of an Airbnb listing in NYC?

SELECT AVG(price) AS 'Average price' 
FROM airbnb_price;


-- 2. What is the average price per night, per neighbourhood, ordered from the most expensive to the cheapest?

SELECT nbhood_full, AVG(price) AS Average_price 
FROM airbnb_price
GROUP BY nbhood_full
ORDER BY Average_price DESC;


-- 3. What is the average, MIN & MAX price per night, per room type, ordered by average price, from the cheapest to the most expensive?

SELECT room_type, ROUND(AVG(price), 2) AS AVG_price, MIN(price) AS MIN_price, MAX(price) AS MAX_price
FROM airbnb_room_type
JOIN airbnb_price ON airbnb_room_type.listing_id=airbnb_price.listing_id
GROUP BY room_type
ORDER BY AVG_price;

# Looking at the result, we can conclude that shared room is the cheapest option in NYC through Airbnb, with the average price of 40,00 USD, and the most expensive option is entire home/apartment with the price of 182,83 USD.


-- 4. Average, MAX & MIN price by neighbourhood and room type:

SELECT nbhood_full AS Neighbourhood, room_type, ROUND(AVG(price),2) AS Avg_price, MAX(price) AS Max_price, MIN(price) AS Min_price
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
GROUP BY 1,2
ORDER BY 1;


-- 5. Based on average price and grouped by room type and neighbourhood, splitting the NYC Airbnb accommodation into four categories: Budget, Average, Expensive and Extravagant.

WITH merged AS(
SELECT room_type, nbhood_full, ROUND(AVG(price),2) AS Avg_price, MAX(price) AS Max_price, MIN(price) AS Min_price
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
GROUP BY room_type, nbhood_full)

SELECT *, CASE
WHEN avg_price <= 69 THEN 'Budget'
WHEN avg_price <= 175 THEN 'Average'
WHEN avg_price <= 350 THEN 'Expensive'
ELSE 'Extravagant'
END AS Price_category
FROM merged; 


-- 6. Average price per location (Manhattan, Brooklyn, Queens, etc.) and total number of available accommodations 

SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS location, ROUND(avg(price), 2) AS avg_price, COUNT(*) AS 'Number of accommodations'
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
GROUP BY location
ORDER BY avg_price DESC;


-- 7. Most common room type per location, average, MIN & MAX price

SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS location, room_type, COUNT(*) AS 'Number of accommodations', ROUND(avg(price), 2) AS avg_price, MAX(price) AS Max_price, MIN(price) AS Min_price
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
GROUP BY 1,2
ORDER BY 1,3 DESC;

# Based on the result, we can see what are the most common room types across different locations, and their prices (AVG, MAX & MIN)


-- 8. In which months are the NYC Airbnb accommodations booked the most?

# (It is enough to extract only the name of the month since the data is only for one year - 2019)

SELECT SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review , COUNT(*) AS No_reviews
FROM airbnb_last_review
GROUP BY month_of_last_review
ORDER BY No_reviews DESC;

# According to the result of this query, it is obvious that the NYC Airbnb accommodations are mostly booked in the spring and summer times. June & July are definitely the most booked months.


-- 9. The total number of reviews indicating in which months the NYC Airbnb is mostly booked, across different locations? 

# (It is enough to extract only the name of the month since the data is only for one year - 2019)

SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS location, SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review, COUNT(last_review) AS No_reviews
FROM airbnb_last_review AS alr
JOIN airbnb_price AS ap ON ap.listing_id = alr.listing_id
GROUP BY 2, 1
ORDER BY 1,3 DESC,2;



-- 10. TOP Accommodations in trending durring summer time (based on the last review date).

SELECT nbhood_full, room_type, description, price, host_name, SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review
FROM airbnb_last_review AS alr
JOIN airbnb_price AS ap ON ap.listing_id = alr.listing_id
JOIN airbnb_room_type AS art ON art.listing_id = alr.listing_id
GROUP BY ap.listing_id
HAVING month_of_last_review = 'June' 
OR month_of_last_review = 'July' 
OR month_of_last_review = 'August';


-- 11.The total number of accommodations in Manhattan and AVG, MIN & MAX price?

ALTER TABLE airbnb_price ADD COLUMN location VARCHAR(50);

UPDATE airbnb_price
SET location = SUBSTRING_INDEX(nbhood_full, ",", 1)
WHERE location IS NULL;


SELECT ap.listing_id, nbhood_full, room_type, description, price, host_name, last_review, location,
COUNT(*) OVER(PARTITION BY location) AS No_of_accommodations_MHTN,
CONCAT("$", AVG(price) OVER(PARTITION BY location)) AS AVG_price_MHTN, 
CONCAT("$", MIN(price) OVER(PARTITION BY location)) AS MIN_Price_MHTN, 
CONCAT("$", MAX(price) OVER(PARTITION BY location)) AS MAX_Price_MHTN
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
WHERE location = "Manhattan"
ORDER BY price ASC;


-- 12. The total number of accommodations per neighbourhood in Manhattan and AVG, MIN & MAX price?

SELECT ap.listing_id, nbhood_full, room_type, description, price, host_name, last_review,
COUNT(*) OVER(PARTITION BY nbhood_full) AS No_of_accommodations_NBHD,
CONCAT("$", AVG(price) OVER(PARTITION BY nbhood_full)) AS AVG_price_NBHD, 
CONCAT("$", MIN(price) OVER(PARTITION BY nbhood_full)) AS MIN_Price_NBHD, 
CONCAT("$", MAX(price) OVER(PARTITION BY nbhood_full)) AS MAX_Price_NBHD
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
WHERE nbhood_full LIKE "Manhattan%"
ORDER BY 2,5;





