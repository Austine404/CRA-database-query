-- ==========================================
-- Practical Assignment - Task 3
-- Name: Augustine Chinemelu Udemezue
-- ==========================================


-- ==========================================
-- 1. Additional services provided by TELE2
-- ==========================================



-- Task 1
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
-- ==========================================


SELECT
    mno.operatorName,
    a.additionalServiceName,
    oas.price
FROM dbo.MobileNetworkOperator AS mno
INNER JOIN dbo.OperatorAdditionalService AS oas
    ON mno.operatorID = oas.operatorID
INNER JOIN dbo.AdditionalService AS a
    ON oas.additionalServiceID = a.additionalServiceID;

-- ==========================================
-- 3. Number of countries belonging to each zone
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
-- ==========================================

SELECT TOP 3 WITH TIES
    p.planName,
    COUNT(s.subscriberID) AS subscriberCount
FROM dbo.[Plan] p
INNER JOIN dbo.Subscriber s ON p.planID = s.planID
GROUP BY p.planID, p.planName
ORDER BY subscriberCount DESC;



-- ==========================================
-- 8. Randomly selected 10 subscribers with detailed status indicators
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



SELECT TOP 10
    p.firstName + ' ' + p.lastName AS fullName,
    c.cityName,
    s.phoneNumber,
    s.contractStartDate,
    s.contractEndDate,
    mno.operatorName,
    pl.planName,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM dbo.OrderedInternetDataPlan oid 
            WHERE oid.subscriberID = s.subscriberID
        ) THEN 'Yes' ELSE 'No' 
    END AS hasOrderedAdditionalInternet,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM dbo.OrderedAdditionalService oas 
            WHERE oas.subscriberID = s.subscriberID
        ) THEN 'Yes' ELSE 'No' 
    END AS hasOrderedAdditionalServices
FROM dbo.Subscriber s
INNER JOIN dbo.Person p ON s.personID = p.personID
INNER JOIN dbo.City c ON p.cityID = c.cityID
INNER JOIN dbo.[Plan] pl ON s.planID = pl.planID
INNER JOIN dbo.MobileNetworkOperator mno ON pl.operatorID = mno.operatorID
ORDER BY NEWID();

-- ==========================================
-- 9. Top five subscribers by number of calls within Lithuania during October 2013
-- ==========================================

SELECT TOP 5 WITH TIES
    p2p.subscriberID,
    COUNT(*) AS callCount
FROM dbo.P2PConnection p2p
INNER JOIN dbo.Country c ON p2p.recipientCountry = c.countryCode
WHERE c.countryName = 'Lithuania'
  AND p2p.connectionStart >= '2013-10-01' 
  AND p2p.connectionStart < '2013-11-01'
GROUP BY p2p.subscriberID
ORDER BY callCount DESC;


-- Task 9
SELECT TOP 5
    s.subscriberID,
    CONCAT(p.firstName, ' ', p.lastName) AS full_name,
    COUNT(*) AS number_of_calls
FROM dbo.Subscriber AS s
INNER JOIN dbo.Person AS p
    ON s.personID = p.personID
INNER JOIN dbo.P2PConnection AS pc
    ON s.subscriberID = pc.subscriberID
INNER JOIN dbo.Country AS c
    ON pc.recipientCountry = c.countryCode
WHERE c.countryName = 'Lithuania'
  AND pc.connectionStart >= '2013-10-01'
  AND pc.connectionStart < '2013-11-01'
GROUP BY
    s.subscriberID,
    p.firstName,
    p.lastName
ORDER BY
    number_of_calls DESC;


    
SELECT DISTINCT recipientCountry
FROM dbo.P2PConnection
ORDER BY recipientCountry;


SELECT
    recipientCountry,
    COUNT(*) AS number_of_calls
FROM dbo.P2PConnection
GROUP BY recipientCountry
ORDER BY recipientCountry;


SELECT TOP 20 *
FROM dbo.P2PConnection
WHERE recipientCountry IS NULL;



-- Task 9: Top 5 subscribers by domestic calls in October 2013

SELECT TOP 5
    s.subscriberID,
    CONCAT(p.firstName, ' ', p.lastName) AS full_name,
    COUNT(*) AS number_of_calls
FROM dbo.P2PConnection AS pc
INNER JOIN dbo.Subscriber AS s
    ON pc.subscriberID = s.subscriberID
INNER JOIN dbo.Person AS p
    ON s.personID = p.personID
WHERE pc.recipientCountry IS NULL
  AND pc.connectionStart >= '2013-10-01'
  AND pc.connectionStart <  '2013-11-01'
GROUP BY
    s.subscriberID,
    p.firstName,
    p.lastName
ORDER BY
    number_of_calls DESC;


-- ==========================================
-- 10. Most popular foreign country by number of call connections
-- ==========================================

SELECT TOP 1 WITH TIES
    c.countryName,
    COUNT(*) AS totalCalls
FROM dbo.P2PConnection p2p
INNER JOIN dbo.Country c ON p2p.recipientCountry = c.countryCode
WHERE c.countryName <> 'Lithuania'
GROUP BY c.countryCode, c.countryName
ORDER BY totalCalls DESC;