# Data Cleaning Log

**Dataset:** fashion_boutique (Retail Fashion Boutique Data Sales Analytics 2025)
**Tool used:** SQL (SQLite, via DB Browser for SQLite)
**Total rows:** ~2,000

This log documents every data quality check performed, what was found, and the reasoning behind each decision. No row was deleted or filled with a guessed value; missing data was investigated first, then either explained or clearly flagged.

---

## 1. Duplicate Records

**Check:**
```sql
SELECT product_id, COUNT(*) 
FROM fashion_boutique
GROUP BY product_id
HAVING COUNT(*) > 1;
```

**Result:** 0 rows returned.

**Decision:** No action needed.

**Reasoning:** No `product_id` appears more than once in the dataset, so there are no duplicate transaction records to remove.

---

## 2. Category Label Consistency

**Check:**
```sql
SELECT DISTINCT category FROM fashion_boutique ORDER BY category;
```

**Result:** 6 clean, distinct values — Accessories, Bottoms, Dresses, Outerwear, Shoes, Tops.

**Decision:** No action needed.

**Reasoning:** No inconsistent spelling or near-duplicate labels (e.g. "Tshirt" vs "T-Shirt") were found. Category names are already standardized.

---

## 3. Missing Values

**Check:**
```sql
SELECT 
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
  SUM(CASE WHEN size IS NULL THEN 1 ELSE 0 END) AS missing_size,
  SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
  SUM(CASE WHEN current_price IS NULL THEN 1 ELSE 0 END) AS missing_price
FROM fashion_boutique;
```

**Result:**

| Column | Missing count |
|---|---|
| category | 0 |
| size | 491 |
| customer_rating | 362 |
| current_price | 0 |

### 3.1 Missing `size` (491 rows)

**Follow-up check:**
```sql
SELECT category, COUNT(*) AS missing_size_count
FROM fashion_boutique
WHERE size IS NULL
GROUP BY category;
```

**Result:** The large majority of missing sizes fall under the Accessories category.

**Decision:** Kept as blank (not filled or guessed). Excluded from any size-based analysis (e.g. "best-selling size per category").

**Reasoning:** This is expected, not an error — accessories (bags, belts, jewelry, etc.) typically don't have a standard clothing size, so a blank value here is correct, not missing data in the problematic sense.

### 3.2 Missing `size` in Dresses (14–17 rows)

**Decision:** Kept as blank. Excluded from size-based analysis. Flagged as unexplained rather than assumed.

**Reasoning:** Unlike Accessories, Dresses would normally be expected to have a size recorded. A small number of blanks here (14 when filtered to non-returned items, 17 across all records) don't have an obvious explanation from the data alone — it could be a data entry gap or "one size fits all" items. Rather than guess, this was left as an open note rather than resolved with an assumption.

### 3.3 Missing `customer_rating` (362 rows)

**Decision:** Excluded from all rating-based calculations (e.g. average rating by category). Not filled with a guessed value (such as the column average).

**Reasoning:** A missing rating most likely means the customer never left a rating — it is not a numeric measurement that failed to record, so filling it with an average or a zero would misrepresent customer sentiment that was never actually given. Treating it as "no opinion provided" and excluding it from rating averages is the more honest approach.

### 3.4 Missing `category` and `current_price`

**Result:** 0 missing in both columns.

**Decision:** No action needed — fully populated.

---

## Summary Table

| Issue checked | Rows affected | Action taken | Reasoning |
|---|---|---|---|
| Duplicate product_id | 0 | None needed | Confirmed via GROUP BY + HAVING COUNT(*) > 1 |
| Category spelling consistency | 0 | None needed | Confirmed via DISTINCT + ORDER BY — 6 clean categories |
| Missing size (overall) | 491 | Kept blank; excluded from size-based analysis | Mostly Accessories, which don't have sizes — expected |
| Missing size (Dresses specifically) | 14–17 | Kept blank; excluded from size-based analysis | No clear cause found; flagged rather than assumed |
| Missing customer_rating | 362 | Excluded from rating averages | Likely unrated items; not filled with a guessed value |
| Missing category / current_price | 0 | None needed | Fully populated |

---

## Principle Applied

Missing data was not automatically deleted or filled. Each case was investigated to understand *why* the value was missing before deciding how to handle it — excluding it only from the specific analyses where it would cause a misleading result, while keeping the row for every other valid column (e.g. a row missing `size` was still included in revenue and category totals).
