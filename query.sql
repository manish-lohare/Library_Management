select * from books
select * from branch
select * from members
select * from employees
select * from issued_status
select * from return_status

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
select * from books

--Task 2: Update an Existing Member's Address
update members
set member_address='144 Main St'
where member_id='C119'
select * from members

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id='IS121'
select * from issued_status

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id='E101'

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select * , count(*) from issued_status
group by 1
having count(*)>1

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_issued_cnt as
select b.isbn,b.book_title,count(ist.issued_id) as issued_count
from books as b
join issued_status as ist
on b.isbn=ist.issued_book_isbn
group by b.isbn,b.book_title
select * from book_issued_cnt

--Task 7. Retrieve All Books in a Specific Category:
select* from books
where category='Classic'

--Task 8: Find Total Rental Income by Category:
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

--Task9:List Members Who Registered in the Last 180 Days:
select * from members
where reg_date >= current_date -interval '180 days'

--Task10:List Employees with Their Branch Manager's Name and their branch details:
select e.emp_id,e.emp_name,e.position,e.salary,b.*,e2.emp_name
from employees as e
join branch as b
on e.branch_id=b.branch_id
join employees as e2
on e2.emp_id=b.manager_id

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
create table Rent as
select * from books
where rental_price::numeric>7.0
select* from Rent

--Task 12: Retrieve the List of Books Not Yet Returned
select i.*
from issued_status as i
left join return_status as r
on i.issued_id = r.issued_id
where r.return_id is null


