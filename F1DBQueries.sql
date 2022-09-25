create database if not exists f1;
use f1;

-- F1 circuits
drop table if exists  circuits;
CREATE TABLE circuits(
circuit_id INT,
circuit_ref VARCHAR(100),
circuit_name VARCHAR(100),
circuit_location VARCHAR(50),
circuit_country VARCHAR(50),
circuit_lat DECIMAL(8,4),
circuit_lng DECIMAL(8,4),
circuit_alt INT,
PRIMARY KEY(circuit_id)
);

SELECT * from circuits;

-- constructors
drop table if exists  constructors;
CREATE TABLE constructors(
constructor_id INT,
constructor_ref VARCHAR(100),
constructor_name VARCHAR(100),
constructor_nationality VARCHAR(100),
PRIMARY KEY(constructor_id)
);

SELECT * from constructors;

-- constructor results
drop table if exists  constructor_results;
CREATE TABLE constructor_results(
constructor_result_id INT,
race_id INT,
constructor_id INT,
constructor_points INT,
constructor_status VARCHAR(20),
PRIMARY KEY(constructor_result_id),
FOREIGN KEY(constructor_id) REFERENCES constructors(constructor_id)
);

SELECT * from constructor_results;

-- drivers
drop table if exists  drivers;
CREATE TABLE drivers(
driver_id INT,
driver_ref VARCHAR(100),
driver_number INT,
driver_fname VARCHAR(20),
driver_sname VARCHAR(20),
driver_dob VARCHAR(20),
driver_nationality VARCHAR(50),
PRIMARY KEY(driver_id)
);

SELECT * from drivers;

-- drivers results
drop table if exists  driver_results;
CREATE TABLE driver_results(
driver_results_id INT,
race_id INT,
driver_id INT,
driver_points INT,
driver_position INT,
driver_wins INT,
PRIMARY KEY(driver_results_id),
UNIQUE KEY(race_id, driver_id)
);

SELECT * from driver_results;

-- lap times
drop table if exists  lap_time;
CREATE TABLE lap_time(
race_id INT,
driver_id INT,
laps_no INT,
driver_position INT,
lap_time VARCHAR(25),
milliseconds INT,
PRIMARY KEY(race_id, driver_id, laps_no),
FOREIGN KEY(race_id, driver_id) REFERENCES driver_results(race_id, driver_id)
);

SELECT * from lap_time;

-- qualifying
drop table if exists  qualifying;
CREATE TABLE qualifying(
qualifying_id INT,
race_id INT,
driver_id INT,
constructor_id INT,
driver_position INT,
Q1 VARCHAR(25),
Q2 VARCHAR(25),
Q3 VARCHAR(25),
PRIMARY KEY(qualifying_id),
UNIQUE KEY(race_id, driver_id,constructor_id)
);

SELECT * from qualifying;

-- race
drop table if exists  race;
CREATE TABLE race(
race_id INT,
race_year VARCHAR(10),
race_round INT,
circuit_id INT,
circuit_name VARCHAR(50),
PRIMARY KEY(race_id),
FOREIGN KEY(circuit_id) REFERENCES circuits(circuit_id)
);

SELECT * from race;

-- results
drop table if exists  results;
CREATE TABLE results(
results_id INT,
race_id INT,
driver_id INT,
constructor_id INT,
grid_position INT,
driver_position INT,
finish_position CHAR(5),
driver_points INT,
fastestLapTime VARCHAR(25),
fastestLapSpeed VARCHAR(25),
lap_no INT,
PRIMARY KEY(results_id),
FOREIGN KEY(race_id) REFERENCES race(race_id),
FOREIGN KEY(driver_id) REFERENCES drivers(driver_id),
FOREIGN KEY(constructor_id) REFERENCES constructors(constructor_id),
FOREIGN KEY(race_id, driver_id, constructor_id) REFERENCES qualifying(race_id, driver_id, constructor_id) ,
FOREIGN KEY(race_id, driver_id) REFERENCES driver_results(race_id, driver_id) 
);
