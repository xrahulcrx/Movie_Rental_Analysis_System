# Movie Rental OLAP Analysis (PostgreSQL)

### Perform advanced analysis on movie rental data using OLAP operations. 


## 1. About the Project

This SQL project includes:

Creating a database and table

Inserting sample rental transaction data

Running OLAP queries

Analyzing rental behavior by genre, customer, movie, and months

## 2. Database Setup
Create Database

CREATE DATABASE MovieRental;

Create Table:

create table rental_data (
							movie_id int not null,
							customer_id int not null,
							genre varchar(20) not null,
							rental_date date not null,
							return_date date,
							rental_fee decimal(10, 2) not null check (rental_fee >= 0)						
);


Insert Sample Data

(15 sample rows included in SQL file)

OLAP Operations Demonstrated
----------------------------

### a) Drill Down: Analyze rentals from genre to individual movie level. 

select movie_id, genre, count(*) as rentals, sum(rental_fee) as revenue
from rental_data
group by genre, movie_id
order by genre, revenue desc



### b) Rollup: Summarize total rental fees by genre and then overall. 

select  coalesce(genre, 'All Genres') as genre_list, count(*) as rentals, round(sum(rental_fee), 2) as revenue
from rental_data
group by rollup (genre)
order by revenue desc nulls last; 

### Cube: Analyze total rental fees across combinations of genre, rental date, and customer. 

### v1 : using date

select 
    genre,
    DATE_TRUNC('month', rental_date)::date AS rental_month,
    customer_id,
    sum(rental_fee) as total_revenue
from rental_data
group by cube (genre, rental_month, customer_id)
order by genre, rental_month, customer_id;



### v2 using month year -  optimised

select coalesce(genre, 'ZAll Genre') as  genre_list,
		coalesce(to_char(date_trunc('Month', rental_date), 'Mon YYYY'), 'All months') as month_year, 
		coalesce(customer_id::text, 'All customer') as customer_id, 
		round(sum(rental_fee),2) as revenue
from rental_data
group by cube(genre, date_trunc('Month', rental_date), customer_id)
order by genre_list, date_trunc('Month', rental_date), customer_id;


### d) Slice: Extract rentals only from the ‘Action’ genre. 

select customer_id, rental_date, rental_fee
from rental_data
where genre = 'Action'
order by rental_date


### e) Dice: Extract rentals where GENRE = 'Action' or 'Drama' and RENTAL_DATE is in the last 3 months.

select movie_id, customer_id, genre, rental_date, coalesce(return_date::text, 'Yet to return') as return_date, rental_fee
from rental_data
where genre in ('Action', 'Drama') and rental_date >= current_date - interval '3 months'
order by genre, rental_date desc;


