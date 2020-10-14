DELIMITER $$
CREATE FUNCTION client_score(id INT(10))
    RETURNS INT(10)
BEGIN
    DECLARE customer_score INT(5) DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE var_customer_number INT(5);
    DECLARE var_customer_amount FLOAT(10, 2);
    DECLARE var_customer_quantity_ordered INT(5);
    DECLARE var_product_price_each FLOAT(10,2);

    DECLARE myCursor CURSOR FOR SELECT p.customerNumber,
                                       p.amount,
                                       od.quantityOrdered,
                                       od.priceEach
                                FROM payments as p
                                         JOIN orders o on p.customerNumber = o.customerNumber
                                         JOIN orderdetails od on o.orderNumber = od.orderNumber
                                WHERE p.customerNumber = id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN myCursor;
    point_loop:
    LOOP
        FETCH myCursor INTO var_customer_number,
                            var_customer_amount,
                            var_customer_quantity_ordered,
                            var_product_price_each;

        IF done THEN
            LEAVE point_loop;
        END IF;


        IF var_customer_amount BETWEEN 40000 AND 60000 THEN
            SET customer_score = customer_score + 1;
        ELSEIF var_customer_amount > 60000 THEN
            SET customer_score = customer_score + 3;
        END IF;


        IF var_customer_quantity_ordered BETWEEN 20 AND 50 THEN
            SET customer_score = customer_score + 1;
        ELSEIF var_customer_quantity_ordered > 50 THEN
            SET customer_score = customer_score + 5;
        END IF;


        IF var_product_price_each > 150 THEN
            SET customer_score = customer_score + 1;
        END IF;

    END LOOP;
    CLOSE myCursor;
    RETURN customer_score;
END $$
DELIMITER ;


SELECT client_score(173) as client_score;




