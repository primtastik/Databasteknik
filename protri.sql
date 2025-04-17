
DROP PROCEDURE IF EXISTS fetch_categories;
DROP TRIGGER IF EXISTS update_stock_after_order;

DELIMITER //

CREATE PROCEDURE fetch_categories()
BEGIN
    SELECT * FROM Category;
END //

CREATE TRIGGER update_stock_after_order
AFTER INSERT ON Order_items
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stock = stock - NEW.quantity
    WHERE products_id = NEW.products_id;
END //

DELIMITER ;