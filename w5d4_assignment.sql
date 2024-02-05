-- FUNCTION TO CALCULATE LATE FEE
CREATE OR REPLACE FUNCTION calculate_late_fee(
days_late INT
)
RETURNS DECIMAL AS $$
BEGIN
    RETURN days_late * 1.00; -- Assuming $1 per day late fee.
END;
$$ LANGUAGE plpgsql;


-- PROCEDURE TO ADD LATE FEE
CREATE OR REPLACE PROCEDURE apply_late_fees(
    _customer_id INTEGER, -- customer id
    _rental_id INTEGER -- rental id
	) 
LANGUAGE plpgsql AS $$
DECLARE
    _days_late INT;
    _late_fee DECIMAL;
BEGIN
    SELECT EXTRACT(day FROM return_date - rental_date) - 7 INTO _days_late
    FROM rental
    WHERE rental_id = _rental_id AND customer_id = _customer_id AND return_date > rental_date + INTERVAL '7 days';
    
    -- check if the rental is late
    IF _days_late > 0 THEN
        -- call the calculate_late_fee function to determine the late fee
        _late_fee := calculate_late_fee(_days_late);
        
        -- update the corresponding payment with the calculated late fee
        UPDATE payment
        SET amount = amount + _late_fee
        WHERE customer_id = _customer_id;
    END IF;
END;
$$;


CALL apply_late_fees(279,15580);

select *
from payment
where rental_id = 15580


select *
from payment
order by rental_id;

select *
from rental
order by rental_id;

-- rental 15580 customer id 279, 9.99




-- ADD PLATINUM MEMBER COLUMN
ALTER TABLE customer
ADD COLUMN platinum_member BOOLEAN DEFAULT FALSE;

-- PROCEDURE TO UPDATE SINGLE MEMBER STATUS
CREATE OR REPLACE PROCEDURE update_platinum_member_status(
    _customer_id INTEGER
) 
LANGUAGE plpgsql AS $$
DECLARE
    _total_spent DECIMAL;
BEGIN
    -- Calculate the total spent amount for the specified customer
    SELECT SUM(amount) INTO _total_spent
    FROM payment
    WHERE customer_id = _customer_id;

    -- Update the platinum_member status based on the total spent
    IF _total_spent > 200 THEN
        UPDATE customer
        SET platinum_member = TRUE
        WHERE customer_id = _customer_id;
    ELSE
        UPDATE customer
        SET platinum_member = FALSE
        WHERE customer_id = _customer_id;
    END IF;
END;
$$;

call update_platinum_member_status(148)
-- customer_id 148 total_amount = 253.55

SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
order by total_amount desc;


SELECT 
    customer.customer_id, 
    first_name, 
    last_name, 
    SUM(amount) AS total_amount,
    platinum_member
FROM 
    customer
JOIN 
    payment ON customer.customer_id = payment.customer_id
GROUP BY 
    customer.customer_id, first_name, last_name, platinum_member
ORDER BY 
    total_amount DESC;



