/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

Code:
SELECT name
FROM `Facilities`
WHERE membercost >0;


/* Q2: How many facilities do not charge a fee to members? */

Code:
SELECT COUNT( facid )
FROM `Facilities`
WHERE membercost >0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Code:
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance
AND membercost >0;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
Code:
SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 );

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

Code:
SELECT name,
CASE
WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END AS monthlymaintenance_label
FROM `Facilities`;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Code:
SELECT firstname, surname
FROM `Members`
WHERE memid = (
SELECT MAX( memid )
FROM `Members` );

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Code:
SELECT DISTINCT member_name,f.name
FROM Facilities AS f
INNER JOIN (

SELECT DISTINCT m.memid, b.facid, CONCAT( m.surname, ',', m.firstname ) AS member_name
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
) AS c ON f.facid = c.facid
WHERE f.name LIKE 'Tennis Court%'
ORDER BY member_name;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Code:
SELECT DISTINCT f.name AS facility_name, CONCAT( m.surname, ',', m.firstname ) AS member_name,
CASE WHEN f.facid =0
THEN f.guestcost * slots / 0.5
ELSE f.membercost * slots / 0.5
END AS cost
FROM (
(
Bookings AS b
INNER JOIN Facilities AS f
USING ( facid )
)
INNER JOIN Members AS m
USING ( memid )
)
WHERE b.starttime LIKE '2012-09-14%'
HAVING cost >30
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Code:
SELECT DISTINCT c.name AS facility_name, CONCAT( m.surname, ',', m.firstname ) AS member_name, c.cost
FROM Members AS m
INNER JOIN (

SELECT f.facid, f.name, f.membercost, f.guestcost, b.memid, b.starttime, slots,
CASE WHEN f.facid =0
THEN f.guestcost * slots / 0.5
ELSE f.membercost * slots / 0.5
END AS cost
FROM Facilities AS f
INNER JOIN Bookings AS b
USING ( facid )
WHERE b.starttime LIKE '2012-09-14%'
HAVING cost >30
) AS c
USING ( memid )
ORDER BY cost DESC;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Code: (with sqlite)
import sqlite3
conn = None
conn = sqlite3.connect('sqlite_db_pythonsqlite.db')
cur = conn.cursor()
print(cur)
#query1 = """SELECT * FROM FACILITIES"""
query1 = """SELECT DISTINCT 
m.surname || ',' || m.firstname  AS member_name,
CASE WHEN f.facid =0
THEN f.guestcost * slots / 0.5
ELSE f.membercost * slots / 0.5
END AS total_revenue
FROM (
(
Bookings AS b
INNER JOIN Facilities AS f
USING ( facid )
)
INNER JOIN Members AS m
USING ( memid )
)
Group BY member_name
HAVING total_revenue<1000
ORDER BY total_revenue DESC"""
cur.execute(query1)
rows = cur.fetchall()
for row in rows:
    print(row)
conn.close()

Code: (with Mysql)
SELECT CONCAT( m.surname, ',', m.firstname ) AS member_name,
CASE WHEN f.facid =0
THEN f.guestcost * slots / 0.5
ELSE f.membercost * slots / 0.5
END AS total_revenue
FROM (
(
Bookings AS b
INNER JOIN Facilities AS f
USING ( facid )
)
INNER JOIN Members AS m
USING ( memid )
)
GROUP BY member_name
HAVING total_revenue <1000
ORDER BY total_revenue DESC;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

Code: (with sqlite)
import sqlite3
conn = None
conn = sqlite3.connect('sqlite_db_pythonsqlite.db')
cur = conn.cursor()
query1 = """
SELECT m1.surname || ',' || m1.firstname  AS member_name, 
m2.surname || ',' || m2.firstname  AS recommended_name
FROM Members AS m1
LEFT JOIN Members AS m2
ON m1.recommendedby = m2.memid
ORDER BY member_name, recommended_name
"""
cur.execute(query1)
rows = cur.fetchall()
for row in rows:
    print(row)
conn.close()

Code: (with Mysql)
SELECT CONCAT(m1.surname,',',m1.firstname) AS member_name, 
CONCAT(m2.surname,',',m2.firstname) AS recommended_name
FROM Members AS m1
LEFT JOIN Members AS m2
ON m1.recommendedby = m2.memid
ORDER BY member_name, recommended_name


/* Q12: Find the facilities with their usage by member, but not guests */

Code: (with sqlite)
import sqlite3
conn = None
conn = sqlite3.connect('sqlite_db_pythonsqlite.db')
cur = conn.cursor()
query1="""
SELECT DISTINCT name AS facility_name
FROM Facilities AS f
INNER JOIN Bookings AS b
USING(facid)
WHERE b.memid <>0
"""
cur.execute(query1)
rows = cur.fetchall()
for row in rows:
    print(row)
conn.close()

Code: (with Mysql)
SELECT DISTINCT name AS facility_name
FROM Facilities AS f
INNER JOIN Bookings AS b
USING(facid)
WHERE b.memid <>0

/* Q13: Find the facilities usage by month, but not guests */

Code: (with sqlite)
import sqlite3
conn = None
conn = sqlite3.connect('sqlite_db_pythonsqlite.db')
cur = conn.cursor()
query1 = """
SELECT DISTINCT c.facility_name AS member_name, strftime('%m',m.joindate) AS facility_month
FROM Members AS m
INNER JOIN (
SELECT name AS facility_name, b.memid
FROM Facilities AS f
INNER JOIN Bookings AS b
USING(facid)
WHERE b.memid <>0) AS c
USING(memid)
ORDER BY member_name
"""
cur.execute(query1)
rows = cur.fetchall()
for row in rows:
    print(row)
conn.close()


Code: (with Mysql)
SELECT DISTINCT c.facility_name AS member_name, MONTH(m.joindate) AS facility_month
FROM Members AS m
INNER JOIN (
SELECT name AS facility_name, b.memid
FROM Facilities AS f
INNER JOIN Bookings AS b
USING(facid)
WHERE b.memid <>0) AS c
USING(memid)
ORDER BY member_name

