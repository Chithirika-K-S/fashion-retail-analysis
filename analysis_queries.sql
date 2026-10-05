-- ============================================================
-- Fashion Retail Sales & Returns Analysis
-- Dataset: fashion_boutique (Retail Fashion Boutique Data Sales Analytics 2025)
-- Tool: SQLite (DB Browser for SQLite)
-- ============================================================


-- ============================================================
-- SECTION 1: DATA CLEANING CHECKS
-- ============================================================

-- 1.1 Check for duplicate product_id
-- Groups rows by product_id and keeps only groups with more than 1 row.
-- Result: 0 rows returned -> no duplicates found.
SELECT product_id, COUNT(*) 
FROM fashion_boutique
GROUP BY product_id
HAVING COUNT(*) > 1;


-- 1.2 Count missing values per column
-- Uses CASE to flag NULLs as 1, then sums them up per column.
SELECT 
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
  SUM(CASE WHEN size IS NULL THEN 1 ELSE 0 END) AS missing_size,
  SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
  SUM(CASE WHEN current_price IS NULL THEN 1 ELSE 0 END) AS missing_price
FROM fashion_boutique;
-- Result: missing_category=0, missing_size=491, missing_rating=362, missing_price=0


-- 1.3 Check category spelling / label consistency
-- DISTINCT removes repeats, so this lists each unique category name once.
SELECT DISTINCT category FROM fashion_boutique ORDER BY category;
-- Result: Accessories, Bottoms, Dresses, Outerwear, Shoes, Tops (6 clean, distinct categories)


-- 1.4 Confirm missing sizes are concentrated in Accessories
SELECT category, COUNT(*) AS missing_size_count
FROM fashion_boutique
WHERE size IS NULL
GROUP BY category;
-- Result: mostly Accessories, as expected (accessories don't have sizes)


-- ============================================================
-- SECTION 2: REVENUE ANALYSIS
-- ============================================================

-- 2.1 Revenue and items sold by category (excluding returns)
-- current_price = actual price paid after discount, so this is real revenue.
SELECT category, 
       ROUND(SUM(current_price), 2) AS revenue,
       COUNT(*) AS items_sold
FROM fashion_boutique
WHERE is_returned = 0
GROUP BY category
ORDER BY revenue DESC;
-- Result: Outerwear highest revenue (41,141.43) despite fewest items sold (280)
--         Accessories most items sold (347) but lowest revenue (15,058.94)


-- 2.2 Revenue lost to discounts, by category
-- Compares original_price (listed) vs current_price (actual) to find the markdown gap.
SELECT category,
       ROUND(SUM(original_price), 2) AS revenue_at_full_price,
       ROUND(SUM(current_price), 2) AS actual_revenue,
       ROUND(SUM(original_price) - SUM(current_price), 2) AS revenue_lost_to_discounts
FROM fashion_boutique
WHERE is_returned = 0
GROUP BY category
ORDER BY revenue_lost_to_discounts DESC;
-- Result: Shoes has the highest discount rate (~13%); Outerwear the lowest (~10%)


-- ============================================================
-- SECTION 3: SEASONAL / TIME TREND ANALYSIS
-- ============================================================

-- 3.1 Monthly revenue trend
-- strftime extracts just year-month from the full date, grouping sales by month.
SELECT strftime('%Y-%m', purchase_date) AS month,
       ROUND(SUM(current_price), 2) AS revenue
FROM fashion_boutique
WHERE is_returned = 0
GROUP BY month
ORDER BY month;
-- Result: August was the highest-revenue month


-- 3.2 Revenue by season, with average price per item
SELECT season,
       ROUND(SUM(current_price), 2) AS revenue,
       COUNT(*) AS items_sold,
       ROUND(SUM(current_price) / COUNT(*), 2) AS avg_price_per_item
FROM fashion_boutique
WHERE is_returned = 0
GROUP BY season
ORDER BY revenue DESC;
-- Result: Fall highest (41,994.89), Winter lowest (37,336.11) - fairly even overall (~12% spread)


-- ============================================================
-- SECTION 4: RETURN ANALYSIS
-- ============================================================

-- 4.1 Return rate by category
-- is_returned is 1/0 (or TRUE/FALSE), so SUM counts how many were returned.
SELECT category,
       COUNT(*) AS total_orders,
       SUM(is_returned) AS returns,
       ROUND(100.0 * SUM(is_returned) / COUNT(*), 1) AS return_rate_pct
FROM fashion_boutique
GROUP BY category
ORDER BY return_rate_pct DESC;
-- Result: Outerwear highest (16.2%), Tops lowest (12.8%)


-- 4.2 Top return reason, per category (using a window function)
-- RANK() OVER (PARTITION BY category ...) ranks reasons separately within each category.
-- Outer WHERE rnk = 1 keeps only the #1 reason per category.
SELECT category, return_reason, count
FROM (
  SELECT category, return_reason, COUNT(*) AS count,
         RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rnk
  FROM fashion_boutique
  WHERE is_returned = 1
  GROUP BY category, return_reason
)
WHERE rnk = 1
ORDER BY category;
-- Result: "Changed Mind" leads in 3/6 categories; "Quality Issue" is top/joint-top 
--         in Dresses and Tops (a cross-category pattern)


-- 4.3 Return reasons specifically for Outerwear
SELECT return_reason, COUNT(*) AS count
FROM fashion_boutique
WHERE category = 'Outerwear' AND is_returned = 1
GROUP BY return_reason
ORDER BY count DESC;
-- Result: Changed Mind (13), Size Issue (12), Quality Issue (12) - 
--         Size + Quality issues = 44% of Outerwear returns


-- 4.4 Average customer rating by category
SELECT category, ROUND(AVG(customer_rating), 2) AS avg_rating, COUNT(*) AS rated_items
FROM fashion_boutique
WHERE customer_rating IS NOT NULL
GROUP BY category
ORDER BY avg_rating DESC;
-- Result: Shoes highest (3.05), Outerwear lowest (2.91) - 
--         matches Outerwear's high return rate finding


-- ============================================================
-- SECTION 5: SIZE-LEVEL ANALYSIS (Outerwear & Dresses)
-- ============================================================
-- Note: the detailed size breakdown (total vs non-returned per size) 
-- was done in Excel using Pivot Tables, filtering category + is_returned,
-- with size in Rows and product_id (Count) in Values.
--
-- Key results:
-- Outerwear size L: 55 total orders, 13 returned -> 23.6% return rate 
--   (highest of any Outerwear size; category average is 16.2%)
-- Dress size XL: 71 total orders, 62 not returned -> 87.3% keep rate 
--   (best volume AND best keep rate among Dress sizes)
-- Dress size S: 52 total orders, 43 not returned -> 17.3% return rate 
--   (highest return rate among Dress sizes)

-- Equivalent SQL version of this analysis, for reference:
SELECT category, size,
       COUNT(*) AS total_orders,
       SUM(is_returned) AS returns,
       ROUND(100.0 * SUM(is_returned) / COUNT(*), 1) AS return_rate_pct
FROM fashion_boutique
WHERE category IN ('Outerwear', 'Dresses') AND size IS NOT NULL
GROUP BY category, size
ORDER BY category, return_rate_pct DESC;
