-- RAW LAYER 

CREATE OR REPLACE TABLE assig_LBM.raw_users (
  user_id INT64,
  signup_date DATE,
  country STRING,
  age_group STRING,
  gender STRING,
  subscription_plan STRING
);

CREATE OR REPLACE TABLE assig_LBM.raw_movies (
  movie_id INT64,
  title STRING,
  genre STRING,
  release_year INT64,
  duration_min INT64,
  production_company STRING,
  age_rating STRING,
  rating FLOAT64
);

CREATE OR REPLACE TABLE assig_LBM.raw_views (
  view_id INT64,
  user_id INT64,
  movie_id INT64,
  view_date DATE,
  minutes_watched INT64,
  device_type STRING
);

CREATE OR REPLACE TABLE assig_LBM.raw_subscriptions (
  subscription_id INT64,
  plan_name STRING,
  monthly_fee NUMERIC(10,2),
  quality STRING,
  start_date DATE,
  end_date DATE
);

CREATE OR REPLACE TABLE assig_LBM.raw_devices (
  device_id INT64,
  device_type STRING,
  platform STRING,
  os_name STRING
);

-- INSERT DATA

INSERT INTO assig_LBM.raw_users VALUES
(1001, '2023-01-01', 'Ukraine', '25-34', 'F', 'Base'),
(1002, '2023-02-15', 'Poland', '35-44', 'M', 'Premium'),
(1003, '2023-03-12', 'Ukraine', '', 'F', 'Base'),
(1004, '2023-03-20', 'Germany', '25-34', '', 'Family'),
(1005, '2023-04-10', 'France', '18-24', 'F', ''),
(1006, '2023-05-01', 'Ukraine', '25-34', 'M', 'Premium'),
(1007, '2023-06-22', '', '35-44', 'M', 'Base');

INSERT INTO assig_LBM.raw_movies VALUES
(2001, 'Avatar 2', 'Sci-Fi', 2022, 190, '20th Century Fox', 'PG-13', 8.9),
(2002, 'Barbie', 'Comedy', 2023, 114, 'Warner Bros', 'PG', 7.2),
(2003, 'Oppenheimer', 'Drama', 2023, 180, 'Universal', 'R', 9.3),
(2004, 'Inside Out 2', 'Animation', 2024, 105, 'Pixar', 'G', 8.4),
(2005, 'The Bachelor', 'Reality', 2025, 60, 'Megogo Originals', '', 9.9), 
(2006, 'Fast X', 'Action', 2023, 142, 'Universal', 'PG-13', 7.5),
(2007, 'Spider-Man: Across the Spider-Verse', 'Animation', 2023, 140, '', 'PG', 8.8);

INSERT INTO assig_LBM.raw_views VALUES
(1, 1001, 2001, '2024-09-01', 140, 'SmartTV'),
(2, 1001, 2003, '2024-09-03', 120, 'SmartTV'),
(3, 1002, 2002, '2024-09-02', 100, 'Mobile'),
(4, 1003, 2004, '2024-09-05', 80, 'Tablet'),
(5, 1004, 2003, '2024-09-06', 160, 'Laptop'),
(6, 1005, 2005, '2024-09-07', 60, 'SmartTV'),
(7, 1006, 2006, '2024-09-08', 120, 'Mobile'),
(8, 1007, 2007, '2024-09-09', 90, ''),
(9, 1002, 2005, '2024-09-10', 50, 'Tablet'),
(10, 1001, 2005, '2024-09-11', 60, '');

INSERT INTO assig_LBM.raw_subscriptions VALUES
(1, 'Base', 4.99, 'HD', '2023-01-01', '2023-12-31'),
(2, '', 9.99, '4K', '2023-02-15', '2023-12-31'),
(3, 'Family', 12.99, '4K', '2023-03-20', '2023-12-31'),
(4, 'Premium', 9.99, '', '2023-04-10', '2023-12-31');

INSERT INTO assig_LBM.raw_devices VALUES
(1, 'SmartTV', 'WebOS', 'Linux'),
(2, '', 'Android', ''),
(3, 'Tablet', '', 'iOS 17'),
(4, 'Laptop', 'Web', ''),
(5, 'Mobile', 'Android', 'Android 13');


-- STAGE LAYER 

CREATE OR REPLACE TABLE assig_LBM.stg_users AS
SELECT DISTINCT
  user_id,
  signup_date,
  NULLIF(country, '') AS country,
  NULLIF(age_group, '') AS age_group,
  NULLIF(gender, '') AS gender,
  NULLIF(subscription_plan, '') AS subscription_plan
FROM assig_LBM.raw_users;

CREATE OR REPLACE TABLE assig_LBM.stg_movies AS
SELECT DISTINCT
  movie_id,
  NULLIF(title, '') AS title,
  NULLIF(genre, '') AS genre,
  release_year,
  duration_min,
  NULLIF(production_company, '') AS production_company,
  NULLIF(age_rating, '') AS age_rating,
  rating
FROM assig_LBM.raw_movies;

CREATE OR REPLACE TABLE assig_LBM.stg_views AS
SELECT DISTINCT
  view_id,
  user_id,
  movie_id,
  view_date,
  minutes_watched,
  NULLIF(device_type, '') AS device_type
FROM assig_LBM.raw_views;

CREATE OR REPLACE TABLE assig_LBM.stg_subscriptions AS
SELECT DISTINCT
  subscription_id,
  NULLIF(plan_name, '') AS plan_name,
  monthly_fee,
  NULLIF(quality, '') AS quality,
  start_date,
  end_date
FROM assig_LBM.raw_subscriptions;

CREATE OR REPLACE TABLE assig_LBM.stg_devices AS
SELECT DISTINCT
  device_id,
  NULLIF(device_type, '') AS device_type,
  NULLIF(platform, '') AS platform,
  NULLIF(os_name, '') AS os_name
FROM assig_LBM.raw_devices;


-- DIMENSIONS

CREATE OR REPLACE TABLE assig_LBM.DimUser AS
SELECT * FROM assig_LBM.stg_users;

CREATE OR REPLACE TABLE assig_LBM.DimMovie AS
SELECT * FROM assig_LBM.stg_movies;

CREATE OR REPLACE TABLE assig_LBM.DimSubscription AS
SELECT * FROM assig_LBM.stg_subscriptions;

CREATE OR REPLACE TABLE assig_LBM.DimDevice AS
SELECT * FROM assig_LBM.stg_devices;


-- FACT TABLE

CREATE OR REPLACE TABLE assig_LBM.FactViews AS
SELECT * FROM assig_LBM.stg_views;


-- MART / ANALYTICS

-- Найпопулярніші жанри
CREATE OR REPLACE TABLE assig_LBM.mart_genre_popularity AS
SELECT 
  m.genre,
  COUNT(v.view_id) AS total_views,
  SUM(v.minutes_watched) AS total_minutes
FROM assig_LBM.FactViews v
JOIN assig_LBM.DimMovie m USING (movie_id)
GROUP BY m.genre
ORDER BY total_views DESC;

-- ТОП-5 фільмів за рейтингом
CREATE OR REPLACE TABLE assig_LBM.mart_top_rated_movies AS
SELECT 
  title,
  genre,
  rating
FROM assig_LBM.DimMovie
ORDER BY rating DESC
LIMIT 5;


-- Країни з найбільш активними користувачами
CREATE OR REPLACE TABLE assig_LBM.mart_active_countries AS
SELECT 
  u.country,
  COUNT(DISTINCT v.user_id) AS active_users,
  SUM(v.minutes_watched) AS total_minutes
FROM assig_LBM.FactViews v
JOIN assig_LBM.DimUser u USING (user_id)
GROUP BY u.country
ORDER BY active_users DESC;

-- Пристрої з найбільшим середнім часом перегляду
CREATE OR REPLACE TABLE assig_LBM.mart_device_usage AS
SELECT 
  v.device_type,
  ROUND(AVG(v.minutes_watched), 2) AS avg_watch_time,
  COUNT(v.view_id) AS total_sessions
FROM assig_LBM.FactViews v
GROUP BY v.device_type
ORDER BY avg_watch_time DESC;

-- Топ-3 користувачі за загальним часом перегляду
CREATE OR REPLACE TABLE assig_LBM.mart_top_users AS
SELECT 
  u.user_id,
  u.country,
  SUM(v.minutes_watched) AS total_minutes
FROM assig_LBM.FactViews v
JOIN assig_LBM.DimUser u USING (user_id)
GROUP BY u.user_id, u.country
ORDER BY total_minutes DESC
LIMIT 3;

-- Середній рейтинг фільмів за жанрами
CREATE OR REPLACE TABLE assig_LBM.mart_avg_rating_by_genre AS
SELECT 
  genre,
  ROUND(AVG(rating), 2) AS avg_rating
FROM assig_LBM.DimMovie
GROUP BY genre
ORDER BY avg_rating DESC;



--- BONUS TASK Slowly Changing Dimension
CREATE OR REPLACE TABLE assig_LBM.DimMovie_SCD AS
SELECT
  movie_id,
  title,
  genre,
  release_year,
  rating,
  CURRENT_DATE() AS start_date, 
  CAST(NULL AS DATE) AS end_date
FROM assig_LBM.DimMovie;

UPDATE assig_LBM.DimMovie_SCD
SET end_date = CURRENT_DATE() - 1
WHERE movie_id = 2001 AND end_date IS NULL;

INSERT INTO assig_LBM.DimMovie_SCD
SELECT
  movie_id,
  title,
  genre,
  release_year,
  9.1 AS rating,       
  CURRENT_DATE() AS start_date,
  NULL AS end_date
FROM assig_LBM.DimMovie
WHERE movie_id = 2001;
