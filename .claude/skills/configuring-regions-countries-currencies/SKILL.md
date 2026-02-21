---
name: configuring-regions-countries-currencies
description: Use when setting up regions, configuring countries, or handling multi-currency scenarios.
---

Use when setting up regions, configuring countries, or handling multi-currency scenarios.

# Configuring Regions, Countries, and Currencies

## Data Relationship

- **Store** defines eligible currencies
- **Region** is collection of countries shopping in same currency
- **Countries** can only be in single region

## URL-based Country Tracking

Keep country in URL: `/dk/products` -> ships to Denmark

## Region Context

Pass region_id or currency_code when fetching prices.

**IMPORTANT**: Use region context for features like free shipping thresholds.