-- Explore Data with SELECT ALL statement
select *
from payment;

-- Stored Procedure Example
-- Simulating a late fee charge
create or replace procedure late_fee(
	customer INTEGER, -- customer_id
	late_payment INTEGER, -- payment_id
	late_fee_amount numeric(5,2) -- increase the amount column by this value
)
language plpgsql -- procedural language postgresql -- stores the language for the procedure for you and other developers
as $$ -- stores the actual query to the procedure, stores as a string literal to exceucte query when the procedure is called, not stored
begin 
	-- use the customer_id and payment_id to alter amount column
	update payment
	set amount = amount + late_fee_amount
	where customer_id = customer and payment_id = late_payment; -- matching the customer id to our customer argument and payment_id to the late_payment argument;
end;
$$

-- calling a procedure
-- customer_id 341
-- payment_id 17503
-- late_fee_amount 2.00  
call late_fee(341, 17503, 2.00);

-- query for specific payment_id for late_fee additions
select *
from payment 
where payment_id = 17503;

-- another example, this time, get wrecked
call late_fee(347, 17529, 8.00);

select *
from payment 
where payment_id = 17529;

drop procedure late_fee; -- drop procedure, no longer in the function folder

-- what's good in the hood with our actors
select *
from actor 
order by actor_id desc;

-- stored function
-- create a function to add an actor to the actor table 
create or replace function add_actor(
	_actor_id INTEGER,
	_first_name VARCHAR(30),
	_last_name VARCHAR(30),
	_last_update TIMESTAMP
)
returns void -- datatype the function is going to return -- void bc we are adding to table
as $main$
begin
	insert into actor
	values(_actor_id, _first_name, _last_name, _last_update);
end;
$main$
language plpgsql;

-- DO NOT CALL FUNCTION, SELECT FUNCTION --
select add_actor(242, 'Alex MF', 'Huynh Baby', NOW()::timestamp);

select *
from actor 
order by actor_id desc;

select add_actor(201, 'Jessica', 'Alba', NOW()::timestamp);
select add_actor(202, 'Emma', 'Watson', NOW()::timestamp);
select add_actor(203, 'Halle', 'Berry', NOW()::timestamp);
select add_actor(204, 'Shakira', 'Shakira', NOW()::timestamp);


select *
from payment 
order by amount desc;

-- function with a return value
-- setting return type to integer
create or replace function get_total_rentals()
returns integer
as $$
begin
	return (select sum(amount) from payment);
end;
$$
language plpgsql;

select get_total_rentals()


-- function avg
create or replace function get_avg_amount()
returns decimal
as $$
begin
	return (select avg(amount) from payment);
end;
$$
language plpgsql;

select get_avg_amount()

select *
from payment
where amount > get_avg_amount()

-- create a function that gives discounts
create or replace function get_discount(price numeric, percentage integer)
returns integer
as $$ 
begin 
	return (price * percentage/100);
end;
$$
language plpgsql;

select get_discount(4.99, 50)

create or replace procedure apply_discount(percentage integer, _payment_id integer)
as $$
begin 
	update payment 
	set amount = get_discount(payment.amount, percentage)
	where payment_id = _payment_id;
end;
$$
language plpgsql;

select *
from payment
order by amount desc;

-- payment_id 24866

call apply_discount(50,24866);

select *
from payment
where payment_id = 24866

