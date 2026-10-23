-- ==========================================
-- Practical Assignment - Task 3
-- Name: Augustine Chinemelu Udemezue
-- ==========================================


-- ==========================================
-- 1. Additional services provided by TELE2
/*Write a query that determines which additional services are provided 
by the mobile network operator TELE2. 
The query must return the additional service name and price.*/
-- ==========================================

SELECT
    a.additionalServiceName,
    oas.price
FROM dbo.MobileNetworkOperator AS mno
INNER JOIN dbo.OperatorAdditionalService AS oas
    ON mno.operatorID = oas.operatorID
INNER JOIN dbo.AdditionalService AS a
    ON oas.additionalServiceID = a.additionalServiceID
WHERE mno.operatorName = 'TELE2';

-- ==========================================
-- 2. Additional serrvices by all mobile operators
/* Write a query that returns the additional services offered by all mobile network operators. 
The query must return the operator name, additional service name, and price.*/
-- ==========================================

    SELECT 
    mno.operatorName,
    s.additionalServiceName,
    oas.price
FROM dbo.OperatorAdditionalService oas
INNER JOIN dbo.MobileNetworkOperator mno ON oas.operatorID = mno.operatorID
INNER JOIN dbo.AdditionalService s ON oas.additionalServiceID = s.additionalServiceID
WHERE oas.additionalServiceID IN (
    SELECT additionalServiceID
    FROM dbo.OperatorAdditionalService
    GROUP BY additionalServiceID
    HAVING COUNT(DISTINCT operatorID) = (SELECT COUNT(*) FROM dbo.MobileNetworkOperator)
);

-- ==========================================
-- 3. Number of countries belonging to each zone
/*Write a query that returns the number of countries belonging to each zone.*/
-- ==========================================

SELECT
    z.zoneName,
    COUNT(c.countryCode) AS number_of_countries
FROM dbo.Zone AS z
INNER JOIN dbo.Country AS c
    ON z.zoneID = c.zoneID
GROUP BY
    z.zoneID,
    z.zoneName;

-- ==========================================
-- 4. Operator offering the most expensive calls to Mexico
/*Write a query that returns the name of the operator offering the 
most expensive calls to Mexico.*/
-- ==========================================

SELECT TOP 1
    mno.operatorName,
    spz.price
FROM dbo.MobileNetworkOperator AS mno
INNER JOIN dbo.ServicePriceInZone AS spz
    ON mno.operatorID = spz.operatorID
INNER JOIN dbo.Country AS c
    ON spz.zoneID = c.zoneID
WHERE c.countryName = 'Meksika'
ORDER BY spz.price DESC;



-- ==========================================
-- 5. Lowest price per 1 MB internet data plan not included in any mobile plan
/*Write a query that finds the internet data plan that is not included 
in any mobile plan and has the lowest price per 1 MB. 
The query must return the operator name, 
internet data plan name, and price per 1 MB.*/
-- ==========================================


SELECT TOP 1
    mno.operatorName,
    idp.internetDataPlanName,
    idp.price / idp.dataAllowanceMB AS price_per_1_MB
FROM dbo.InternetDataPlan AS idp
INNER JOIN dbo.MobileNetworkOperator AS mno
    ON idp.operatorID = mno.operatorID
LEFT JOIN dbo.[Plan] AS p
    ON idp.internetDataPlanID = p.internetDataPlanID
WHERE p.planID IS NULL
ORDER BY price_per_1_MB ASC;


-- ==========================================
-- 6. Percentage distribution of subscribers among mobile network operators
/*Write a query that returns the percentage distribution of subscribers 
among mobile network operators.*/
-- ==========================================

SELECT
    mno.operatorName,
    COUNT(s.subscriberID) AS number_of_subscribers,
    CAST(
        COUNT(s.subscriberID) * 100.0
        / (SELECT COUNT(*) FROM dbo.Subscriber)
        AS DECIMAL(5,2)
    ) AS percentage_of_subscribers
FROM dbo.MobileNetworkOperator AS mno
INNER JOIN dbo.[Plan] AS p
    ON mno.operatorID = p.operatorID
INNER JOIN dbo.Subscriber AS s
    ON p.planID = s.planID
GROUP BY
    mno.operatorID,
    mno.operatorName;
-- ==========================================
-- 7. Three most popular mobile plans among subscribers
/*Write a query that returns the three most popular mobile plans among subscribers.
If several plans have the same number of subscribers at the cut-off point, 
return all tied plans. The query must return the plan name and 
number of subscribers.*/
-- ==========================================

WITH plan_subscribers AS
(
    SELECT
        p.planID,
        p.planName,
        COUNT(s.subscriberID) AS number_of_subscribers
    FROM dbo.[Plan] AS p
    LEFT JOIN dbo.Subscriber AS s
        ON p.planID = s.planID
    GROUP BY
        p.planID,
        p.planName
)
SELECT
    planName,
    number_of_subscribers
FROM
(
    SELECT
        planName,
        number_of_subscribers,
        DENSE_RANK() OVER (
            ORDER BY number_of_subscribers DESC
        ) AS ranking
    FROM plan_subscribers
) AS ranked_plans
WHERE ranking <= 3
ORDER BY number_of_subscribers DESC;
-- ==========================================
-- 8. Randomly selected 10 subscribers with detailed status indicators
/*Write a query that returns information about ten randomly selected subscribers 
including full name, city, phone number, contract dates, operator, 
plan name, and ordering indicators for additional internet plans and services.*/
-- ==========================================


SELECT TOP 10
    CONCAT(p.firstName, ' ', p.lastName) AS full_name,
    c.cityName,
    s.phoneNumber,
    s.contractStartDate,
    s.contractEndDate,
    mno.operatorName,
    pl.planName,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM dbo.OrderedInternetDataPlan AS oidp
            WHERE oidp.subscriberID = s.subscriberID
        )
        THEN 'Yes'
        ELSE 'No'
    END AS internet_data_plan_ordered,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM dbo.OrderedAdditionalService AS oas
            WHERE oas.subscriberID = s.subscriberID
        )
        THEN 'Yes'
        ELSE 'No'
    END AS additional_service_ordered

FROM dbo.Subscriber AS s
INNER JOIN dbo.Person AS p
    ON s.personID = p.personID
INNER JOIN dbo.City AS c
    ON p.cityID = c.cityID
INNER JOIN dbo.[Plan] AS pl
    ON s.planID = pl.planID
INNER JOIN dbo.MobileNetworkOperator AS mno
    ON pl.operatorID = mno.operatorID
ORDER BY NEWID();

-- ==========================================
-- 9. Top five subscribers by number of calls within Lithuania during October 2025
/*Write a query that returns the top five subscribers by the number of calls 
made within Lithuania during October 2025.*/
-- ==========================================
  

    SELECT TOP 5 WITH TIES
    p2p.subscriberID,
    COUNT(*) AS callCount
FROM dbo.P2PConnection p2p
INNER JOIN dbo.Service s ON p2p.serviceID = s.serviceID
WHERE s.serviceID = 1 -- Service 1 inherently means calls within Lithuanian networks
  AND p2p.connectionStart >= '2025-10-01' 
  AND p2p.connectionStart < '2025-11-01'
GROUP BY p2p.subscriberID
ORDER BY callCount DESC;



-- ==========================================
-- 10. Most popular foreign country by number of call connections
/*Write a query that determines the most popular foreign country based 
on the number of calls made to that country. If several countries 
are equally popular, return all of them.*/
-- ==========================================


SELECT TOP 1 WITH TIES
    c.countryName,
    COUNT(*) AS totalCalls
FROM dbo.P2PConnection p2p
INNER JOIN dbo.Service s ON p2p.serviceID = s.serviceID
INNER JOIN dbo.Country c ON p2p.recipientCountry = c.countryCode
WHERE s.serviceID = 4 -- Skambučiai į užsienio tinklus
  AND c.countryName NOT IN ('Lithuania', 'Lietuva')
GROUP BY c.countryCode, c.countryName
ORDER BY totalCalls DESC;
