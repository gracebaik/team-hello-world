-- Remove previous project tables and views
DROP VIEW IF EXISTS v_student_profiles CASCADE;
DROP TABLE IF EXISTS availability_slots, raw_class_dataset_staging, student_availability, student_skills, student_tools, students, tools CASCADE;-- 1. Clean up existing tables for safe execution
DROP TABLE IF EXISTS nypd_complaints CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. Placeholder User Table (stores personnel/analyst info)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age INT CHECK (age >= 0),
    role VARCHAR(50) DEFAULT 'analyst',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Core Dataset Table (NYPD Complaints Data)
CREATE TABLE nypd_complaints (
    complaint_id BIGINT PRIMARY KEY,
    reported_by_user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    complaint_date DATE NOT NULL,
    complaint_time TIME NOT NULL,
    hour INT CHECK (hour BETWEEN 0 AND 23),
    time_block VARCHAR(50),
    offense VARCHAR(100) NOT NULL,
    law_category VARCHAR(50),
    premises VARCHAR(100),
    location_of_occurrence VARCHAR(50),
    park VARCHAR(100),
    precinct INT,
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Seed Data (Includes placeholder users & sample rows from your dataset)
INSERT INTO users (full_name, age, role) VALUES
('Alex Rivera', 28, 'Data Analyst'),
('Sam Chen', 34, 'Precinct Officer');

INSERT INTO nypd_complaints (
    complaint_id, reported_by_user_id, complaint_date, complaint_time, hour,
    time_block, offense, law_category, premises, location_of_occurrence, park, precinct, latitude, longitude
) VALUES
(327390569, 1, '2026-06-30', '21:17:00', 21, 'Evening (6pm-12am)',  'PETIT LARCENY',       'MISDEMEANOR', 'DRUG STORE',           'INSIDE', NULL,                     6, 40.728617,   -74.000058),
(327356412, 1, '2026-06-30', '09:50:00',  9, 'Morning (6am-12pm)',  'PETIT LARCENY',       'MISDEMEANOR', 'DRUG STORE',           'INSIDE', NULL,                     6, 40.732628,   -74.000291),
(327334589, 2, '2026-06-30', '00:40:00',  0, 'Late night (12-6am)', 'FELONY ASSAULT',      'FELONY',      'GROCERY/BODEGA',      'INSIDE', NULL,                     6, 40.726877,   -73.995558),
(327386059, 2, '2026-06-30', '17:00:00', 17, 'Afternoon (12-6pm)', 'GRAND LARCENY',       'FELONY',      'PARK/PLAYGROUND',     NULL,     'WASHINGTON SQUARE PARK', 6, 40.730606,   -73.997738),
(327386060, 1, '2026-06-30', '20:38:00', 20, 'Evening (6pm-12am)',  'ADMINISTRATIVE CODE', 'VIOLATION',   'TRANSIT - NYC SUBWAY', NULL,     NULL,                     6, 40.73170654, -74.00095616);