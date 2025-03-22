use finprodata;
select * from order_detail
LIMIT 50;
select * from customer_detail
LIMIT 50;
select * from payment_detail
limit 50;
select * from sku_detail
limit 50;

-- ANSWER NO 1
SELECT 
    EXTRACT(MONTH FROM order_date) AS month_,
    DATE_FORMAT(order_date, '%M') AS month_to_string,
    SUM(after_discount) AS total_sales
FROM order_detail
WHERE EXTRACT(YEAR FROM order_date) = 2021
    AND is_valid = 1
GROUP BY month_, month_to_string
ORDER BY total_sales DESC
LIMIT 5;

-- ANSWER 2
WITH trans_category AS (
SELECT 
	s.category,
    o.order_date,
    o.after_discount,
    o.is_valid
FROM order_detail as o
LEFT JOIN sku_detail as s ON o.sku_id = s.id
)

SELECT 
	category as product_category,
    SUM(after_discount) as total_sales
FROM trans_category
    WHERE EXTRACT(YEAR FROM order_date) = 2022
    AND is_valid = 1
    GROUP BY 1
    ORDER BY 2 DESC

-- ANSWER 3    
WITH trans_category AS (
    SELECT 
        o.sku_id,
        s.category AS product_category,
        o.order_date,
        o.after_discount
    FROM order_detail AS o
    LEFT JOIN sku_detail AS s ON o.sku_id = s.id
    WHERE o.is_valid = 1
)

SELECT
	product_category,
CASE
        WHEN SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2021 THEN after_discount ELSE 0 END) 
             > SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2022 THEN after_discount ELSE 0 END) 
        THEN 'Penurunan'
        
        WHEN SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2021 THEN after_discount ELSE 0 END) 
             < SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2022 THEN after_discount ELSE 0 END) 
        THEN 'Kenaikan'
        
        ELSE 'Tetap'
    
END as sales_trend
FROM trans_category
GROUP BY product_category;

-- ANSWER 4
WITH trans_category AS (
    SELECT 
        o.sku_id,
        s.category AS product_category,
        o.order_date,
        o.after_discount,
        p.payment_method
    FROM order_detail AS o
    LEFT JOIN sku_detail AS s ON o.sku_id = s.id
    LEFT JOIN payment_detail as p on o.payment_id = p.id
    WHERE o.is_valid = 1   
)
SELECT 
	payment_method,
    sum(after_discount) as total_sales
FROM trans_category
WHERE EXTRACT(YEAR FROM order_date) = 2022
GROUP BY 1
ORDER BY 2 DESC

-- ANSWER 5
WITH trans_category AS (
    SELECT 
        o.sku_id,
        o.id,
        s.category AS product_category,
        o.order_date,
        o.after_discount,
        s.sku_name,
        p.payment_method
    FROM order_detail AS o
    LEFT JOIN sku_detail AS s ON o.sku_id = s.id
    LEFT JOIN payment_detail as p on o.payment_id = p.id
    WHERE o.is_valid = 1 
     AND (
        s.sku_name LIKE 'Samsung%' 
        OR s.sku_name LIKE 'Apple%' 
        OR s.sku_name LIKE 'Sony%' 
        OR s.sku_name LIKE 'Huawei%' 
        OR s.sku_name LIKE 'Lenovo%'
    )
)

SELECT 
    sku_name,
    SUM(after_discount) AS total_sales
FROM trans_category
GROUP BY sku_name
ORDER BY total_sales DESC;

select sku_name from sku_detail
