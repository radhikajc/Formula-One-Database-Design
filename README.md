# Formula-One-Database-Design

## Business Problem & Design:
Formula One Racing is in need of an database system to record racing outcomes based on past
race data. Each season, two primary championships are contested, the World Constructors’
Championship and the World Drivers’ Championship. 10 teams compete for the World
Constructors' Championship and each team has 2 drivers competing for the World Drivers’
Championship. Each race comprises of a weekend (three days) in host country. First day of the
weekend has two “free” practice sessions, second days begins with a third “free” practice
followed by qualifying race which decides the grid position for race day. Third day which is a
Sunday is race day.

The purpose of this database design is to build a database encompassing data from the Formula
One racing seasons. A user will be able to query this database to answer several basic questions
“Who has won the most races?” or “What are the current team standings?” or “Who has qualified
in the top ten the most times during this season?”. The data model will help visualize the data
and aid in identifying the relationships that exist between the different groups.

<img width="457" alt="image" src="https://user-images.githubusercontent.com/103969912/192170499-63bc9403-a604-41c9-b42a-55b74e7285f0.png">

In implementing this database, the following must be noted:
1. A season comprises of 19-20 races spread across different countries and circuits. The
Championship is awarded at the end of a season depending on the performance of a
driver across the season.
2. Performance of each car/driver varies across circuits as each individual model has its own
strengths and weaknesses which are tested across these circuits.
3. The two main events in a race is the Qualifying session, that decides the position from
which a driver starts the race on race day and the Race day itself where the performance
of the driver decides their position in Championship standing.
4. The outcome of the constructer result is directly related to the performance of the drivers
as the points allotted to the constructer is as per the representing drivers finish position in
the race.

## ER Diagram:

<img width="450" alt="image" src="https://user-images.githubusercontent.com/103969912/192170526-0d69e4c1-844d-47ca-94da-a81e5993a26f.png">

## UML Diagram:

<img width="468" alt="image" src="https://user-images.githubusercontent.com/103969912/192170558-f3d10b2e-e2ac-4dd4-af5c-dc7db13790a5.png">

### Relational Model (primary keys are underlined; foreign keys are in italics)

* Circuit (Circuit_ID, Circuit_name, Circuit_location, Circuit_country, Circuit_lat, Circuit_long, Circuit_alt)

* Race (Race_ID, Circuit_ID, Race_date, Race_name, Race_time, Race_round, Race_year)

* Driver (Driver_ID, Driver_DOB, Driver_reference, Driver_fname, Driver_lname,
Driver_nationality, Driver_code)

* Constructor (Constructor_ID, Constructor_nationality, Constructor_reference,
Constructor_name)

* Race_Driver (Result_Id, Driver_ID)

* Constructor_Driver (Constructor_ID, Driver_ID)

* Constructor_Race(Constructor_ID,Race_ID)

* Constructor_Results (Constructor_Results_ID, Race_ID, Constructor_ID,
Constructor_points, Constructor_status)

* Driver_Results (Driver_Results_ID, Race_ID, Driver_ID, Driver_points,
Driver_position, Driver_wins)

* Results ( Result_Id, Driver_ID, Race_ID, Constructor_ID, Grid_position,
Driver_position, Finish_position, Driver_points, FastestLapTime, FastestLapSpeed)

### Implementation of Relation Model via MySQL:
The database was created in MySQL and the following queries were performed:

Query 1: Countries with highest accumulated points:
SELECT driver.driver_nationality ,
SUM(results.driver_points) AS 'Total Points'
FROM driver
JOIN results ON driver.driver_id = results.driver_id
GROUP BY driver.driver_nationality
HAVING SUM(results.driver_points) > 0
ORDER BY SUM(results.driver_points) DESC;

<img width="199" alt="image" src="https://user-images.githubusercontent.com/103969912/192170636-17618159-3cc9-4f83-bf0c-2cecb9340d8d.png">


Query 2: All time points leaders with their nationality:
SELECT driver.driver_fname AS 'First Name',
driver.driver_lname AS 'Last Name',
driver.driver_nationality AS 'Nationality',
SUM(results.driver_points) AS 'Total Points'
FROM driver
JOIN results ON driver.driver_id = results.driver_id
GROUP BY driver.driver_id
ORDER BY SUM(results.driver_points) DESC;

<img width="346" alt="image" src="https://user-images.githubusercontent.com/103969912/192170649-0b818a95-2ea7-497a-9a19-cf3e8fa7cc48.png">

Query 3: Find the total number of first position secured by all drivers:

WITH first_position AS(
SELECT * FROM results
WHERE 1 = 1
AND finish_position = '1')
SELECT drivers.driver_fname, drivers.driver_sname, 
       COUNT(*) AS wins FROM first_position 
       INNER JOIN drivers 
       ON first_position.driver_id = drivers.driver_id
WHERE 1 = 1
GROUP BY drivers.driver_fname, drivers.driver_sname
ORDER BY COUNT(*) DESC;

![image](https://user-images.githubusercontent.com/103969912/192170708-68e76819-3cc6-4c14-8738-68dfd990b461.png)

Query 4: Find the Driver with most number of retirements:

WITH retirement_data AS(
SELECT driver_id, COUNT(finish_position) 
AS Number_Of_Retirements FROM results
WHERE 1 = 1
AND finish_position = 'R'
GROUP BY driver_id
ORDER BY COUNT(finish_position) DESC)

SELECT retirement_data.*, drivers.driver_fname, drivers.driver_sname, drivers.driver_nationality FROM retirement_data 
INNER JOIN drivers 
ON drivers.driver_id = retirement_data.driver_id
ORDER BY Number_Of_Retirements DESC;

<img width="468" alt="image" src="https://user-images.githubusercontent.com/103969912/192170730-46a2148a-60c1-4278-a37b-310c9e34453e.png">

Query 5: Find the Constructor and Driver pairing:

WITH pairing AS(
SELECT DISTINCT driver_id, constructor_id FROM results)

SELECT drivers.driver_fname, drivers.driver_sname, drivers.driver_nationality 
AS driver_nationality, constructors.constructor_name, 
constructors.constructor_nationality AS constructor_nationality 
FROM drivers INNER JOIN pairing 
ON drivers.driver_id = pairing.driver_id
INNER JOIN constructors 
ON constructors.constructor_id = pairing.constructor_id
ORDER BY drivers.driver_fname, drivers.driver_sname;


<img width="468" alt="image" src="https://user-images.githubusercontent.com/103969912/192170755-4d3617f0-dbb8-4c8d-b853-0238cf43f54a.png">


Query 6: Find the Count of Driver nationalities:

SELECT driver_nationality, COUNT(*) AS number_of_drivers
FROM drivers
GROUP BY driver_nationality
ORDER BY COUNT(*) DESC;

<img width="232" alt="image" src="https://user-images.githubusercontent.com/103969912/192170770-6665665d-7219-465e-9445-7d7084e937b6.png">

Query 7: Find the Fastest Lap speed in each circuit and for each driver:

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

<img width="308" alt="image" src="https://user-images.githubusercontent.com/103969912/192170801-348cebda-7bec-48db-9c90-a2b2278cb5b8.png">


Query 8: Return drivers with fastest laps:

SELECT drivers.driver_fname
FROM drivers
WHERE driver_id = ANY
  (SELECT driver_id
  FROM lap_time
  WHERE milliseconds < 89000);
  
  <img width="150" alt="image" src="https://user-images.githubusercontent.com/103969912/192170821-b220104b-f914-4e94-b06b-101c4e43726c.png">


<img width="568" alt="image" src="https://user-images.githubusercontent.com/103969912/192170831-8865413e-95bd-468c-a57f-7fa4a26d7830.png">

## Data Visualization Using Python:
The schema that we created in SQL workbench was connected to python in our local platform by
using the pymysql.

Following queries were executed:

1) All the constructors that made their drivers to take part in the more than 100 races

query:
"""WITH greatest_100 AS
(SELECT c.constructor_id, c.constructor_name, d.driver_fname, d.driver_lname, d.driver_id,
count(*) AS counts
FROM driver AS d INNER JOIN constructor_drivers AS cd
ON d.driver_id=cd.driver_id INNER JOIN constructor AS c
ON c.constructor_id=cd.constructor_id
GROUP BY c.constructor_name, d.driver_id
HAVING count(*) > 100
ORDER BY count(*) DESC)
SELECT constructor_name, sum(counts) AS Counted FROM greatest_100
GROUP BY constructor_name
ORDER BY Counted
"""

<img width="553" alt="image" src="https://user-images.githubusercontent.com/103969912/192170872-daa4ca5d-5085-4894-be17-b39b03f72a3f.png">

2) Countries that hosted races and the number of races hosted:

query:

"""select c.circuit_country, c.circuit_lat, c.circuit_long, count(r.race_id)
from race as r left join circuit c
on r.circuit_id=c.circuit_id
group by c.circuit_country"""

<img width="580" alt="image" src="https://user-images.githubusercontent.com/103969912/192170909-459f3854-7669-49a1-a98b-df23ba21a752.png">

3) The total drivers representing their respecting nation at F1:

query:

"""SELECT driver_nationality, COUNT(*) AS number_of_drivers
FROM driver
GROUP BY driver_nationality
ORDER BY COUNT(*) DESC;"""

<img width="586" alt="image" src="https://user-images.githubusercontent.com/103969912/192170930-74fa979c-cfdc-4855-99a6-ab6b8ba6493d.png">


4)The total drivers representing their respecting nation at F1 with the number of drivers in
that country being higher that the average number of drivers:

<img width="601" alt="image" src="https://user-images.githubusercontent.com/103969912/192170948-eeda9a61-6611-40ff-8b73-bdf423a162a2.png">


Summary and Recommendation:
• The Formula One database designed on MySQL is a relational database that can be
implemented across the sports industry.

• It can help eager data miners and other curious students explore analytics capabilities.

• Improvement on the database would be the implementation more features to give more
accurate responses on user queries.

• The shortcoming would in the NoSQL implementation of this Database. More study
should be done on how a unique relational database like this can be implemented in a
NoSQL environment.
