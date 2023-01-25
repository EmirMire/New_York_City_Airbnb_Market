# New_York_City_Airbnb_Market


New York City Airbnb Market - Data Analytics with MySQL &amp; Data Visualization with MS Excel.

The dataset for this project was taken from the real-world data platform – Kaggle. 

- About Dataset

Welcome to New York City (NYC), one of the most-visited cities in the world. As a result, from 2008 to 2019 there are many Airbnb listings to meet the high demand for temporary lodging for anywhere between a few nights to many months, guests and hosts have used Airbnb to expand on traveling possibilities and present a more unique, personalized way of experiencing the world.

This dataset includes all needed information from host name, listing id, dates, neighborhood names, prices to rooms, their types and description, etc. 

Using this dataset, you can apply various data cleaning techniques, perform data analytics and data visualization, make predictions, and most importantly – HAVE FUN!



**LET'S GET STARTED!**

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

![image](https://user-images.githubusercontent.com/121452974/214641233-6682769f-3d6a-4fad-bbfd-d2043c714bdb.png)



    -- 2. What is the average price per night, per neighbourhood, ordered from the most expensive to the cheapest?

SELECT nbhood_full, AVG(price) AS Average_price 
FROM airbnb_price
GROUP BY nbhood_full
ORDER BY Average_price DESC;

![image](https://user-images.githubusercontent.com/121452974/214641629-9feeccff-7278-40bc-aa9e-59e5b6f4a5cc.png)



    -- 3. What is the average, MIN & MAX price per night, per room type, ordered by average price, 
          from the cheapest to the most expensive?

SELECT room_type, ROUND(AVG(price), 2) AS AVG_price, MIN(price) AS MIN_price, MAX(price) AS MAX_price
FROM airbnb_room_type
JOIN airbnb_price ON airbnb_room_type.listing_id=airbnb_price.listing_id
GROUP BY room_type
ORDER BY AVG_price;

![image](https://user-images.githubusercontent.com/121452974/214641971-fcbf2748-010b-4d66-ab74-f1902943252c.png)

_**Looking at the result, we can conclude that shared room is the cheapest option in NYC through Airbnb is shared room, with the average price of 40,00 USD, and the most expensive option is entire home/apartment with the price of 182,83 USD.**_



    -- 4. Average, MAX & MIN price by neighbourhood and room type:

SELECT nbhood_full AS Neighbourhood, room_type, ROUND(AVG(price),2) AS Avg_price, MAX(price) AS Max_price, MIN(price) AS Min_price
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
GROUP BY 1,2
ORDER BY 1;

![image](https://user-images.githubusercontent.com/121452974/214642106-e83af83a-ce6d-471a-84b9-c40dfbf8b481.png)



    -- 5. Based on average price and grouped by room type and neighbourhood, splitting the NYC Airbnb accommodation into four categories: 
          Budget, Average, Expensive and Extravagant.

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

![image](https://user-images.githubusercontent.com/121452974/214642283-e1405f33-d6c5-47ca-97dd-10d611b1dbef.png)



    -- 6. Average price per location (Manhattan, Brooklyn, Queens, etc.) and total number of available accommodations 

SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS location, ROUND(avg(price), 2) AS avg_price, COUNT(*) AS 'Number of accommodations'
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
GROUP BY location
ORDER BY avg_price DESC;

![image](https://user-images.githubusercontent.com/121452974/214642488-49070064-5558-42ff-aaec-76c64a06292c.png)



    -- 7. Most common room type per location, average, MIN & MAX price

SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS location, room_type, COUNT(*) AS 'Number of accommodations', ROUND(avg(price), 2) AS avg_price, MAX(price) AS Max_price, MIN(price) AS Min_price
FROM airbnb_price AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
JOIN airbnb_last_review AS alr ON alr.listing_id = ap.listing_id
GROUP BY 1,2
ORDER BY 1,3 DESC;

![image](https://user-images.githubusercontent.com/121452974/214642595-cb6716df-bd59-4dfa-9814-a6d335880d60.png)

_**Based on the result, we can see what are the most common room types across different locations, and their prices (AVG, MAX & MIN)**_



    -- 8. In which months are the NYC Airbnb accommodations booked the most?

_(It is enough to extract only the name of the month since the data is only for one year - 2019)_

SELECT SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review , COUNT(*) AS No_reviews
FROM airbnb_last_review
GROUP BY month_of_last_review
ORDER BY No_reviews DESC;

![image](https://user-images.githubusercontent.com/121452974/214642890-0ccbc2c6-7aa1-4163-bc79-d8cea2896e29.png)

_**According to the result of this query, it is obvious that the NYC Airbnb accommodations are mostly booked in the spring and summer times. June & July are definitely the most booked months.**_



    -- 9. The total number of reviews indicating in which months the NYC Airbnb is mostly booked, across different locations? 

_(It is enough to extract only the name of the month since the data is only for one year - 2019)_

SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS location, SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review, COUNT(*) AS No_reviews
FROM airbnb_last_review AS alr
JOIN airbnb_price AS ap ON ap.listing_id = alr.listing_id
JOIN airbnb_room_type AS art ON art.listing_id = alr.listing_id
GROUP BY 2, 1
ORDER BY 1,3 DESC,2;

![image](https://user-images.githubusercontent.com/121452974/214643060-1b552633-0d53-4bec-bfa6-7cff43c794d2.png)



    -- 10. TOP Accommodations in trending durring summer time (based on the last review date).

SELECT nbhood_full, room_type, description, price, host_name, SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review
FROM airbnb_last_review AS alr
JOIN airbnb_price AS ap ON ap.listing_id = alr.listing_id
JOIN airbnb_room_type AS art ON art.listing_id = alr.listing_id
GROUP BY ap.listing_id
HAVING month_of_last_review = 'June' 
OR month_of_last_review = 'July' 
OR month_of_last_review = 'August';

![image](https://user-images.githubusercontent.com/121452974/214643310-af534b6a-7c58-4ccc-bf9e-f221686dc607.png)



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

![image](https://user-images.githubusercontent.com/121452974/214643696-a8a91e9b-b974-47c9-a59f-567b1a4842fd.png)



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

![image](https://user-images.githubusercontent.com/121452974/214643824-147764bc-9f06-448a-915b-0a5ed3be36be.png)





