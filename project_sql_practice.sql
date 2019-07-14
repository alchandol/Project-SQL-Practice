/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name, membercost FROM Facilities WHERE membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) FROM Facilities WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost,monthlymaintenance FROM Facilities WHERE membercost > 0 AND membercost < (monthlymaintenance * 0.2)


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM Facilities WHERE facid IN(1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,monthlymaintenance, 
CASE WHEN monthlymaintenance <= 100 THEN 'cheap' 
WHEN monthlymaintenance > 100 THEN 'expensive' 
ELSE NULL END AS ischeap FROM Facilities 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */


SELECT firstname,surname from Members a
INNER JOIN (SELECT max(joindate) as max_date from Members) b 
ON a.joindate = b.max_date



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(firstname,' ',surname) AS name, B.facname from Members A INNER JOIN (
    SELECT DISTINCT memid, 
    CASE WHEN facid =0 THEN  'Tennis Court 1'
    WHEN facid =1 THEN  'Tennis Court 2' 
    ELSE NULL END AS facname 
    FROM  `Bookings` WHERE facid IN ( 0, 1 ) ) B 
ON A.memid = B.memid
ORDER BY name



/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT(M.firstname, ' ', M.surname) AS membername, F.name,
CASE WHEN B.memid = 0 THEN F.guestcost * B.slots ELSE F.membercost * B.slots END AS costs FROM Bookings AS B 
LEFT JOIN Facilities AS F ON F.facid = B.facid 
INNER JOIN Members AS M ON M.memid = B.memid 
WHERE B.starttime LIKE '2012-09-14%' AND ((B.memid = 0 AND F.guestcost * B.slots > 30) OR (B.memid != 0 AND F.membercost * B.slots > 30))
ORDER BY costs DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT CONCAT(firstname, ' ', surname) AS mem_name, FF.name, FF.costs FROM Members AS M INNER JOIN (
    SELECT F.name , B.memid, 
    CASE WHEN B.memid = 0 THEN F.guestcost * B.slots 
    ELSE F.membercost * B.slots END AS costs FROM Facilities AS F 
    INNER JOIN (
        SELECT * FROM Bookings WHERE starttime LIKE '2012-09-14%') B 
    ON F.facid = B.facid) AS FF 
ON FF.memid = M.memid
WHERE FF.costs > 30
ORDER BY FF.costs DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT F.name, SUM(FF.costs) FROM Facilities AS F LEFT JOIN (
    SELECT F.facid, F.name, 
    CASE WHEN B.memid = 0 THEN F.guestcost * B.slots 
    ELSE F.membercost * B.slots END AS COSTS
    FROM Facilities AS F
    INNER JOIN Bookings AS B
    ON F.facid = B.facid 
) FF ON F.facid = FF.facid
GROUP BY F.name
HAVING SUM(FF.costs) < 1000
ORDER BY SUM(FF.costs) ASC


