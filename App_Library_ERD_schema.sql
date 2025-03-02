-- Library Management
-- branch table
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
