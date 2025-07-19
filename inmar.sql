WITH ranked_date AS ( -- Use window function to sort and add a row number for each Creation DateTime per RedemptionDate, being row_num 1 the mowst recent
  SELECT retailerId, redemptionDate, reds.redemptionCount,reds.createDateTime, row_number() over(PARTITION BY redemptionDate ORDER BY reds.createDateTime DESC) AS row_num
  -- added "_fix" at the end to add the 0 counts of 23/11/02; tblRedemptions-ByDay_fixtblRedemptions-ByDay
  FROM `reporting.tblRedemptions-ByDay_fix` reds JOIN `reporting.tblRetailers` retailer
    ON reds.retailerId = retailer.id
  WHERE retailerName = 'ABC Store'
  GROUP BY 1, 2, 3, 4
), min_redemptions AS ( --find the minimum redemption count, to use as the JOIN key for question #1
  SELECT MIN(redemptionCount) AS redemptionCount
  FROM ranked_date
  WHERE row_num = 1
    AND redemptionDate Between date('2023-10-30') AND date('2023-11-05')
), max_redemptions AS ( --find the maximum redemption count, to use as the JOIN key for question #2
  SELECT MAX(redemptionCount) AS redemptionCount
  FROM ranked_date
  WHERE row_num = 1
    AND redemptionDate Between date('2023-10-30') AND date('2023-11-05')
)

-- Main task query:
SELECT redemptionDate, redemptionCount
FROM ranked_date
WHERE row_num = 1 -- This filters the most recent redemption count from the first tempral table
  AND redemptionDate Between date('2023-10-30') AND date('2023-11-05')
ORDER BY 1 ASC

--1. Which date had the least number of redemptions and what was the redemption count?
/*
    SELECT redemptionDate, rd.redemptionCount, createDateTime
    FROM ranked_date rd JOIN min_redemptions minr
    ON rd.redemptionCount = minr.redemptionCount
    WHERE rd.row_num = 1
    --  2023-11-02; 0 -- Excercise before INSERT: 2023-11-05;3702
    -- Creation: 2023-11-06 (Doesn't change with future insert)
*/

--2. Which date had the most number of redemptions and what was the redemption count?
/*
    SELECT redemptionDate, rd.redemptionCount, createDateTime
    FROM ranked_date rd JOIN max_redemptions maxr
    ON rd.redemptionCount = maxr.redemptionCount
    WHERE rd.row_num = 1
    --  2023-11-04; 5224
    -- Creation: 2023-11-05
*/

--3. What was the createDateTime for each redemptionCount in questions 1 and 2?
/*
  --1. 2023-11-06
  --2. 2023-11-05
*/

--4. Is there another method you can use to pull back the most recent redemption count, by redemption date, 
    --for the date range 2023-10-30 to 2023-11-05, for retailer "ABC Store"? In words, describe how you would do this 
    --(no need to write a query, unless you’d like to)
/*
    Yes. Instead of creating a temporal table, a less straight forward way would be creating a view that pulls 
    the max(createDateTime) for each redemptionDate, then joining that back to the original table to get the redemptionCount's.
    This would avoid the need for row_number() and would still give the most recent redemption count per date, but with a longer
    and more confusing query (might be less efficient as well).
*/