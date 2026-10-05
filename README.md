# Fashion Retail Sales & Returns Analysis

## Objective
Analyze a fashion boutique's sales data to understand revenue drivers, return patterns, and seasonal trends, and provide data-backed recommendations on stocking and quality control.

## Dataset
- Source: [Kaggle - Retail Fashion Boutique Data Sales Analytics 2025](https://www.kaggle.com/datasets/pratyushpuri/retail-fashion-boutique-data-sales-analytics-2025)
- ~2,000 transaction records
- Columns: product_id, category, brand, season, size, color, original_price, markdown_percentage, current_price, purchase_date, stock_quantity, customer_rating, is_returned, return_reason

## Tools Used
- SQL (SQLite, via DB Browser for SQLite)
- Excel (Pivot Tables, Charts)
- Power BI (Dashboard)

## Data Cleaning
Full details in [cleaning_log.md](./cleaning_log.md). Summary:
| Check | Result | Action |
|---|---|---|
| Duplicate product_id | None found | No action needed |
| Category spelling consistency | 6 clean categories | No action needed |
| Missing size (491 rows) | Mostly Accessories | Kept as blank; excluded from size-based analysis |
| Missing rating (362 rows) | Unrated items | Excluded from rating averages, not guessed |

## Key Questions Explored
- Which categories generate the most revenue?
- How much revenue is lost to discounts, by category?
- Is there a seasonal sales pattern?
- Which categories and sizes have the highest return rates?
- What are the most common return reasons, and do they repeat across categories?
- Which size/color combinations sell best, and which have the best "keep rate" (low returns)?

All queries are in [analysis_queries.sql](./analysis_queries.sql).

## Key Findings
1. **Outerwear drives the most revenue (₹41,141) despite the fewest items sold (280)** — indicating a high price-per-item category, averaging ~₹147/item versus ~₹43/item for Accessories.
2. **Outerwear also has the highest return rate (16.2%) and lowest average rating (2.91)** of any category. Within Outerwear, **size L alone has a 23.6% return rate**, well above the category's other sizes (13–18%), pointing to a specific sizing issue in that size.
3. **"Quality Issue" is a top or joint-top return reason in multiple categories** (Dresses, Tops), not isolated to one category, suggesting a cross-category quality control gap rather than a single product problem.
4. **Revenue is fairly even across seasons** (within ~12% of each other), with Fall slightly ahead — a mild rather than sharp seasonal pattern.
5. **Dress size XL has both the highest order volume (71) and the best keep rate (87.3%)**, making it the strongest candidate for increased stock, while size S has the highest return rate (17.3%) among Dress sizes.

## Recommendations
- Review the size chart / fit for Outerwear size L specifically, given its disproportionately high return rate.
- Investigate quality control processes for categories with repeated "Quality Issue" returns (Dresses, Tops).
- Prioritize stock and marketing for Dress size XL ahead of high-demand periods.
- Consider that Outerwear's premium pricing is justified by demand, but its low rating/high returns suggest the product may not be meeting buyer expectations despite selling well.

## Dashboard
See `fashion_dashboard.pbix` or the screenshots in `/screenshots` for the Power BI dashboard, including revenue by category, return rate by category, revenue by season, and average rating by category.

## Files in This Repo
- `README.md` — this file
- `cleaning_log.md` — detailed data cleaning decisions and reasoning
- `analysis_queries.sql` — all SQL queries used, with comments
- `visulatization.pbix` — Power BI dashboard file
- `/screenshots` — chart and dashboard images
