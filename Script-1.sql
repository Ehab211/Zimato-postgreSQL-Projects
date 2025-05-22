-- =============================================
-- Table: customer
-- =============================================
CREATE TABLE customer (
    customer_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    reg_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: customer_logs
-- Logs changes in the customer table
CREATE TABLE customer_logs (
    log_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT,
    action VARCHAR(10), -- INSERT, UPDATE, DELETE
    old_name VARCHAR(50),
    new_name VARCHAR(50),
    old_reg_date DATE,
    new_reg_date DATE,
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(50) -- (if a user system exists)
	operation_status VARCHAR(20) DEFAULT 'SUCCESS', -- To track if the logging operation succeeded
    error_message TEXT -- To store any error message if the operation fails
);

-- Function to log changes in the customer table
CREATE OR REPLACE FUNCTION log_customer_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        BEGIN
            INSERT INTO customer_logs(customer_id, action, new_name, new_reg_date, modified_by, operation_status)
            VALUES (NEW.customer_id, 'INSERT', NEW.customer_name, NEW.reg_date, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO customer_logs(customer_id, action, new_name, new_reg_date, modified_by, operation_status, error_message)
            VALUES (NEW.customer_id, 'INSERT', NEW.customer_name, NEW.reg_date, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original INSERT operation
        END;
    ELSIF TG_OP = 'UPDATE' THEN
        BEGIN
            INSERT INTO customer_logs(customer_id, action, old_name, new_name, old_reg_date, new_reg_date, modified_by, operation_status)
            VALUES (OLD.customer_id, 'UPDATE', OLD.customer_name, NEW.customer_name, OLD.reg_date, NEW.reg_date, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO customer_logs(customer_id, action, old_name, new_name, old_reg_date, new_reg_date, modified_by, operation_status, error_message)
            VALUES (OLD.customer_id, 'UPDATE', OLD.customer_name, NEW.customer_name, OLD.reg_date, NEW.reg_date, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original UPDATE operation
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            INSERT INTO customer_logs(customer_id, action, old_name, old_reg_date, modified_by, operation_status)
            VALUES (OLD.customer_id, 'DELETE', OLD.customer_name, OLD.reg_date, current_user, 'SUCCESS');
            RETURN OLD;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO customer_logs(customer_id, action, old_name, old_reg_date, modified_by, operation_status, error_message)
            VALUES (OLD.customer_id, 'DELETE', OLD.customer_name, OLD.reg_date, current_user, 'FAILED', SQLERRM);
            RETURN OLD; -- Continue the original DELETE operation
        END;
    END IF;
    RETURN NULL; -- Should not be reached
END;
$$ LANGUAGE plpgsql;

-- Trigger for INSERT, UPDATE, DELETE operations on customer table
CREATE TRIGGER trg_log_customer_changes
AFTER INSERT OR UPDATE OR DELETE ON customer
FOR EACH ROW
EXECUTE FUNCTION log_customer_changes();



-- =============================================
-- Table: restaurant
-- =============================================
CREATE TABLE restaurant (
    restaurant_id BIGSERIAL PRIMARY KEY,
    restaurant_name VARCHAR(50) NOT NULL,
    city VARCHAR(25) NOT NULL,
    opening_hours VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: restaurant_logs
-- Logs changes in the restaurant table
CREATE TABLE restaurant_logs (
    log_id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT,
    action VARCHAR(10), -- INSERT, UPDATE, DELETE
    old_name VARCHAR(50),
    new_name VARCHAR(50),
    old_city VARCHAR(25),
    new_city VARCHAR(25),
    old_opening_hours VARCHAR(50),
    new_opening_hours VARCHAR(50),
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(50), -- (if a user system exists)
	operation_status VARCHAR(20) DEFAULT 'SUCCESS', -- To track if the logging operation succeeded
    error_message TEXT -- To store any error message if the operation fails
);

-- Function to log changes in the restaurant table
CREATE OR REPLACE FUNCTION log_restaurant_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        BEGIN
            INSERT INTO restaurant_logs(restaurant_id, action, new_name, new_city, new_opening_hours, modified_by, operation_status)
            VALUES (NEW.restaurant_id, 'INSERT', NEW.restaurant_name, NEW.city, NEW.opening_hours, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO restaurant_logs(restaurant_id, action, new_name, new_city, new_opening_hours, modified_by, operation_status, error_message)
            VALUES (NEW.restaurant_id, 'INSERT', NEW.restaurant_name, NEW.city, NEW.opening_hours, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original INSERT operation
        END;
    ELSIF TG_OP = 'UPDATE' THEN
        BEGIN
            INSERT INTO restaurant_logs(restaurant_id, action, old_name, new_name, old_city, new_city, old_opening_hours, new_opening_hours, modified_by, operation_status)
            VALUES (OLD.restaurant_id, 'UPDATE', OLD.restaurant_name, NEW.restaurant_name, OLD.city, NEW.city, OLD.opening_hours, NEW.opening_hours, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO restaurant_logs(restaurant_id, action, old_name, new_name, old_city, new_city, old_opening_hours, new_opening_hours, modified_by, operation_status, error_message)
            VALUES (OLD.restaurant_id, 'UPDATE', OLD.restaurant_name, NEW.restaurant_name, OLD.city, NEW.city, OLD.opening_hours, NEW.opening_hours, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original UPDATE operation
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            INSERT INTO restaurant_logs(restaurant_id, action, old_name, old_city, old_opening_hours, modified_by, operation_status)
            VALUES (OLD.restaurant_id, 'DELETE', OLD.restaurant_name, OLD.city, OLD.opening_hours, current_user, 'SUCCESS');
            RETURN OLD;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO restaurant_logs(restaurant_id, action, old_name, old_city, old_opening_hours, modified_by, operation_status, error_message)
            VALUES (OLD.restaurant_id, 'DELETE', OLD.restaurant_name, OLD.city, OLD.opening_hours, current_user, 'FAILED', SQLERRM);
            RETURN OLD; -- Continue the original DELETE operation
        END;
    END IF;
    RETURN NULL; -- Should not be reached
END;
$$ LANGUAGE plpgsql;

-- Trigger for INSERT, UPDATE, DELETE operations on restaurant table
CREATE TRIGGER trg_log_restaurant_changes
AFTER INSERT OR UPDATE OR DELETE ON restaurant
FOR EACH ROW
EXECUTE FUNCTION log_restaurant_changes();



-- =============================================
-- Table: orders
-- =============================================
CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    restaurant_id BIGINT NOT NULL,
    order_items VARCHAR(250) NOT NULL,
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(50) CHECK(order_status IN ('complete', 'incomplete')),
    total_amount DECIMAL(10, 2) NOT null CHECK (total_amount > 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_restaurant_id FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id)
);

-- Table: order_logs
-- Logs changes in the orders table
CREATE TABLE order_logs (
    log_id BIGSERIAL PRIMARY KEY, -- Using SERIAL as in original code, though BIGSERIAL is consistent with others
    order_id BIGINT,
    action VARCHAR(10), -- INSERT, UPDATE, DELETE
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    old_total DECIMAL(10, 2),
    new_total DECIMAL(10, 2),
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(50), -- (if a user system exists)
	operation_status VARCHAR(20) DEFAULT 'SUCCESS', -- To track if the logging operation succeeded
    error_message TEXT -- To store any error message if the operation fails
);

-- Function to log changes in the orders table
CREATE OR REPLACE FUNCTION log_order_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        BEGIN
            INSERT INTO order_logs(order_id, action, new_status, new_total, modified_by, operation_status)
            VALUES (NEW.order_id, 'INSERT', NEW.order_status, NEW.total_amount, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO order_logs(order_id, action, new_status, new_total, modified_by, operation_status, error_message)
            VALUES (NEW.order_id, 'INSERT', NEW.order_status, NEW.total_amount, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original INSERT operation
        END;
    ELSIF TG_OP = 'UPDATE' THEN
        BEGIN
            INSERT INTO order_logs(order_id, action, old_status, new_status, old_total, new_total, modified_by, operation_status)
            VALUES (OLD.order_id, 'UPDATE', OLD.order_status, NEW.order_status, OLD.total_amount, NEW.total_amount, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO order_logs(order_id, action, old_status, new_status, old_total, new_total, modified_by, operation_status, error_message)
            VALUES (OLD.order_id, 'UPDATE', OLD.order_status, NEW.order_status, OLD.total_amount, NEW.total_amount, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original UPDATE operation
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            INSERT INTO order_logs(order_id, action, old_status, old_total, modified_by, operation_status)
            VALUES (OLD.order_id, 'DELETE', OLD.order_status, OLD.total_amount, current_user, 'SUCCESS');
            RETURN OLD;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO order_logs(order_id, action, old_status, old_total, modified_by, operation_status, error_message)
            VALUES (OLD.order_id, 'DELETE', OLD.order_status, OLD.total_amount, current_user, 'FAILED', SQLERRM);
            RETURN OLD; -- Continue the original DELETE operation
        END;
    END IF;
    RETURN NULL; -- Should not be reached
END;
$$ LANGUAGE plpgsql;

-- Trigger for INSERT, UPDATE, DELETE operations on orders table
CREATE TRIGGER trg_log_order_changes
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION log_order_changes();


-- =============================================
-- Table: riders
-- =============================================
CREATE TABLE riders (
    rider_id BIGSERIAL PRIMARY KEY,
    rider_name VARCHAR(50) NOT NULL,
    sign_up DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Table: rider_logs
-- Logs changes in the riders table
CREATE TABLE rider_logs (
    log_id BIGSERIAL PRIMARY KEY,
    rider_id BIGINT,
    action VARCHAR(10), -- INSERT, UPDATE, DELETE
    old_name VARCHAR(50),
    new_name VARCHAR(50),
    old_signup DATE,
    new_signup DATE,
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(50), -- (if a user system exists)
	operation_status VARCHAR(20) DEFAULT 'SUCCESS', -- To track if the logging operation succeeded
    error_message TEXT -- To store any error message if the operation fails
);

-- Function to log changes in the riders table
CREATE OR REPLACE FUNCTION log_rider_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        BEGIN
            INSERT INTO rider_logs(rider_id, action, new_name, new_signup, modified_by, operation_status)
            VALUES (NEW.rider_id, 'INSERT', NEW.rider_name, NEW.sign_up, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO rider_logs(rider_id, action, new_name, new_signup, modified_by, operation_status, error_message)
            VALUES (NEW.rider_id, 'INSERT', NEW.rider_name, NEW.sign_up, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original INSERT operation
        END;
    ELSIF TG_OP = 'UPDATE' THEN
        BEGIN
            INSERT INTO rider_logs(rider_id, action, old_name, new_name, old_signup, new_signup, modified_by, operation_status)
            VALUES (OLD.rider_id, 'UPDATE', OLD.rider_name, NEW.rider_name, OLD.sign_up, NEW.sign_up, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO rider_logs(rider_id, action, old_name, new_name, old_signup, new_signup, modified_by, operation_status, error_message)
            VALUES (OLD.rider_id, 'UPDATE', OLD.rider_name, NEW.rider_name, OLD.sign_up, NEW.sign_up, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original UPDATE operation
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            INSERT INTO rider_logs(rider_id, action, old_name, old_signup, modified_by, operation_status)
            VALUES (OLD.rider_id, 'DELETE', OLD.rider_name, OLD.sign_up, current_user, 'SUCCESS');
            RETURN OLD;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO rider_logs(rider_id, action, old_name, old_signup, modified_by, operation_status, error_message)
            VALUES (OLD.rider_id, 'DELETE', OLD.rider_name, OLD.sign_up, current_user, 'FAILED', SQLERRM);
            RETURN OLD; -- Continue the original DELETE operation
        END;
    END IF;
    RETURN NULL; -- Should not be reached
END;
$$ LANGUAGE plpgsql;

-- Trigger for INSERT, UPDATE, DELETE operations on riders table
CREATE TRIGGER trg_log_rider_changes
AFTER INSERT OR UPDATE OR DELETE ON riders
FOR EACH ROW
EXECUTE FUNCTION log_rider_changes();


-- =============================================
-- Table: delivery
-- =============================================
CREATE TABLE delivery (
    delivery_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    delivery_status VARCHAR(50) CHECK(delivery_status IN ('delivered', 'failed', 'in_progress')),
    delivery_date DATE,
    delivery_time TIME,
    rider_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rider_id FOREIGN KEY (rider_id) REFERENCES riders (rider_id),
    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- Table: delivery_logs
-- Logs changes in the delivery table
CREATE TABLE delivery_logs (
    log_id BIGSERIAL PRIMARY KEY,
    delivery_id BIGINT,
    order_id BIGINT,
    action VARCHAR(10), -- INSERT, UPDATE, DELETE
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    old_date DATE,
    new_date DATE,
    old_time TIME,
    new_time TIME,
    old_rider_id BIGINT,
    new_rider_id BIGINT,
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(50), -- (if a user system exists)
	operation_status VARCHAR(20) DEFAULT 'SUCCESS', -- To track if the logging operation succeeded
    error_message TEXT -- To store any error message if the operation fails
);

-- Function to log changes in the delivery table
CREATE OR REPLACE FUNCTION log_delivery_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        BEGIN
            INSERT INTO delivery_logs(delivery_id, order_id, action, new_status, new_date, new_time, new_rider_id, modified_by, operation_status)
            VALUES (NEW.delivery_id, NEW.order_id, 'INSERT', NEW.delivery_status, NEW.delivery_date, NEW.delivery_time, NEW.rider_id, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO delivery_logs(delivery_id, order_id, action, new_status, new_date, new_time, new_rider_id, modified_by, operation_status, error_message)
            VALUES (NEW.delivery_id, NEW.order_id, 'INSERT', NEW.delivery_status, NEW.delivery_date, NEW.delivery_time, NEW.rider_id, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original INSERT operation
        END;
    ELSIF TG_OP = 'UPDATE' THEN
        BEGIN
            INSERT INTO delivery_logs(delivery_id, order_id, action, old_status, new_status, old_date, new_date, old_time, new_time, old_rider_id, new_rider_id, modified_by, operation_status)
            VALUES (OLD.delivery_id, OLD.order_id, 'UPDATE', OLD.delivery_status, NEW.delivery_status, OLD.delivery_date, NEW.delivery_date, OLD.delivery_time, NEW.delivery_time, OLD.rider_id, NEW.rider_id, current_user, 'SUCCESS');
            RETURN NEW;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO delivery_logs(delivery_id, order_id, action, old_status, new_status, old_date, new_date, old_time, new_time, old_rider_id, new_rider_id, modified_by, operation_status, error_message)
            VALUES (OLD.delivery_id, OLD.order_id, 'UPDATE', OLD.delivery_status, NEW.delivery_status, OLD.delivery_date, NEW.delivery_date, OLD.delivery_time, NEW.delivery_time, OLD.rider_id, NEW.rider_id, current_user, 'FAILED', SQLERRM);
            RETURN NEW; -- Continue the original UPDATE operation
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            INSERT INTO delivery_logs(delivery_id, order_id, action, old_status, old_date, old_time, old_rider_id, modified_by, operation_status)
            VALUES (OLD.delivery_id, OLD.order_id, 'DELETE', OLD.delivery_status, OLD.delivery_date, OLD.delivery_time, OLD.rider_id, current_user, 'SUCCESS');
            RETURN OLD;
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO delivery_logs(delivery_id, order_id, action, old_status, old_date, old_time, old_rider_id, modified_by, operation_status, error_message)
            VALUES (OLD.delivery_id, OLD.order_id, 'DELETE', OLD.delivery_status, OLD.delivery_date, OLD.delivery_time, OLD.rider_id, current_user, 'FAILED', SQLERRM);
            RETURN OLD; -- Continue the original DELETE operation
        END;
    END IF;
    RETURN NULL; -- Should not be reached
END;
$$ LANGUAGE plpgsql;

-- Trigger for INSERT, UPDATE, DELETE operations on delivery table
CREATE TRIGGER trg_log_delivery_changes
AFTER INSERT OR UPDATE OR DELETE ON delivery
FOR EACH ROW
EXECUTE FUNCTION log_delivery_changes();

-- =============================================
-- CREATE INDEXES
-- =============================================
CREATE INDEX idx_orders_order_date ON orders (order_date);
CREATE INDEX idx_orders_order_status ON orders (order_status);
CREATE INDEX idx_delivery_delivery_date ON delivery (delivery_date);
CREATE INDEX idx_delivery_delivery_status ON delivery (delivery_status);
-- =============================================
-- Analysis & Reports Queries
-- =============================================

-- Q.1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Morna Bricham" in the last 1 year.
WITH top_5_freqiently_ordered_dishes_by_specific_customer AS (
    SELECT
        c.customer_name,
        o.order_items,
        COUNT(o.order_items) AS total_orders,
        -- Using DENSE_RANK to handle ties
        DENSE_RANK() OVER(ORDER BY COUNT(o.order_items) DESC) AS rank
    FROM orders o
    JOIN customer c ON c.customer_id = o.customer_id
    WHERE c.customer_name = 'Morna Bricham'
      AND o.order_date >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY c.customer_name, o.order_items
)
SELECT
    customer_name,
    order_items,
    total_orders
FROM top_5_freqiently_ordered_dishes_by_specific_customer
WHERE rank <= 5;


-- Q.2 Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed, based on 2-hour intervals.
SELECT
    -- Create 2-hour intervals (e.g., 00:00-01:59, 02:00-03:59)
    CONCAT(
        TO_CHAR(FLOOR(EXTRACT(HOUR FROM order_time) / 2) * 2, 'FM00'),
        ':00 - ',
        TO_CHAR(FLOOR(EXTRACT(HOUR FROM order_time) / 2) * 2 + 1, 'FM00'),
        ':59'
    ) AS time_interval,
    COUNT(*) AS total_orders
FROM orders
GROUP BY time_interval
ORDER BY total_orders DESC;

-- Q.3 Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 310 orders.
-- Return customer_name, and aov (average order value)
SELECT
  c.customer_id,
  c.customer_name,
  COUNT(*) AS order_count,
  AVG(total_amount) AS aov
FROM orders o
JOIN customer c ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING COUNT(*) > 310
ORDER BY aov DESC;


-- Q.4 High-Value Customers
-- Question: List the customers who have spent more than 250K in total on food orders.
-- Return customer_name, and total_spent
SELECT
  c.customer_name,
  SUM(total_amount) AS total_spent
FROM orders o
JOIN customer c ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING SUM(total_amount) >= 250000
ORDER BY total_spent desc;

-- Q.5 Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered.
-- Return each restaurant name, city and number of not delivered orders
-- Approach 1: Using LEFT JOIN and checking for NULL delivery_id or failed status
SELECT
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS undelivered_orders
FROM orders o
LEFT JOIN restaurant r ON r.restaurant_id = o.restaurant_id
LEFT JOIN delivery d ON d.order_id = o.order_id
WHERE d.delivery_id IS NULL -- Orders with no corresponding delivery record
   OR d.delivery_status = 'failed' -- Or orders that explicitly failed delivery
GROUP BY r.restaurant_name, r.city
ORDER BY undelivered_orders DESC;

-- Approach 2: Using NOT EXISTS
SELECT
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS undelivered_orders
FROM orders o
JOIN restaurant r ON r.restaurant_id = o.restaurant_id
WHERE NOT EXISTS (
    SELECT 1
    FROM delivery d
    WHERE d.order_id = o.order_id AND d.delivery_status = 'delivered'
) -- Exclude orders that have a 'delivered' status in the delivery table
GROUP BY r.restaurant_name, r.city
ORDER BY undelivered_orders DESC;


-- Q.6 Delivery Performance by Rider
-- Question: Calculate the average delivery time per rider for delivered orders in the last 30 days.
-- Consider delivery time as the difference between order_timestamp and delivery_timestamp.
-- Return rider_name, and avg_delivery_time
SELECT
    r.rider_name,
    -- Calculate average time difference in minutes
    ROUND(AVG(
        EXTRACT(EPOCH FROM (
            (d.delivery_date + d.delivery_time)::TIMESTAMPTZ - (o.order_date + o.order_time)::TIMESTAMPTZ
        )) / 60 -- Convert seconds to minutes
    ), 2) AS avg_delivery_time_minutes
FROM delivery d
JOIN riders r USING (rider_id)
JOIN orders o USING (order_id)
WHERE d.delivery_status = 'delivered'
    AND d.delivery_date >= CURRENT_DATE - INTERVAL '30 days' -- Filter for last 30 days
GROUP BY r.rider_name
ORDER BY avg_delivery_time_minutes DESC;


-- Q. 6+ Restaurant Revenue Ranking:
-- Rank restaurants by their total revenue from the last year, including their name,
-- total revenue, and rank within their city.
SELECT
    r.restaurant_name,
    r.city,
    SUM(o.total_amount) AS total_revenue,
    -- Rank restaurants by revenue within each city
    DENSE_RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rank_within_city
FROM orders o
JOIN restaurant r USING (restaurant_id)
WHERE o.order_status = 'complete'
  AND o.order_date >= CURRENT_DATE - INTERVAL '1 year' -- Filter for last year
GROUP BY r.restaurant_id, r.restaurant_name, r.city
ORDER BY total_revenue DESC;


-- Q. 7 Most Popular Dish by City:
-- Identify the most popular dish in each city based on the number of orders.
-- Approach 1: Using DENSE_RANK (shows all tied top dishes)
WITH popular_dish_rank AS (
    SELECT
        r.city,
        o.order_items AS dish,
        COUNT(o.order_items) AS order_count,
        DENSE_RANK() OVER (PARTITION BY r.city ORDER BY COUNT(o.order_items) DESC, o.order_items) AS rank -- Handle ties alphabetically
    FROM orders o
    JOIN restaurant r USING (restaurant_id)
    GROUP BY 1, 2
)
SELECT
    city,
    dish,
    order_count
FROM popular_dish_rank
WHERE rank = 1
ORDER BY city, dish; -- Order by city and then dish for clarity

-- Approach 2: Using ROW_NUMBER (shows only one top dish per city in case of ties)
WITH popular_dish_rank AS (
    SELECT
        r.city,
        o.order_items AS dish,
        COUNT(o.order_items) AS order_count,
        ROW_NUMBER() OVER (PARTITION BY r.city ORDER BY COUNT(o.order_items) DESC) AS rank -- Selects only one row per city
    FROM orders o
    JOIN restaurant r USING (restaurant_id)
    GROUP BY 1, 2
)
SELECT
    city,
    dish,
    order_count
FROM popular_dish_rank
WHERE rank = 1
ORDER BY city;

-- Q.8 Customer Churn:
-- Find customers who haven't placed an order in 2025 but did in 2024.

-- Optional: Reset sequence and insert test data for demonstration
-- SELECT setval('customer_customer_id_seq', (SELECT MAX(customer_id) FROM customer));
-- INSERT INTO customer (customer_name, reg_date) VALUES ('Mohamed Ezzat', '2025-05-13');
-- INSERT INTO orders (order_id, customer_id, restaurant_id, order_items, order_date, order_time, order_status, total_amount)
-- VALUES ('10001', '34', '8', 'Pizza Margherita', '2024-05-13', '05:12:18', 'complete', '150');

-- Approach 1: Using CTEs and LEFT JOIN
WITH order_in_2024 AS (
    SELECT DISTINCT
        customer_id,
        customer_name
    FROM orders o
    JOIN customer c USING (customer_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
),
order_in_2025 AS (
    SELECT DISTINCT
        customer_id,
        customer_name
    FROM orders o
    JOIN customer c USING (customer_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = 2025
)
SELECT
    o2024.customer_id,
    o2024.customer_name
FROM order_in_2024 o2024
LEFT JOIN order_in_2025 o2025 USING (customer_id)
WHERE o2025.customer_id IS NULL;

-- Approach 2: Using NOT IN subquery
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM orders o
JOIN customer c USING (customer_id)
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
AND c.customer_id NOT IN (
    SELECT customer_id
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2025
);

-- Approach 3: Using EXCEPT operator
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM
    orders o
JOIN
    customer c USING (customer_id)
WHERE
    EXTRACT(YEAR FROM o.order_date) = 2024

EXCEPT -- Returns rows from the first query that are not in the second
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM
    orders o
JOIN
    customer c USING (customer_id)
WHERE
    EXTRACT(YEAR FROM o.order_date) = 2025;


-- Q.9 Cancellation Rate Comparison:
-- Calculate and compare the order cancellation rate for each restaurant between the
-- current year and the previous year.
WITH cancellation_2025 AS (
    SELECT
        r.restaurant_name,
        COUNT(o.order_id) AS cancelled_2025
    FROM orders o
    JOIN restaurant r USING (restaurant_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = 2025
        AND o.order_status = 'incomplete'
    GROUP BY r.restaurant_name
),
cancellation_2024 AS (
    SELECT
        r.restaurant_name,
        COUNT(o.order_id) AS cancelled_2024
    FROM orders o
    JOIN restaurant r USING (restaurant_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
        AND o.order_status = 'incomplete'
    GROUP BY r.restaurant_name
),
all_order_count_2024 AS (
    SELECT
        r.restaurant_name,
        COUNT(o.order_id) AS total_order_2024
    FROM orders o
    JOIN restaurant r USING (restaurant_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY r.restaurant_name
),
all_order_count_2025 AS (
    SELECT
        r.restaurant_name,
        COUNT(o.order_id) AS total_order_2025
    FROM orders o
    JOIN restaurant r USING (restaurant_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = 2025
    GROUP BY r.restaurant_name
)
SELECT
    COALESCE(c25.restaurant_name, c24.restaurant_name) AS restaurant_name,
    -- Use COALESCE to show 0 counts if no orders or cancellations in a year
    COALESCE(total_order_2025.total_order_2025, 0) AS total_orders_2025,
    COALESCE(c25.cancelled_2025, 0) AS cancelled_2025,
    COALESCE(total_order_2024.total_order_2024, 0) AS total_orders_2024,
    COALESCE(c24.cancelled_2024, 0) AS cancelled_2024,
    -- Calculate cancellation percentage, handle division by zero
    CONCAT(
        ROUND(
            (COALESCE(c25.cancelled_2025, 0) * 100.0) / NULLIF(COALESCE(total_order_2025.total_order_2025, 0), 0),
            2
        ), '%'
    ) AS cancellation_perc_2025,
    CONCAT(
        ROUND(
            (COALESCE(c24.cancelled_2024, 0) * 100.0) / NULLIF(COALESCE(total_order_2024.total_order_2024, 0), 0),
            2
        ), '%'
    ) AS cancellation_perc_2024
FROM cancellation_2025 c25
FULL OUTER JOIN cancellation_2024 c24 USING (restaurant_name)
LEFT JOIN all_order_count_2024 ON COALESCE(c25.restaurant_name, c24.restaurant_name) = all_order_count_2024.restaurant_name
LEFT JOIN all_order_count_2025 ON COALESCE(c25.restaurant_name, c24.restaurant_name) = all_order_count_2025.restaurant_name
ORDER BY COALESCE(c25.cancelled_2025, 0) DESC, COALESCE(c24.cancelled_2024, 0) DESC, restaurant_name;


-- Q.10 Rider Average Delivery Time:
-- Determine each rider's average delivery time.
-- Consider delivery time as the difference between order_timestamp and delivery_timestamp.
SELECT
    r.rider_name,
    -- Calculate average time difference in minutes
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                (d.delivery_date + d.delivery_time)::TIMESTAMPTZ - (o.order_date + o.order_time)::TIMESTAMPTZ
            )) / 60 -- Convert seconds to minutes
        ), 2
    ) AS avg_delivery_time_minutes
FROM
    delivery d
JOIN
    riders r USING (rider_id)
JOIN
    orders o USING (order_id)
WHERE
    d.delivery_status = 'delivered' -- Only include successful deliveries
    AND o.order_status = 'complete' -- Ensure the order itself was marked complete
    AND (d.delivery_date + d.delivery_time)::TIMESTAMPTZ >= (o.order_date + o.order_time)::TIMESTAMPTZ -- Ensure delivery time is not before order time
GROUP BY
    r.rider_name
ORDER BY
    avg_delivery_time_minutes ASC; -- Order by shortest average time


-- Q.11 Monthly Restaurant Growth Ratio:
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.
-- This query calculates month-over-month growth for delivered orders.
WITH FirstOrder AS (
    -- Find the date of the first delivered order for each restaurant
    SELECT
        o.restaurant_id,
        MIN(o.order_date) AS join_date_first_order
    FROM orders o
    JOIN delivery d USING(order_id)
    WHERE o.order_status = 'complete' AND d.delivery_status = 'delivered'
    GROUP BY o.restaurant_id
),
MonthlyOrders AS (
    -- Count delivered orders per restaurant per month
    SELECT
        o.restaurant_id,
        r.restaurant_name,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN delivery d USING(order_id)
    JOIN restaurant r USING(restaurant_id)
    JOIN FirstOrder fo USING(restaurant_id) -- Join with first order date
    WHERE o.order_status = 'complete'
        AND d.delivery_status = 'delivered'
        AND o.order_date >= fo.join_date_first_order -- Start counting from the first delivered order date
    GROUP BY o.restaurant_id, r.restaurant_name, EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
),
DataWithPrevMonthCount AS (
    -- Add previous month's order count using LAG window function
    SELECT
        restaurant_id,
        restaurant_name,
        order_year,
        order_month,
        order_count,
        LAG(order_count) OVER (PARTITION BY restaurant_id ORDER BY order_year, order_month) AS prev_month_count
    FROM MonthlyOrders
)
SELECT
    restaurant_name,
    order_year,
    order_month,
    order_count,
    -- Calculate growth ratio: (current - previous) / previous * 100
    CASE
        WHEN prev_month_count IS NULL THEN NULL -- No previous month data
        WHEN prev_month_count = 0 AND order_count > 0 THEN 'Infinite%' -- Growth from 0
        WHEN prev_month_count = 0 AND order_count = 0 THEN '0%' -- Still 0
        ELSE ROUND(
            ((order_count - prev_month_count)::numeric
            / prev_month_count ) * 100,
            2
        )::text || '%' -- Calculate percentage and format
    END AS growth_ratio
FROM DataWithPrevMonthCount
ORDER BY restaurant_id, order_year, order_month;


-- Q.12 Yearly Restaurant Growth Ratio:
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.
-- This query calculates year-over-year growth for delivered orders.
WITH FirstOrder AS (
    -- Find the date of the first delivered order for each restaurant
    SELECT
        o.restaurant_id,
        MIN(o.order_date) AS join_date
    FROM orders o
    JOIN delivery d ON o.order_id = d.order_id
    WHERE o.order_status = 'complete' AND d.delivery_status = 'delivered'
    GROUP BY o.restaurant_id
),
YearlyOrders AS (
    -- Count delivered orders per restaurant per year
    SELECT
        o.restaurant_id,
        r.restaurant_name,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN delivery d ON o.order_id = d.order_id
    JOIN restaurant r ON o.restaurant_id = r.restaurant_id
    JOIN FirstOrder fo ON o.restaurant_id = fo.restaurant_id -- Join with first order date
    WHERE o.order_status = 'complete'
        AND d.delivery_status = 'delivered'
        AND o.order_date >= fo.join_date -- Start counting from the first delivered order date
    GROUP BY o.restaurant_id, r.restaurant_name, EXTRACT(YEAR FROM o.order_date)
),
DataWithPrevYearCount AS (
    -- Add previous year's order count using LAG window function
    SELECT
        restaurant_id,
        restaurant_name,
        order_year,
        order_count,
        LAG(order_count) OVER (PARTITION BY restaurant_id ORDER BY order_year) AS prev_year_count
    FROM YearlyOrders
)
SELECT
    restaurant_name,
    order_year,
    order_count,
    -- Calculate growth ratio: (current - previous) / previous * 100
    CASE
        WHEN prev_year_count IS NULL THEN NULL -- No previous year data
        WHEN prev_year_count = 0 AND order_count > 0 THEN 'Infinite%' -- Growth from 0
        WHEN prev_year_count = 0 AND order_count = 0 THEN '0%' -- Still 0
        ELSE ROUND(
            ((order_count - prev_year_count)::NUMERIC
             / prev_year_count) * 100,
            2
        )::text || '%' -- Calculate percentage and format
    END AS Growth_Ratio
FROM DataWithPrevYearCount
ORDER BY restaurant_id, order_year;


-- Q.13 Customer Segmentation:
-- Segment customers into 'Gold' or 'Silver' groups based on their total spending
-- compared to the average order value (AOV). If a customer's total spending exceeds
-- the AOV (calculated from delivered complete orders), label them as 'Gold';
-- otherwise, label them as 'Silver'.
-- Write an SQL query to determine each customer's segment, total number of orders,
-- and total revenue.

-- Optional: Create indexes for performance if needed (as in original code)
-- CREATE INDEX idx_orders_customer_status ON orders (customer_id, order_status);
-- CREATE INDEX idx_delivery_order_status ON delivery (order_id, delivery_status);
-- EXPLAIN ANALYZE -- Use this keyword before the query to see execution plan

-- Approach 1: Using CTEs for clarity (as in original code)
WITH Customer_total_revenue AS MATERIALIZED (
    -- Calculate total orders count and amount for each customer (only delivered complete orders)
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS total_orders_count,
        SUM(o.total_amount) AS total_orders_amount
    FROM customer c
    JOIN orders o USING (customer_id)
    JOIN delivery d USING (order_id)
    WHERE o.order_status = 'complete' AND d.delivery_status = 'delivered'
    GROUP BY c.customer_id, c.customer_name
),
AverageOrderValue AS MATERIALIZED (
    -- Calculate the overall Average Order Value (AOV) from delivered complete orders
    SELECT
        AVG(total_amount) AS AOV
    FROM orders o
    JOIN delivery d ON o.order_id = d.order_id
    WHERE o.order_status = 'complete' AND d.delivery_status = 'delivered'
),
CustomerSegment AS (
    -- Assign segment based on comparison with AOV
    SELECT
        customer_id,
        customer_name,
        total_orders_count,
        total_orders_amount,
        CASE
            WHEN total_orders_amount >= (SELECT AOV FROM AverageOrderValue) THEN 'Gold'
            ELSE 'Silver'
        END AS Customers_Segment
    FROM Customer_total_revenue
)
SELECT
    customer_name,
    total_orders_count,
    total_orders_amount,
    Customers_Segment
FROM CustomerSegment
ORDER BY customer_name;

-- Approach 2: Direct calculation with subquery (as in original code)
/*EXPLAIN ANALYZE*/
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders_count,
    SUM(o.total_amount) AS total_orders_amount,
    CASE
        -- Compare customer's total spending to the overall AOV
        WHEN SUM(o.total_amount) >= (
            SELECT AVG(total_amount)
            FROM orders o_sub
            JOIN delivery d_sub USING (order_id)
            WHERE o_sub.order_status = 'complete' AND d_sub.delivery_status = 'delivered'
        ) THEN 'Gold'
        ELSE 'Silver'
    END AS Customers_Segment
FROM customer c
JOIN orders o USING (customer_id)
JOIN delivery d USING (order_id)
WHERE o.order_status = 'complete' AND d.delivery_status = 'delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_name;


-- Q.14 Rider Monthly Earnings:
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount for delivered complete orders.
SELECT
    r.rider_id,
    r.rider_name,
    TO_CHAR(d.delivery_date, 'YYYY-MM') AS month, -- Format month as YYYY-MM
    ROUND(SUM(o.total_amount) * 0.08, 2) AS total_earnings -- Calculate 8% of total amount
FROM
    riders r
JOIN
    delivery d USING (rider_id)
JOIN
    orders o USING (order_id)
WHERE
    d.delivery_status = 'delivered'
    AND o.order_status = 'complete' -- Ensure only completed and delivered orders contribute
GROUP BY
    r.rider_id, r.rider_name, month
ORDER BY
    r.rider_id, month; -- Order by rider and then month


-- Q.15 Rider Ratings Analysis:
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- Riders receive this rating based on delivery time (difference between order_timestamp and delivery_timestamp).
-- If delivered < 15 minutes: 5-star
-- If delivered between 15 and 20 minutes: 4-star
-- If delivered > 20 minutes: 3-star (for delivered complete orders)
SELECT
    r.rider_name,
    -- Count orders where delivery time is less than 15 minutes
    SUM(CASE
        WHEN EXTRACT(EPOCH FROM ((d.delivery_date + d.delivery_time)::TIMESTAMPTZ - (o.order_date + o.order_time)::TIMESTAMPTZ)) / 60 < 15 THEN 1
        ELSE 0
    END) AS "5_Star_Rating",
    -- Count orders where delivery time is between 15 and 20 minutes
    SUM(CASE
        WHEN EXTRACT(EPOCH FROM ((d.delivery_date + d.delivery_time)::TIMESTAMPTZ - (o.order_date + o.order_time)::TIMESTAMPTZ)) / 60 BETWEEN 15 AND 20 THEN 1
        ELSE 0
    END) AS "4_Star_Rating",
    -- Count orders where delivery time is greater than 20 minutes
    SUM(CASE
        WHEN EXTRACT(EPOCH FROM ((d.delivery_date + d.delivery_time)::TIMESTAMPTZ - (o.order_date + o.order_time)::TIMESTAMPTZ)) / 60 > 20 THEN 1
        ELSE 0
    END) AS "3_Star_Rating"
FROM
    riders r
JOIN delivery d USING (rider_id)
JOIN orders o USING (order_id)
WHERE
    d.delivery_status = 'delivered'
    AND o.order_status = 'complete'
    AND (d.delivery_date + d.delivery_time)::TIMESTAMPTZ >= (o.order_date + o.order_time)::TIMESTAMPTZ -- Ensure delivery time is not before order time
GROUP BY
    r.rider_name
ORDER BY
    r.rider_name;


-- Q.16 Order Frequency by Day:
-- Analyze order frequency per day of the week and identify the peak day for each restaurant.
SELECT
    restaurant_name,
    day_of_week,
    total_orders
FROM
(
    SELECT
        r.restaurant_name,
        -- Extract the day of the week name
        TO_CHAR(o.order_date, 'Day') AS day_of_week,
        COUNT(o.order_id) AS total_orders,
        -- Rank days by order count for each restaurant
        DENSE_RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) AS rank
    FROM
        orders o
    JOIN
        restaurant r USING (restaurant_id)
    GROUP BY
        r.restaurant_name,
        TO_CHAR(o.order_date, 'Day')
) AS ranked_days
WHERE rank = 1 -- Select the day(s) with the highest rank
ORDER BY
    restaurant_name,
    total_orders DESC;


-- Q.17 Customer Lifetime Value (CLV):
-- Calculate the total revenue generated by each customer over all their *completed* orders.
SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_revenue
FROM customer c
JOIN orders o USING (customer_id)
WHERE o.order_status = 'complete' -- Consider only completed orders
GROUP BY 1
ORDER BY total_revenue DESC;


-- Q.18 Monthly Sales Trends:
-- Identify sales trends by comparing each month's total sales to the previous month.
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount) AS total_sales,
    -- Get the total sales from the previous month
    LAG(SUM(total_amount), 1 /* offset number of rows to go back */) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) AS prev_month_sales,
    -- Calculate the month-over-month change
    SUM(total_amount) - LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) AS monthly_change,
     -- Calculate the month-over-month growth percentage
    CASE
        WHEN LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) IS NULL THEN NULL
        WHEN LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) = 0
             AND SUM(total_amount) > 0 THEN 'Infinite%'
         WHEN LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) = 0
             AND SUM(total_amount) = 0 THEN '0%'
        ELSE ROUND(
                ((SUM(total_amount) - LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)))::NUMERIC
                / LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) ) * 100,
            2
        )::TEXT || '%'
    END AS monthly_growth_percentage,
    CASE
        WHEN SUM(total_amount) > LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date))
            THEN 'Increasing'
        WHEN SUM(total_amount) < LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date))
            THEN 'Decreasing'
        WHEN SUM(total_amount) = LAG(SUM(total_amount), 1) OVER (ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date))
            THEN 'Stable'
        ELSE 'N/A' -- For the first month
    END AS sales_trend
FROM
    orders
WHERE order_status = 'complete' -- Consider only completed orders
GROUP BY
    1, 2
ORDER BY
    year, month;


-- Q.19 Rider Efficiency:
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest (fastest) and highest (slowest) averages.
WITH AverageDeliveryTimes AS (
    SELECT
        r.rider_name,
        ROUND(
            AVG(
                EXTRACT(EPOCH FROM ((d.delivery_date + d.delivery_time)::TIMESTAMPTZ - (o.order_date + o.order_time)::TIMESTAMPTZ)) / 60
            ), 2
        ) AS avg_delivery_time_minutes
    FROM
        riders r
    JOIN
        delivery d USING (rider_id)
    JOIN
        orders o USING (order_id)
    WHERE
        d.delivery_status = 'delivered'
        AND o.order_status = 'complete'
         AND (d.delivery_date + d.delivery_time)::TIMESTAMPTZ >= (o.order_date + o.order_time)::TIMESTAMPTZ -- Ensure delivery time is not before order time
    GROUP BY
        r.rider_name
),
RankedRiders AS (
    SELECT
        rider_name,
        avg_delivery_time_minutes,
        DENSE_RANK() OVER (ORDER BY avg_delivery_time_minutes ASC) AS rank_fastest, -- Rank for fastest riders
        DENSE_RANK() OVER (ORDER BY avg_delivery_time_minutes DESC) AS rank_slowest -- Rank for slowest riders
    FROM
        AverageDeliveryTimes
)
SELECT
    rider_name,
    avg_delivery_time_minutes,
    CASE
        WHEN rank_fastest = 1 THEN 'Fastest Rider'
        WHEN rank_slowest = 1 THEN 'Slowest Rider'
        ELSE 'Average Performer' -- Label other riders
    END AS performance_level
FROM RankedRiders
ORDER BY avg_delivery_time_minutes;


-- Q.20 Order Item Popularity:
-- Track the popularity of specific order items over time and identify seasonal demand spikes.
-- This query aggregates orders by item and season (simplified to Spring/Summer/Winter).
SELECT
    order_items,
    CASE
        WHEN EXTRACT(MONTH FROM order_date) BETWEEN 3 AND 5 THEN 'Spring' -- March, April, May
        WHEN EXTRACT(MONTH FROM order_date) BETWEEN 6 AND 8 THEN 'Summer' -- June, July, August
        WHEN EXTRACT(MONTH FROM order_date) BETWEEN 9 AND 11 THEN 'Autumn' -- Sep, Oct, Nov
        ELSE 'Winter' -- December, January, February
    END AS season,
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_status = 'complete' -- Consider only completed orders
GROUP BY order_items, season
ORDER BY order_items, total_orders DESC;

/* end project zomato */