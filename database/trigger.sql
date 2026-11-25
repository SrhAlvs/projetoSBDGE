USE projetoSBDGE;

DELIMITER //

CREATE TRIGGER trg_sale_item_set_price
    BEFORE INSERT ON sale_item
    FOR EACH ROW
BEGIN
    IF NEW.unit_price IS NULL THEN
        SELECT price
        INTO NEW.unit_price
        FROM product
        WHERE id_product = NEW.product_id;
    END IF;
END //

DELIMITER ;