-- Library Management System

--create branch table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
                    branch_id VARCHAR(10) PRIMARY KEY,
					manager_id	VARCHAR(10),
					branch_address	VARCHAR(55),
					contact_no VARCHAR(20)
					);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
                    emp_id	VARCHAR(10) PRIMARY KEY,
					emp_name VARCHAR(25),	
					position VARCHAR(25),
					salary	INT,
					branch_id VARCHAR(25) --FK
                    );

DROP TABLE IF EXISTS books;
CREATE TABLE books (
                    isbn VARCHAR(20) PRIMARY KEY,
					book_title VARCHAR(75),
					category VARCHAR(20),	
					rental_price FLOAT,	
					status VARCHAR(15),	
					author VARCHAR(35),
					publisher VARCHAR(55)
                    );

DROP TABLE IF EXISTS members;
CREATE TABLE members (
                    member_id VARCHAR(20) PRIMARY KEY,
					member_name	VARCHAR(35),
					member_address VARCHAR(75),	
					reg_date DATE
					);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
                    issued_id VARCHAR(10) PRIMARY KEY,
					issued_member_id VARCHAR(10), 
					issued_book_name VARCHAR(75),
					issued_date	DATE,
					issued_book_isbn VARCHAR(35),
					issued_emp_id VARCHAR(10)
                    );

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
                    return_id VARCHAR(10) PRIMARY KEY,	
					issued_id VARCHAR(10),	--FK
					return_book_name VARCHAR(75),	
					return_date	DATE,
					return_book_isbn VARCHAR(20) --FK
                    );

--FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

--Project Task

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status 
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT m.member_name
FROM members m
INNER JOIN issued_status ist ON m.member_id = ist.issued_member_id
GROUP BY 1
HAVING COUNT(*) > 1;

--CTAs
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_cnts
AS 
SELECT b.book_title, COUNT(*) as issued_cnts 
FROM books b
INNER JOIN issued_status ist ON b.isbn = ist.issued_book_isbn
GROUP BY 1;			 )

SELECT *
FROM book_cnts;

-- Task 7. Retrieve All Books in a Specific Category
SELECT *
FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category and number of times issued
SELECT category, SUM(rental_price) as total_rental_income, COUNT(*) as no_of_times_issued
FROM books b
INNER JOIN issued_status ist ON b.isbn = ist.issued_book_isbn 
GROUP BY 1
ORDER BY 2 DESC;

-- Task 9: List Members Who Registered in the Last 180 Days
INSERT INTO members
VALUES
('C131','Cersei','165 Road St','2025-06-05'),
('C132','Aemon','154 King St','2025-06-05');

SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL'180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details
SELECT e1.*, b.manager_id, e2.emp_name as manager
FROM employees as e1
JOIN branch as b ON b.branch_id = e1.branch_id
JOIN employees as e2 ON e2.emp_id = b.manager_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD
CREATE TABLE books_price_greater_than_sevenusd
AS
SELECT *
FROM books
WHERE rental_price > 7

SELECT *
FROM books_price_greater_than_sevenusd;


-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT issued_book_name
FROM issued_status ist
LEFT JOIN return_status rst ON ist.issued_id=rst.issued_id
WHERE return_id ISNULL


/* 
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT ist.issued_member_id, m.member_name, b.book_title, ist.issued_date,
       CURRENT_DATE - ist.issued_date as days_overdue
FROM issued_status ist 
JOIN members m 
ON m.member_id = ist.issued_member_id
JOIN books b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status rst
ON rst.issued_id = ist.issued_id
WHERE return_date ISNULL
      AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

/* 
Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE branch_reports
AS
SELECT br.branch_id, br.manager_id, 
       COUNT(ist.issued_id) as number_book_issued,
	   COUNT(rst.return_id) as number_of_book_return,
	   SUM(b.rental_price) as total_revenue
FROM issued_status ist
JOIN employees e
ON e.emp_id = ist.issued_emp_id
JOIN branch br
ON e.branch_id = br.branch_id
LEFT JOIN return_status rst
ON rst.issued_id = ist.issued_id
JOIN books b
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT *
FROM branch_reports;

/* Task 15: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT DISTINCT issued_member_id
                    FROM issued_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month');

SELECT * 
FROM active_members;

/* Task 16: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT e.emp_name,
       br.*,
       COUNT(ist.issued_id) as no_book_issued
FROM issued_status ist
JOIN employees e
ON e.emp_id = ist.issued_emp_id
JOIN branch br
ON e.branch_id = br.branch_id
GROUP BY 1,2;

---------------------------------------------------END PROJECT--------------------------------------------------------
