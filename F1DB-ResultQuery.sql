use F1;

-- Countries with highest accumulated points:
SELECT drivers.driver_nationality , 
SUM(results.driver_points) AS 'Total Points'
        FROM drivers
        JOIN results ON drivers.driver_id = results.driver_id
        GROUP BY drivers.driver_nationality
        HAVING SUM(results.driver_points) > 0
        ORDER BY SUM(results.driver_points) DESC;

-- All time points leaders with their nationality:
SELECT drivers.driver_fname AS 'First Name', 
        drivers.driver_sname AS 'Last Name', 
        drivers.driver_nationality AS 'Nationality', 
        SUM(results.driver_points) AS 'Total Points'
        FROM drivers
        JOIN results ON drivers.driver_id = results.driver_id
        GROUP BY drivers.driver_id
        ORDER BY SUM(results.driver_points) DESC;

-- Total number of first position of all the drivers:
WITH first_position AS(
SELECT * FROM results
WHERE 1 = 1
AND finish_position = '1'
)
SELECT drivers.driver_fname, drivers.driver_sname, 
       COUNT(*) AS wins FROM first_position 
       INNER JOIN drivers 
       ON first_position.driver_id = drivers.driver_id
WHERE 1 = 1
GROUP BY drivers.driver_fname, drivers.driver_sname
ORDER BY COUNT(*) DESC;

-- Driver with most number of retirements:
WITH retirement_data AS(
SELECT driver_id, COUNT(finish_position) AS Number_Of_Retirements FROM results
WHERE 1 = 1
AND finish_position = 'R'
GROUP BY driver_id
ORDER BY COUNT(finish_position) DESC
)

SELECT retirement_data.*, drivers.driver_fname, drivers.driver_sname, drivers.driver_nationality FROM retirement_data 
INNER JOIN drivers 
ON drivers.driver_id = retirement_data.driver_id
ORDER BY Number_Of_Retirements DESC;

-- Constructor and Driver pairing:
WITH pairing AS(
SELECT DISTINCT driver_id, constructor_id FROM results
)

SELECT drivers.driver_fname, drivers.driver_sname, drivers.driver_nationality 
AS driver_nationality, constructors.constructor_name, 
constructors.constructor_nationality AS constructor_nationality 
FROM drivers INNER JOIN pairing 
ON drivers.driver_id = pairing.driver_id
INNER JOIN constructors 
ON constructors.constructor_id = pairing.constructor_id
ORDER BY drivers.driver_fname, drivers.driver_sname;

-- Count of Driver nationalities:
SELECT driver_nationality, COUNT(*) AS number_of_drivers
FROM drivers
GROUP BY driver_nationality
ORDER BY COUNT(*) DESC;

-- Fastest Lap speed in each circuit ever and the driver
WITH fastestspeed AS(
SELECT race_id, MAX(fastestLapSpeed) AS fastestLapSpeed FROM results
WHERE 1 = 1
AND fastestLapSpeed != ''
GROUP BY race_id
ORDER BY race_id 
)

SELECT results.driver_id, results.race_id, results.fastestLapSpeed, drivers.driver_fname, drivers.driver_sname
FROM results 
INNER JOIN fastestspeed 
ON fastestspeed.fastestLapSpeed = results.fastestLapSpeed
INNER JOIN drivers 
ON drivers.driver_id = results.driver_id
INNER JOIN race
ON results.race_id = race.race_id
INNER JOIN circuits 
ON circuits.circuit_id = race.circuit_id
ORDER BY race.race_id ;


-- Return drivers with fastest laps:
SELECT drivers.driver_fname
FROM drivers
WHERE driver_id = ANY
  (SELECT driver_id
  FROM lap_time
  WHERE milliseconds < 89000);




