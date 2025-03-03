# Library_Management
## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`
This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/manish-lohare/Library_Management/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/manish-lohare/Library_Management/blob/main/EDR.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
drop table if exists branch;
create table branch
	(
		branch_id varchar(10) primary key,
		manager_id varchar(10),
		branch_address varchar(50),
		contact_no varchar(20)
	)

drop table if exists books;
create table books 
	(
		isbn varchar(20) primary key,
		book_title varchar(50),
		category varchar(20),
		rental_price varchar(20),
		status varchar(20),
		author	varchar(50),
		publisher varchar(50)

	)

drop table if exists employees;
create table employees
	(
		emp_id varchar(10) primary key,
		emp_name varchar(20),
		position varchar(20),
		salary varchar(10),
		branch_id varchar(10)

	)

drop table if exists issued_status;
create table issued_status
	(
		issued_id varchar(10) primary key,
		issued_member_id varchar(10),
		issued_book_name varchar(50),
		issued_date date,
		issued_book_isbn varchar(50),
		issued_emp_id varchar(10)
	)

drop table if exists members;
create table members
	(
		member_id varchar(10) primary key,
		member_name varchar(20),
		member_address varchar(50),
		reg_date date

	)

drop table if exists return_status;
create table return_status
	(
		return_id varchar(10) primary key,
		issued_id varchar(10),
		return_book_name varchar(50),
		return_date date,
		return_book_isbn varchar(50)

	)

-- Foreign Key
alter table issued_status
add constraint fk_member
foreign key (issued_member_id)
references members(member_id)

alter table issued_status 
add constraint fk_employees
foreign key(issued_emp_id)
references employees(emp_id)

alter table issued_status
add constraint fk_books
foreign key(issued_book_isbn)
references books(isbn)

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id)

alter table return_status
add constraint fk_issued_status
foreign key(issued_id)
references issued_status(issued_id)

alter table return_status
add constraint fk_return_status
foreign key(return_book_isbn)
references books(isbn) 
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
select * from books
```

**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address='144 Main St'
where member_id='C119'
select * from members
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status
where issued_id='IS121'
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from issued_status
where issued_emp_id='E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select * , count(*) from issued_status
group by 1
having count(*)>1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_issued_cnt as
select b.isbn,b.book_title,count(ist.issued_id) as issued_count
from books as b
join issued_status as ist
on b.isbn=ist.issued_book_isbn
group by b.isbn,b.book_title
```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select* from books
where category='Classic'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,
    SUM(b.rental_price::NUMERIC),  -- Convert using shorthand
    COUNT(*)
FROM 
    books AS b
JOIN
    issued_status AS ist
ON 
    b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select * from members
where reg_date >= current_date -interval '180 days'
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e.emp_id,e.emp_name,e.position,e.salary,b.*,e2.emp_name
from employees as e
join branch as b
on e.branch_id=b.branch_id
join employees as e2
on e2.emp_id=b.manager_id
```


Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table Rent as
select * from books
where rental_price::numeric>7.0
select* from Rent
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select i.*
from issued_status as i
left join return_status as r
on i.issued_id = r.issued_id
where r.return_id is null
```
## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
```sql
select 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	--rts.return_date,
	current_date-ist.issued_date as overdue
from issued_status as ist
join members as m
on ist.issued_member_id=m.member_id
join books as bk
on ist.issued_book_isbn=bk.isbn
left join return_status as rts
on ist.issued_id=rts.issued_id
where rts.return_date is null
	and (current_date-ist.issued_date)>30
order by ist.issued_member_id


```
**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
```sql
--manual process
select * from books
select * from issued_status
select * from return_status

select * from issued_status
where issued_book_isbn='978-0-375-41398-8'

select * from return_status
where issued_id='IS134'

select * from books
where isbn='978-0-375-41398-8'

insert into return_status(return_id,issued_id,return_date,book_quality)
values('RS120','IS134',current_date,'good')

update books
set status='yes'
where isbn='978-0-375-41398-8'

--code 
create or replace procedure add_return_records(p_return_id varchar(10),p_issued_id varchar(10),p_book_quality varchar(20))
language plpgsql
as $$
declare
	v_isbn varchar(20);
	v_book_name varchar(90);
begin
--all logic and code
--inserting into returns based on user input
insert into return_status(return_id,issued_id,return_date,book_quality)
values
(p_return_id,p_issued_id,current_date,p_book_quality);


select
	issued_book_isbn,
	issued_book_name
	into
	v_isbn,
	v_book_name
from issued_status
where issued_id=p_issued_id;

update books
set status='yes'
where isbn=v_isbn;

raise notice'Thank you for returning the book : %',v_book_name;
end;
$$

--testing
/* issued_id=IS135
ISBN = WHERE isbn = '978-0-307-58837-1'
*/
select * from books
where isbn='978-0-307-58837-1'

select * from issued_status
where issued_book_isbn='978-0-307-58837-1'

select * from return_status
where issued_id='IS135'

--calling function
call add_return_records('RS138','IS135','good')
```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
```sql
select * from branch
select * from employees
select * from issued_status
select * from return_status

create table branch_report
as
	select 
		b.branch_id,
		b.manager_id,
		count(ist.issued_id) as issued_cnt,
		count(rts.return_id) as return_cnt,
		sum(bk.rental_price :: numeric) as total_revenue
	from branch as b
	join employees as e
	on b.branch_id=e.branch_id
	join issued_status as ist
	on ist.issued_emp_id=e.emp_id
	join books as bk
	on ist.issued_book_isbn=bk.isbn
	left join return_status as rts
	on ist.issued_id=rts.issued_id
	group by 1,2

```
**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
```sql
create table active_member as
	select * from
	members
	where member_id in (
		select issued_member_id from 
		issued_status
		where issued_date>= current_date-interval '2 month' 
	)


```
**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
```sql
select 
	e.emp_id,
	e.emp_name,
	count(ist.issued_member_id) as cnt_issued_book,
	b.branch_id
from employees as e
join issued_status as ist
on e.emp_id=ist.issued_emp_id
join branch as b
on b.branch_id=e.branch_id
group by e.emp_id,b.branch_id
order by cnt_issued_book desc
limit 3

```
