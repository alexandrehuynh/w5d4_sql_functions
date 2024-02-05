select *
from customer;

select *
from order_;

alter table customer
drop column phone_number cascade; -- in case other tables are dependent on this column, it removes dependencies

alter table order_
add order_quantity integer,
add staff_first varchar(50),
add staff_last varchar(50),
add price integer;

alter table order_ 
alter column price type numeric(6,2);

update order_ 
set order_quantity = 3, 
staff_first = 'Rod', 
staff_last = 'Kimble', 
price = 250.00 
where order_id = 1;

-- Rod Kimble is manager, bc we broke and he's our only guy
-- updating staff_first and staff_last to him bc he manny
update order_ 
set staff_first = 'Rod', staff_last = 'Kimble'