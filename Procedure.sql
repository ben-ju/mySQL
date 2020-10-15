DELIMITER $$
CREATE PROCEDURE revenue(IN year CHAR(10), OUT sum_year INT)
BEGIN
    DECLARE var_month INT;
    DECLARE var_sum INT;
    DECLARE done INT DEFAULT FALSE;

# CURSOR
    DECLARE month_sum CURSOR FOR
        SELECT MONTH(o.orderDate) as month,
               TRUNCATE(SUM(o2.priceEach * o2.quantityOrdered), 2) as sum
        FROM orders as o
        JOIN orderdetails o2 on o.orderNumber = o2.orderNumber
        WHERE YEAR(o.orderDate) = year
        GROUP BY MONTH(o.orderDate);
# FLAG
    DECLARE EXIT HANDLER FOR NOT FOUND
        SET done = TRUE;

# OUT VARIABLE
    SET sum_year = (
        SELECT
               TRUNCATE(SUM(o2.priceEach * o2.quantityOrdered), 2) as total
        FROM orders as o
        JOIN orderdetails o2 on o.orderNumber = o2.orderNumber
        WHERE YEAR(o.orderDate) = year
    );

# DROP revenue TABLE
    IF EXISTS(
        SELECT *
              FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = 'revenue') THEN
        DROP TABLE revenue;
    END IF;

# NEW revenue TABLE
    CREATE TABLE revenue
    (
        month     INT,
        month_sum FLOAT(10, 2)
    );

    OPEN month_sum;

    revenue_loop:
    LOOP
        IF done THEN
            LEAVE revenue_loop;
        END IF;

#   INSERT revenue TABLE
        FETCH month_sum INTO var_month, var_sum;
        INSERT INTO revenue (month, month_sum)
        VALUES              (var_month, var_sum);

    END LOOP;
    CLOSE month_sum;
END $$


CALL revenue('2004', @sum_year);

SELECT @sum_year as total_of_the_year;

SELECT *
from revenue;
