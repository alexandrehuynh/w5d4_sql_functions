ALTER TABLE customer
ADD phone_number VARCHAR(15);

ALTER TABLE order_
ADD order_quantity INTEGER,
ADD staff_first VARCHAR(50),
ADD staff_last VARCHAR(50),
ADD price INTEGER

ALTER TABLE order_
  ALTER COLUMN price TYPE NUMERIC(5,2);

UPDATE customer
SET phone_number = '773-202-LUNA'
WHERE first_name = 'George' AND last_name = 'Washington'

UPDATE order_
SET order_quantity = 3, staff_first = 'Rod', staff_last = 'Kimble', price = '250.00'
WHERE order_id = 1

CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(100)
);

ALTER TABLE staff 
DROP COLUMN email;

ALTER TABLE staff 
DROP COLUMN staff_id CASCADE; -- removes dependencies associated with column

DROP TABLE staff;


-- Explore Data with SELECT ALL statement
SELECT *
FROM payment;

-- Stored Procedure Example
-- Simulating a late fee charge

CREATE OR REPLACE PROCEDURE lateFee(
	customer INTEGER, -- customer id
	latePayment INTEGER, -- payment id
	lateFeeAmount DECIMAL -- amount for latefee
	
)
LANGUAGE plpgsql -- gets stored and this lets other users know what language the procedures are written in
AS $$ -- literal string quoting, we dont want to run it right away, takes it as a string of text, then runs when we call the --procedure
BEGIN
	-- Add late fee to customer payment amount
	UPDATE payment
	SET amount = amount + lateFeeAmount
	WHERE customer_id = customer AND payment_id = latePayment;
	
	-- Commit the above statement inside of a transaction
	COMMIT;
	
END;
$$

-- procedures are stored on the left column

-- Calling a Stored Procedure
CALL lateFee(341, 17504, 2.00);


-- Validate the late fee has been posted
SELECT *
FROM payment
WHERE customer_id = 341;

-- DELETE/DROP newly created stored procedure
DROP PROCEDURE latefee;





--- Stored Functions Example
-- Stored Function to insert data into the actor table

CREATE OR REPLACE FUNCTION add_actor(_actor_id INTEGER, _first_name VARCHAR, _last_name VARCHAR, _last_update TIMESTAMP WITHOUT TIME ZONE)
RETURNS void -- can return datatype but in this case we are inserting to a table
AS $MAIN$ -- naming the string literal that will be called with the function call
BEGIN
	INSERT INTO actor
	VALUES(_actor_id, _first_name, _last_name, _last_update);
END;
$MAIN$
LANGUAGE plpgsql;

-- DO NOT 'CALL' A FUNCTION -- SELECT IT 
--Bad Call of Function
-- CALL add_actor(500,'Orlando', 'Bloom', CURRENT_TIMESTAMP);

-- Good Call of Function
SELECT add_actor(500,'Orlando', 'Bloom', NOW()::timestamp);

-- Verify that new actor has been added
SELECT *
FROM actor
WHERE actor_id = 500;

-- You can call a function inside a procedure but not a procedure inside a function


-- DELETE/DROP Stored Function
DROP FUNCTION add_actor;

CREATE OR REPLACE FUNCTION add_actor3(actor_id INTEGER, first_name VARCHAR, last_name VARCHAR)
									 
RETURNS void
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO actor
		VALUES(actor_id, first_name, last_name);
		
END;
$MAIN$

SELECT add_actor3(503, 'Elijah');

SELECT *
FROM actor
WHERE actor_id = 502;

CREATE OR REPLACE FUNCTION add_actor4(actor_id INTEGER, first_name VARCHAR)
									 
RETURNS void 
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO actor
		VALUES(actor_id, first_name);
		
END;
$MAIN$

SELECT add_actor4(503, 'Elijah')

-- Presidents Example
CREATE OR REPLACE FUNCTION add_president(pres_id INTEGER, first_name VARCHAR)
									 
RETURNS void 
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO customer
		VALUES(pres_id, first_name);
		
END;
$MAIN$

SELECT *
FROM customer;

SELECT add_president(10, 'Barack');

CREATE FUNCTION get_total_rentals()
RETURNS INTEGER
AS $$
    BEGIN
        RETURN (SELECT SUM(amount) FROM payment);
    END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION get_discount(price NUMERIC, percentage INTEGER)
RETURNS INTEGER
AS $$
    BEGIN
        RETURN (price * percentage/100);
    END;
$$ LANGUAGE plpgsql;


CREATE PROCEDURE apply_discount(percentage INTEGER, _payment_id INTEGER)
AS $$
    BEGIN
        UPDATE payment
        SET amount = get_discount(payment.amount, percentage)
        WHERE payment_id = _payment_id;
    END;
$$ LANGUAGE plpgsql;

SELECT *
FROM payment;

CALL apply_discount(75, 17505);
SELECT *
FROM payment
WHERE payment_id = 17505;