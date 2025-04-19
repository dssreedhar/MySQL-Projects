-- MySQL Project - E-Commerce Customer Churn Analysis:

-- Data Cleaning:

USE ecomm;

-- Handle missing values and outliers
 
SELECT AVG (WarehouseToHome) from customer_churn ;
SELECT AVG (HourSpendOnApp) from customer_churn ;
SELECT AVG (OrderAmountHikeFromlastYear) from customer_churn ;
SELECT AVG (DaySinceLastOrder) from customer_churn ;

SET @mode_value = (
  SELECT Tenure
  FROM customer_churn
  GROUP BY Tenure
  ORDER BY COUNT(*) DESC
  LIMIT 1
);

SET @mode_value = (
  SELECT CouponUsed
  FROM customer_churn
  GROUP BY CouponUsed
  ORDER BY COUNT(*) DESC
  LIMIT 1
);

SET @mode_value = (
  SELECT OrderCount
  FROM customer_churn
  GROUP BY OrderCount
  ORDER BY COUNT(*) DESC
  LIMIT 1
);

SET SQL_SAFE_UPDATES = 0;

DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

-- Dealing with Inconsistencies:

UPDATE customer_churn
SET 
  PreferredLoginDevice = REPLACE(PreferredLoginDevice, 'Phone', 'Mobile Phone'),
  PreferedOrderCat = REPLACE(PreferedOrderCat, 'Mobile', 'Mobile Phone'),
  
  PreferredPaymentMode = REPLACE(PreferredPaymentMode, 'COD', 'Cash on Delivery'),
  PreferredPaymentMode = REPLACE(PreferredPaymentMode, 'CC', 'Credit Card');

-- Data Transformation:

-- Column Renaming:
ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat,
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

-- Creating New Columns:
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(5) AS (IF(Complain = 1, 'Yes', 'No')),
ADD COLUMN ChurnStatus VARCHAR(10) AS (IF(Churn = 1, 'Churned', 'Active'));

-- Column Dropping:
ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

                -- Data Exploration and Analysis:

-- 1. Retrieve the count of churned and active customers
SELECT 
  SUM(IF(ChurnStatus = 'Churned', 1, 0)) AS Churned_Customers,
  SUM(IF(ChurnStatus = 'Active', 1, 0)) AS Active_Customers
FROM customer_churn;


-- 2. Display the average tenure and total cashback amount of customers who churned
SELECT 
  AVG(Tenure) AS Average_Tenure,
  SUM(CashbackAmount) AS Total_Cashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';


-- 3. Determine the percentage of churned customers who complained
SELECT 
  (SUM(IF(ComplaintReceived = 'Yes' AND ChurnStatus = 'Churned', 1, 0)) / 
   SUM(IF(ChurnStatus = 'Churned', 1, 0))) * 100 
   AS Complaint_Percentage;


-- 4. Find the gender distribution of customers who complained
SELECT 
  Gender, 
  COUNT(*) AS Count
FROM customer_churn
WHERE ComplaintReceived = 'Yes'
GROUP BY Gender;


-- 5. Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory
SELECT 
  CityTier, 
  COUNT(*) AS Count
FROM customer_churn
WHERE ChurnStatus = 'Churned' 
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY Count DESC 
LIMIT 1;


-- 6. Identify the most preferred payment mode among active customers
SELECT 
  PreferredPaymentMode, 
  COUNT(*) AS Count
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY Count DESC 
LIMIT 1;


-- 7. Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering
SELECT 
  SUM(OrderAmountHikeFromlastYear) 
  AS Total_Order 
FROM customer_churn
WHERE MaritalStatus = 'Single' 
  AND PreferredOrderCat = 'Mobile Phones';


-- 8. Find the average number of devices registered among customers who used UPI as their preferred payment mode
SELECT 
  AVG(NumberOfDeviceRegistered) 
  AS Average_Devices_Registered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';


-- 9. Determine the city tier with the highest number of customers
SELECT 
  CityTier, 
  COUNT(*) AS Count
FROM customer_churn
GROUP BY CityTier
ORDER BY Count DESC 
LIMIT 1;


-- 10. Identify the gender that utilized the highest number of coupons
SELECT 
  Gender, 
  SUM(CouponUsed) 
  AS Total_Coupons_Used
FROM customer_churn
GROUP BY Gender
ORDER BY Total_Coupons_Used DESC 
LIMIT 1;


-- 11. List the number of customers and the maximum hours spent on the app in each preferred order category
SELECT 
  PreferredOrderCat, 
  COUNT(*) AS Customer_Count,
  MAX(HoursSpentOnApp) 
  AS Max_Hours_Spent
FROM customer_churn
GROUP BY PreferredOrderCat;


-- 12. Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score
SELECT 
  SUM(OrderCount) 
  AS Total_Order_Count
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card' 
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);


-- 13. How many customers are there who spent only one hour on the app and days since their last order was more than 5?
SELECT 
  COUNT(*) 
  AS Customer_Count
FROM customer_churn
WHERE HoursSpentOnApp = 1 
  AND DaySinceLastOrder > 5;


-- 14. What is the average satisfaction score of customers who have complained?
SELECT 
  AVG(SatisfactionScore) 
  AS Average_Satisfaction_Score
FROM customer_churn
WHERE ComplaintReceived = 'Yes';


-- 15. List the preferred order category among customers who used more than 5 coupons
SELECT 
  PreferredOrderCat, 
  COUNT(*) AS Customer_Count
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat;


-- 16. List the top 3 preferred order categories with the highest average cashback amount
SELECT 
  PreferredOrderCat, 
  AVG(CashbackAmount) 
  AS Average_Cashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY Average_Cashback DESC 
LIMIT 3;

                   --  Thank you --
