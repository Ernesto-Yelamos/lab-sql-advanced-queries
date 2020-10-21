# Lab | SQL Advanced queries
# In this lab, you will be using the Sakila database of movie rentals.
use sakila;
set sql_safe_updates=0;
SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

### Instructions
	-- 1. List each pair of actors that have worked together.
select * from sakila.film_actor;
select * from sakila.actor;

select a.actor_id, b.actor_id from sakila.film_actor as a
join sakila.film_actor as b on b.film_id = a.film_id and a.actor_id <> b.actor_id
group by a.actor_id, b.actor_id;

select a1.actor_id, fa1.film_id, concat(a1.first_name, ' ', a1.last_name) as 'actor 1', a2.actor_id, concat(a2.first_name, ' ', a2.last_name) as 'actor 2' from sakila.actor as a1
join sakila.film_actor as fa1 on a1.actor_id = fa1.actor_id
join sakila.film_actor as fa2 on (fa1.film_id = fa2.film_id) and (fa1.actor_id <> fa2.actor_id)
join sakila.actor as a2 on a2.actor_id = fa2.actor_id
group by a1.actor_id, a2.actor_id
order by a1.actor_id, a2.actor_id;

/*
select a1.actor_id, concat(an1.first_name,' ‘,an1.last_name) as actor_1, a2.actor_id, concat(an2.first_name,’ ’,an2.last_name) as actor_2 from sakila.film_actor as a1
join sakila.film_actor as a2 on a2.film_id = a1.film_id and a1.actor_id < a2.actor_id
join sakila.actor as an1 on an1.actor_id = a1.actor_id
join sakila.actor as an2 on an2.actor_id = a2.actor_id
group by a1.actor_id, a2.actor_id
order by a1.actor_id, a2.actor_id;
*/

	-- 2. For each film, list actor that has acted in more films.
# Checking necessary tables.
select * from sakila.film_actor;
select * from sakila.actor;
select * from sakila.film;

# Amount of films each actor has appeared in.
select actor_id, count(film_id) as amount_film from sakila.film_actor
group by actor_id
order by actor_id;

# Amount of films each actor has appeared in with names of actors.
select concat(b.first_name, ' ', b.last_name) as 'Name Actor', count(film_id) as 'Amount Films' from sakila.film_actor as a
join sakila.actor as b on a.actor_id = b.actor_id
group by a.actor_id;
    
# Create view that returns the film, the actors that were in it, and the amount of films that each actor has worked in.
drop view film_film_actor;
create view film_film_actor as

with cte_af as 
	(select actor_id, count(film_id) as amount_film from sakila.film_actor
    group by actor_id
    order by actor_id)

select fa.film_id, f.title, fa.actor_id, concat(a.first_name, ' ', a.last_name) as Name_Actor,
cte.amount_film
from sakila.film_actor as fa
right join sakila.film as f on f.film_id = fa.film_id
right join sakila.actor as a on a.actor_id = fa.actor_id
right join cte_af as cte on cte.actor_id = a.actor_id
order by fa.film_id, f.title, amount_film desc;

select * from film_film_actor;

# Query to get the rank (which has been in most films) of actors per film using the create view table.
select film_id, title, Name_Actor, dense_rank() over (partition by film_id order by amount_film desc) as 'rank' from film_film_actor;

# Query to be able to use rank in the where clause.
select title, Name_Actor from 
(
	select film_id, title, Name_Actor, dense_rank() over (partition by film_id order by amount_film desc) as 'ranking' from film_film_actor
) as sub
where ranking = 1
order by title;
