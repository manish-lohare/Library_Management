select * from books
select * from members
select * from branch
select * from employees
select * from issued_status
select * from return_status


/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- join issued_status==members==books==return_status
-- filter those who have return book and overdue < 30 

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


/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/

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

--Task 15: Branch Performance Report
/*Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
-- join branch==employees==issued_status==return_status
--table used
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


/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 2 months.
*/
create table active_member as
	select * from
	members
	where member_id in (
		select issued_member_id from 
		issued_status
		where issued_date>= current_date-interval '2 month' 
	)


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
--table used
select * from branch
select * from employees
select * from issued_status

-- employees == issued_status == branch
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


/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.
*/
--table used
select * from issued_status
select * from return_status
select * from members
select * from books

	select 
		m.member_name,
		b.book_title,
		count(m.member_id) as cnt_issued_damage_book
	from return_status as rts
	join issued_status as ist
	on rts.issued_id=ist.issued_id
	join members as m
	on ist.issued_member_id=m.member_id
	join books as b
	on b.isbn=ist.issued_book_isbn
	where rts.book_quality='damage'
	group by 1,2
	having count(m.member_id)>2


	
/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, 
it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available.
*/

--table require
select * from books
select * from issued_status

create or replace procedure issue_book(p_issued_id varchar(10),p_issued_member_id varchar(10),p_issued_book_isbn varchar(50),p_issued_emp_id varchar(10))
language plpgsql
as $$
declare 
	v_status varchar(20);
begin
-- all code
	--checking if book book is available 'yes'
	select 
		status
		into 
		v_status
	from books
	where isbn=p_issued_book_isbn;

	if v_status='yes' then
		insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		values
		(p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn,p_issued_emp_id);

		update books
		set status='no'
		where isbn=p_issued_book_isbn;
		
		raise notice 'Book Record is added successfully for book isbn :%',p_issued_book_isbn;
	else
		raise notice 'Sorry Book is not available , book isbn :%',p_issued_book_isbn;
	end if;
end;
$$

--testing 
select * from books
select * from issued_status
-- "978-0-553-29698-2" -- 978-0-14-118776-1
-- "978-0-375-41398-8" -- no

call issue_book('IS158','C108','978-0-7432-7357-1','E104')
call issue_book('IS159','C108','978-0-141-44171-6','E104')


/*
Task 20: Create Table As Select (CTAS) Objective: 
Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books 
they have issued but not returned within 30 days. The table should include: 
The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/
--table used
select * from books
select * from issued_status
select * from return_status
select * from members

create table fines as
	select 
		m.member_id,
		count(ist.issued_id) as no_overdue_books,
		current_date-ist.issued_date as overdue,
		(current_date-ist.issued_date)*0.5 as total_fine
	from issued_status as ist
	join members as m
	on ist.issued_member_id=m.member_id
	join books as bk
	on ist.issued_book_isbn=bk.isbn
	left join return_status as rts
	on ist.issued_id=rts.issued_id
	where rts.return_date is null
		and (current_date-ist.issued_date)>30
	group by 1,overdue

