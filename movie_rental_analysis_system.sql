--Database created
create database MovieRental;

--Database verfication
select current_database();

--Creation of Table rental_data

create table rental_data (
							movie_id int not null,
							customer_id int not null,
							genre varchar(20) not null,
							rental_date date not null,
							return_date date check (return_date is null or return_date >= rental_date),
							rental_fee decimal(10, 2) not null check (rental_fee >= 0)						
);



insert into rental_data (movie_id, customer_id, genre, rental_date, return_date, rental_fee) values
							(101, 1, 'Action',   '2025-08-15', '2025-08-20', 5.99),
							(102, 2, 'Drama',    '2025-09-10', '2025-09-15', 4.99),
							(103, 1, 'Comedy',   '2025-10-05', '2025-10-08', 3.99),
							(104, 3, 'Action',   '2025-11-01', NULL, 7.99),
							(105, 4, 'Sci-Fi',   '2025-07-20', '2025-07-25', 6.99),
							(101, 2, 'Action',   '2025-10-20', '2025-10-25', 5.99),
							(106, 5, 'Drama',    '2025-11-15', NULL, 4.99),
							(107, 1, 'Comedy',   '2025-09-25', '2025-09-30', 8.99),
							(102, 3, 'Drama',    '2025-08-30', '2025-09-05', 4.99),
							(108, 6, 'Action',   '2025-11-20', NULL, 6.99),
							(109, 2, 'Sci-Fi',   '2025-10-10', '2025-10-15', 9.99),
							(103, 4, 'Comedy',   '2025-11-10', '2025-11-14', 3.99),
							(101, 5, 'Action',   '2025-09-18', '2025-09-22', 5.99),
							(106, 1, 'Drama',    '2025-10-30', NULL, 4.99),
							(110, 3, 'Horror',   '2025-11-25', NULL, 1.99);



							

select * from rental_data;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--#######################################################################################################
--OLAP Operations: 
--#######################################################################################################


-- a) Drill Down: Analyze rentals from genre to individual movie level. 

select movie_id, genre, count(*) as rentals, round(sum(rental_fee), 2) as revenue
from rental_data
group by genre, movie_id
order by genre, revenue desc;

-- b) Rollup: Summarize total rental fees by genre and then overall. 

select  coalesce(genre, 'All Genres') as genre_list, count(*) as rentals, round(sum(rental_fee), 2) as revenue
from rental_data
group by rollup (genre)
order by grouping(genre), revenue desc nulls last; 


-- c) Cube: Analyze total rental fees across combinations of genre, rental date, and customer. 

-- v1 : using date

select 
    genre,
    date_trunc('month', rental_date)::date AS rental_month,
    customer_id,
    sum(rental_fee) as total_revenue
from rental_data
group by cube (genre, rental_month, customer_id)
order by grouping(genre), grouping(date_trunc('month', rental_date)::date), grouping(customer_id),
		genre, rental_month, customer_id;



-- v2 using month year -  optimised

select coalesce(genre, 'All Genre') as  genre_list,
		coalesce(to_char(date_trunc('Month', rental_date), 'Mon YYYY'), 'All months') as month_year, 
		coalesce(customer_id::text, 'All customer') as customer_id, 
		round(sum(rental_fee),2) as revenue
from rental_data
group by cube(genre, date_trunc('Month', rental_date), customer_id)
order by grouping(genre), grouping(date_trunc('Month', rental_date)), grouping(customer_id),
		genre, date_trunc('Month', rental_date) nulls first, customer_id;


-- d) Slice: Extract rentals only from the ‘Action’ genre. 

select customer_id, movie_id, rental_date, rental_fee, coalesce(return_date::text, 'Yet to return') as return_date 
from rental_data
where genre = 'Action'
order by rental_date desc;


-- e) Dice: Extract rentals where GENRE = 'Action' or 'Drama' and RENTAL_DATE is in the last 3 months.

select movie_id, customer_id, genre, rental_date, coalesce(return_date::text, 'Yet to return') as return_date, rental_fee
from rental_data
where genre in ('Action', 'Drama') and rental_date >= (current_date - interval '3 months')
order by genre, rental_date desc;







