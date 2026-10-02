--select * from Country;
---SELECT * FROM CRA;
--select * from City;


-- ==========================================
-- Practical Assignment - Task 2
-- Name: Augustine Chinemelu Udemezue
-- ==========================================


-- ==========================================
-- 1. Number of records in City
-- ==========================================

SELECT COUNT(*) AS number_of_cities
FROM City;


-- ==========================================
-- 2. Plans containing Internet Data Plan
-- ==========================================
SELECT 
    p.planName,
    p.price AS PlanPrice,
    idp.internetDataPlanName,
    idp.dataAllowanceMB,
    idp.price AS InternetPrice,
    mno.operatorName
FROM [Plan] p
INNER JOIN InternetDataPlan idp ON p.internetDataPlanID = idp.internetDataPlanID
INNER JOIN MobileNetworkOperator mno ON p.operatorID = mno.operatorID;


-- ==========================================
-- 3. Operators and plans with at least
-- 100 free minutes
-- ==========================================
SELECT 
    mno.operatorName,
    p.planName,
    p.price
FROM MobileNetworkOperator mno
INNER JOIN [Plan] p ON mno.operatorID = p.operatorID
INNER JOIN PlanBundle pb ON p.planID = pb.planID
INNER JOIN Service s ON pb.serviceID = s.serviceID
WHERE s.serviceName LIKE '%minute%' 
  AND s.serviceName LIKE '%Lithuania%'
  AND (
      s.serviceName LIKE '%100%' OR 
      s.serviceName LIKE '%200%' OR 
      s.serviceName LIKE '%300%' OR
      s.serviceName LIKE '%500%' OR
      s.serviceName LIKE '%1000%'
  );
-- ==========================================
-- 4. Number of users in each city
-- ==========================================

SELECT 
    c.cityName,
    COUNT(p.personID) AS UserCount
FROM City c
INNER JOIN Person p ON c.cityID = p.cityID
GROUP BY c.cityName
ORDER BY UserCount DESC;


-- ==========================================
-- 5. Cities with no users
-- ==========================================

SELECT c.cityName
FROM City c
LEFT JOIN Person p ON c.cityID = p.cityID
WHERE p.personID IS NULL;


-- ==========================================
-- 6A. Average users per city
-- Excluding cities with no users
-- ==========================================

SELECT AVG(CAST(UserCount AS DECIMAL(10,2))) AS AvgUsersPerCity
FROM (
    SELECT c.cityID, COUNT(p.personID) AS UserCount
    FROM City c
    INNER JOIN Person p ON c.cityID = p.cityID
    GROUP BY c.cityID
) AS CityCounts;


-- ==========================================
-- 6B. Average users per city
-- Including cities with no users
-- ==========================================

SELECT AVG(CAST(ISNULL(UserCount, 0) AS DECIMAL(10,2))) AS AvgUsersPerCity
FROM (
    SELECT c.cityID, COUNT(p.personID) AS UserCount
    FROM City c
    LEFT JOIN Person p ON c.cityID = p.cityID
    GROUP BY c.cityID
) AS CityCounts;


-- ==========================================
-- 7. Operator(s) with the largest number
-- of plans
-- ==========================================

SELECT TOP (1) WITH TIES
    mno.operatorName,
    COUNT(p.planID) AS PlanCount
FROM MobileNetworkOperator mno
INNER JOIN [Plan] p ON mno.operatorID = p.operatorID
GROUP BY mno.operatorName
ORDER BY PlanCount DESC;


-- ==========================================
-- 8. People subscribing between
-- 2025-01-03 and 2025-01-10
-- ==========================================

SELECT 
    p.firstName,
    p.lastName,
    pl.planName,
    s.contractStartDate
FROM Subscriber s
INNER JOIN Person p ON s.personID = p.personID
INNER JOIN [Plan] pl ON s.planID = pl.planID
WHERE s.contractStartDate BETWEEN '2025-01-03' AND '2025-01-10'
ORDER BY s.contractStartDate;


-- ==========================================
-- 9. Average plan price per operator
-- ==========================================

SELECT 
    mno.operatorName,
    AVG(CAST(p.price AS DECIMAL(10,2))) AS AvgPlanPrice
FROM MobileNetworkOperator mno
INNER JOIN [Plan] p ON mno.operatorID = p.operatorID
GROUP BY mno.operatorName
ORDER BY AvgPlanPrice DESC;



-- ==========================================
-- 10. Number of additional services
-- per operator
-- ==========================================

SELECT 
    mno.operatorName,
    COUNT(oas.operatorAdditionalServiceID) AS AdditionalServiceCount
FROM MobileNetworkOperator mno
LEFT JOIN OperatorAdditionalService oas ON mno.operatorID = oas.operatorID
GROUP BY mno.operatorName
ORDER BY AdditionalServiceCount DESC

-- Task 10
SELECT
    mno.operatorName,
    COUNT(oas.additionalServiceID) AS number_of_additional_services
FROM dbo.MobileNetworkOperator AS mno
LEFT JOIN dbo.OperatorAdditionalService AS oas
    ON mno.operatorID = oas.operatorID
GROUP BY
    mno.operatorID,
    mno.operatorName;