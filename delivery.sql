do
$$
DECLARE
    i INT;
	delivery_id int;
    random_status TEXT;
	order_id int;
	rider_id int;
	delivery_date date;
	delivery_time time;
BEGIN
    -- Loop through 10 rows
    FOR i IN 1..9750 LOOP
	    -- تعيين order_id مباشرة
		delivery_id := i;
		order_id := FLOOR(RANDOM() * 10000) + 1;
		rider_id := FLOOR(RANDOM() * 34) +1;
		delivery_date := TO_CHAR(TIMESTAMP '01-05-2024' + FLOOR(RANDOM() * 366) * INTERVAL '1 day','DD/MM/YYYY');
		delivery_time := TO_CHAR(TIME '00:00:00' + FLOOR(RANDOM() * 86400) * INTERVAL '1 second','HH24:MI:SS');

with
    status_table
    as
    (
        select UNNEST(ARRAY[
				    'delivered', 'failed', 'in_progress'
				]) AS random_status_selected
    )
-- Generate random statu items for each row
SELECT STRING_AGG(random_status_selected, ', ')
INTO random_status
FROM (
	        select random_status_selected
    from status_table
    ORDER BY RANDOM()
	        LIMIT FLOOR(RANDOM() * 1 + 1)
	    );
	
		-- Insert the generated random orders into the orders table
	        -- Print or Insert the result
	INSERT INTO delivery
(delivery_id, order_id, delivery_status, delivery_date, delivery_time, rider_id)
	values
(delivery_id, order_id, random_status, delivery_date, delivery_time, rider_id);
END LOOP;
END $$;



select *
from delivery