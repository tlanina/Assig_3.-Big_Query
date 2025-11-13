## Megogo Data Warehouse
This project builds a Data Warehouse for the Megogo streaming platform using Google BigQuery.
The goal is to structure and clean viewing, user, and movie data for analysis and reporting.

## Data flows from the RAW layer, where it is stored as uploaded,
to the STAGE layer, where missing values are replaced with NULL and duplicates are removed.
Clean data is then loaded into DIM tables that describe users, movies, devices, and subscriptions.
The FACT table connects all dimensions and stores viewing activity with minutes watched and dates.
MART tables are created for analysis, such as most popular genres, top movies, and active countries.

## Layers
RAW – source data
STAGE – cleaned data
DIM – descriptive tables
FACT – measurable events
MART – summary analytics

## Bonus Task: SCD Type 2
Implemented Slowly Changing Dimension Type 2 for the DimMovie table
to keep the history of rating changes over time. When a movie’s rating changes, the current record is “closed” by setting its end_date to the previous day, and a new record is inserted with the updated rating and a new start_date.

# Team: assig_LBM
# Members: Mariia Nosulko, Tanya Lanina, Maryna Bondar
