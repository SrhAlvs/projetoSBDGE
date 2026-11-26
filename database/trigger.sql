USE projetoSBDGE;

-- =================================
-- preenche automaticamente
-- o sale_item.unit_price
-- quando o produto é inserido
-- =================================
CREATE TRIGGER trg_sale_item_set_price
    BEFORE INSERT ON sale_item
    FOR EACH ROW
BEGIN
    IF NEW.unit_price IS NULL THEN
        SET NEW.unit_price = (
            SELECT price
            FROM product
            WHERE id_product = NEW.product_id
        );
    END IF;
END;


-- =================================
-- preenche automaticamente
-- o sale_item.unit_price
-- quando um produto é atualizado
-- e tem unit_price==NULL
-- =================================
CREATE TRIGGER trg_sale_item_update_price
    BEFORE UPDATE ON sale_item
    FOR EACH ROW
BEGIN
    IF NEW.unit_price IS NULL THEN
        SET NEW.unit_price = (
            SELECT price
            FROM product
            WHERE id_product = NEW.product_id
        );
    END IF;
END;


-- =================================
-- preenche automaticamente o
-- log de auditoria quando inserir
-- um novo produto
-- =================================
CREATE TRIGGER trg_audit_product_insert
    AFTER INSERT ON product
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_id,
        operation,
        table_name,
        record_id,
        old_value,
        new_value
    )
    VALUES (
               @current_user_id,
               'INSERT',
               'product',
               NEW.id_product,
               NULL,
               JSON_OBJECT(
                       'category_id', NEW.category_id,
                       'supplier_id', NEW.supplier_id,
                       'name', NEW.name,
                       'description', NEW.description,
                       'sku', NEW.sku,
                       'type', NEW.type,
                       'price', NEW.price,
                       'is_active', NEW.is_active,
                       'created_at', NEW.created_at,
                       'updated_at', NEW.updated_at
               )
           );
END;


-- =================================
-- preenche automaticamente o
-- log de auditoria quando atualizar
-- um produto
-- =================================
CREATE TRIGGER trg_audit_product_update
    AFTER UPDATE ON product
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_id,
        operation,
        table_name,
        record_id,
        old_value,
        new_value
    )
    VALUES (
               @current_user_id,
               'UPDATE',
               'product',
               OLD.id_product,
               JSON_OBJECT(
                       'category_id', OLD.category_id,
                       'supplier_id', OLD.supplier_id,
                       'name', OLD.name,
                       'description', OLD.description,
                       'sku', OLD.sku,
                       'type', OLD.type,
                       'price', OLD.price,
                       'is_active', OLD.is_active,
                       'created_at', OLD.created_at,
                       'updated_at', OLD.updated_at
               ),
               JSON_OBJECT(
                       'category_id', NEW.category_id,
                       'supplier_id', NEW.supplier_id,
                       'name', NEW.name,
                       'description', NEW.description,
                       'sku', NEW.sku,
                       'type', NEW.type,
                       'price', NEW.price,
                       'is_active', NEW.is_active,
                       'created_at', NEW.created_at,
                       'updated_at', NEW.updated_at
               )
           );
END;


-- =================================
-- preenche automaticamente o
-- log de auditoria quando excluir
-- um produto
-- =================================
CREATE TRIGGER trg_audit_product_delete
    AFTER DELETE ON product
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_id,
        operation,
        table_name,
        record_id,
        old_value,
        new_value
    )
    VALUES (
               @current_user_id,
               'DELETE',
               'product',
               OLD.id_product,
               JSON_OBJECT(
                       'category_id', OLD.category_id,
                       'supplier_id', OLD.supplier_id,
                       'name', OLD.name,
                       'description', OLD.description,
                       'sku', OLD.sku,
                       'type', OLD.type,
                       'price', OLD.price,
                       'is_active', OLD.is_active,
                       'created_at', OLD.created_at,
                       'updated_at', OLD.updated_at
               ),
               NULL
           );
END;

SHOW TRIGGERS;