# # FIRST FUNCTION CALCULATING THE MARGIN RATE OF A PRODUCT

DELIMITER $$
CREATE FUNCTION margin(buyPrice FLOAT(10, 2), priceEach FLOAT(10, 2))
    RETURNS FLOAT(10, 2)
BEGIN
    SET @margin = 0;
    IF buyPrice AND priceEach IS NOT NULL THEN
        SET @margin := priceEach - buyPrice;
        SET @margin := (@margin / buyPrice) * 100;
        RETURN @margin;
    END IF;
END $$;
DELIMITER ;


SELECT productName,
       margin(buyPrice, o.priceEach) as margin_rate
FROM products
NATURAL JOIN orderdetails o
HAVING margin_rate < 20;


## CALCULATE THE MARGIN RATE FOR EACH PRODUCT

SELECT customerNumber,
       TRUNCATE(SUM(amount), 2) as totalAmount
FROM payments
GROUP BY customerNumber;

SELECT (
           SELECT COUNT(orders.orderNumber) as total_orders
           FROM orders
           GROUP BY customerNumber
       ) AS total_orders,
       (
           SELECT TRUNCATE(SUM(amount), 2) as total_amount
           FROM payments
           GROUP BY customerNumber
       ) AS total_amount
FROM orders
         JOIN payments p on orders.customerNumber = p.customerNumber
ORDER BY p.customerNumber;


## CALCULATE THE NUMBER OF ORDERS OF A CUSTOMER
DELIMITER $$
CREATE FUNCTION total_orders_customer(id INT(5))
    RETURNS INT(5)
BEGIN
    RETURN (
        SELECT COUNT(orders.orderNumber) as total_orders
        FROM orders
        WHERE customerNumber = id
        GROUP BY customerNumber
    );
END $$
DELIMITER ;


## CALCULATE THE TOTAL ORDERS AMOUNT OF A CUSTOMER
DELIMITER $$
CREATE FUNCTION total_amount_orders_customer(id INT(5))
    RETURNS FLOAT(10,2)
BEGIN
    RETURN (SELECT TRUNCATE(SUM(amount), 2)
            FROM payments
            WHERE customerNumber = id
            GROUP BY customerNumber);
END $$
DELIMITER ;


## RETURN DE THE AVERAGE AMOUNT SPENT BY CUSTOMERS
DELIMITER $$
CREATE FUNCTION get_average_amount_customers()
RETURNS FLOAT(10,2)
BEGIN
    RETURN (SELECT TRUNCATE(AVG(sum_amount), 2) as average_amount
    FROM (
             SELECT SUM(amount) as sum_amount
             FROM payments
             GROUP BY customerNumber
         ) as inner_query);
END $$

## RETURN A REDUCTION RATE DEPENDING ON THE TOTAL OF ORDERS AND THE AMOUNT SPENT BY CUSTOMER
DELIMITER $$
CREATE FUNCTION get_reduction_ratio_customer(id int(5))
    RETURNS FLOAT(10,2)
BEGIN
    DECLARE reduction FLOAT(10,2);
    DECLARE average_amount_customers FLOAT(10,2);
    DECLARE total_amount_orders_customer FLOAT(10,2);
    DECLARE total_orders_customer INT(10);

    SET reduction = 0;

    SET total_amount_orders_customer = total_amount_orders_customer(id);

    SET average_amount_customers = get_average_amount_customers();

    SET total_orders_customer = total_orders_customer(id);


    IF total_orders_customer <= 2 THEN
        SET reduction = 2;
    ELSEIF total_orders_customer <= 4 THEN
        SET reduction = 4;
    ELSEIF total_orders_customer > 4 THEN
        SET reduction = 5;
    END IF;

    IF total_amount_orders_customer > (average_amount_customers * 2) THEN
        SET reduction = (reduction * 1.5);
    END IF;
    RETURN reduction;
END $$
DELIMITER ;

SELECT get_reduction_ratio_customer(121) as reduction;







