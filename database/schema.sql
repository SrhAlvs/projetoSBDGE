USE projetoSBDGE;

-- =================================
--      PESSOAS E AUTENTICAÇÃO
-- =================================

CREATE TABLE employee ( -- funcionário
    id_employee INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    cpf VARCHAR(14) NOT NULL, -- vai que um dia usamos letras ou aumentam os números
    email VARCHAR(150),
    position ENUM('ADMINISTRATOR','MANAGER','SALESPERSON','STOCK_CLERK') NOT NULL,
    hire_date DATE NOT NULL, -- data de admissão
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_employee_cpf UNIQUE (cpf), -- cpf é único
    CONSTRAINT uk_employee_email UNIQUE (email) -- email é único
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE user ( -- usuário
    id_user INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL, -- FK
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login DATETIME,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_user_employee UNIQUE (employee_id), -- único
    CONSTRAINT uk_user_username UNIQUE (username), -- único
    CONSTRAINT fk_user_employee
        FOREIGN KEY (employee_id)
            REFERENCES employee(id_employee)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede excluir um funcionário que ainda possua uma conta associada
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE role ( -- role
    id_role INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,

    CONSTRAINT uk_role_name UNIQUE (name) -- único
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE user_role ( -- usuário + role
    user_id INT UNSIGNED NOT NULL, -- FK
    role_id INT UNSIGNED NOT NULL, -- FK
    PRIMARY KEY (user_id, role_id), -- chave primária composta

    CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id)
            REFERENCES user(id_user)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE CASCADE, -- se o usuário for excluído, vai excluir aqui também
    CONSTRAINT fk_user_role_role
        FOREIGN KEY (role_id)
            REFERENCES role(id_role)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede excluir uma role que ainda esteja atribuída a usuários
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

-- =================================
--      CADASTROS COMERCIAIS
-- =================================

CREATE TABLE category ( -- categoria
    id_category INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    description VARCHAR(255),
    parent_category_id INT UNSIGNED, -- FK, relacionamento recursivo, quando a tabela se relaciona com ela mesma

    CONSTRAINT uk_category_name UNIQUE (name), -- único
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_category_id)
            REFERENCES category(id_category)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede excluir uma categoria-pai que ainda possua uma categoria-filho associado
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE supplier ( -- fornecedor
    id_supplier INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL, -- razão social da empresa, o nome jurídico
    trade_name VARCHAR(120), -- nome fantasia, o nome mais conhecido
    cnpj VARCHAR(17) NOT NULL, -- vai que um dia usamos letras ou aumentam os números
    email VARCHAR(150),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uk_supplier_cnpj UNIQUE (cnpj), -- único
    CONSTRAINT uk_supplier_email UNIQUE (email) -- único
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE product ( -- produto
    id_product INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL, -- FK
    supplier_id INT UNSIGNED, -- FK, não é "NOT NULL" porque a própria empresa pode oferecer serviços e produtos
    name VARCHAR(120) NOT NULL,
    description TEXT, -- não sei se vou deixar
    sku VARCHAR(50) NOT NULL, -- não sei se vou deixar, mas seria um trem tipo MOU-000001 para mouses por exemplo
    type ENUM('PRODUCT', 'SERVICE') NOT NULL DEFAULT 'PRODUCT',
    price DECIMAL(12,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uk_product_sku UNIQUE (sku), -- único
    CONSTRAINT chk_product_price
        CHECK (price >= 0), -- checa se o preço é não negativo
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
            REFERENCES category(id_category)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT, -- impede excluir uma categoria que ainda possua produtos associados
    CONSTRAINT fk_product_supplier
        FOREIGN KEY (supplier_id)
            REFERENCES supplier(id_supplier)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede excluir um fornecedor que ainda possua produtos associados
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

-- =================================
--    ESTOQUE, VENDAS E PAGAMENTOS
-- =================================

CREATE TABLE inventory ( -- estoque/inventário
    id_inventory INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL, -- FK
    quantity DECIMAL(12,3) NOT NULL DEFAULT 0, -- quantidade em estoque
    minimum_inventory DECIMAL(12,3) NOT NULL DEFAULT 0, -- quantidade mínima desejada antes do alerta de reposição
    updated_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uk_inventory_product UNIQUE (product_id), -- único
    CONSTRAINT chk_inventory_quantity
        CHECK (quantity >= 0), -- checa se a quantidade é não negativa
    CONSTRAINT chk_inventory_minimum_inventory
        CHECK (minimum_inventory >= 0), -- checa se a quantidade é não negativa
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
            REFERENCES product(id_product)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede excluir um produto que ainda tenha associações no estoque
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE customer ( -- cliente
    id_customer INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    cpf_cnpj VARCHAR(17) NOT NULL, -- vai que um dia usamos letras ou aumentam os números
    email VARCHAR(150),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_customer_cpf_cnpj UNIQUE (cpf_cnpj), -- único
    CONSTRAINT uk_customer_email UNIQUE (email) -- único
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE sale ( -- venda
    id_sale INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED, -- FK
    employee_id INT UNSIGNED NOT NULL, -- FK
    sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
    status ENUM('PENDING', 'COMPLETED', 'CANCELED') NOT NULL DEFAULT 'PENDING',

    CONSTRAINT chk_sale_total_amount
        CHECK (total_amount >= 0), -- checa se o valor total é não negativo
    CONSTRAINT fk_sale_customer
        FOREIGN KEY (customer_id)
            REFERENCES customer(id_customer)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT, -- impede que a exclusão de um cliente afete um registro de venda
    CONSTRAINT fk_sale_employee
        FOREIGN KEY (employee_id)
            REFERENCES employee(id_employee)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede que a exclusão de um funcionário afete um registro de venda
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE inventory_movement ( -- movimentação de estoque/inventário
    id_inventory_movement INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL, -- FK
    user_id INT UNSIGNED NOT NULL, -- FK
    sale_id INT UNSIGNED, -- FK
    type ENUM('ENTRY', 'EXIT', 'ADJUSTMENT_IN', 'ADJUSTMENT_OUT') NOT NULL,
    quantity DECIMAL(12,3) NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_inventory_movement_quantity
        CHECK (quantity > 0), -- checa se a quantidade da movimentação é positiva
    CONSTRAINT fk_inventory_movement_product
        FOREIGN KEY (product_id)
            REFERENCES product(id_product)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT, -- impede que a exclusão de um produto afete o histórico do estoque
    CONSTRAINT fk_inventory_movement_user
        FOREIGN KEY (user_id)
            REFERENCES user(id_user)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT, -- impede que a exclusão de um usuário afete o histórico do estoque

    CONSTRAINT fk_inventory_movement_sale
        FOREIGN KEY (sale_id)
            REFERENCES sale(id_sale)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede que a exclusão de uma venda afete o histórico do estoque
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE sale_item ( -- item de venda
    id_sale_item INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id INT UNSIGNED NOT NULL, -- FK
    product_id INT UNSIGNED NOT NULL, -- FK
    quantity DECIMAL(12,3) NOT NULL,
    unit_price DECIMAL(12,2) DEFAULT NULL, -- é preenchido automaticamente pela trigger trg_sale_item_set_price
    subtotal DECIMAL(14,2)
        GENERATED ALWAYS AS (
                quantity * unit_price
            ) STORED, -- essa coluna é gerada e preenchida pelo próprio banco

    CONSTRAINT chk_sale_item_quantity
        CHECK (quantity > 0), -- checa se a quantidade da movimentação é positiva
    CONSTRAINT chk_sale_item_unit_price
        CHECK (unit_price IS NULL OR unit_price >= 0), -- checa se o valor unitário do item é não negativo
    CONSTRAINT fk_sale_item_sale
        FOREIGN KEY (sale_id)
            REFERENCES sale(id_sale)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT, -- impede excluir uma venda que possui itens associados
    CONSTRAINT fk_sale_item_product
        FOREIGN KEY (product_id)
            REFERENCES product(id_product)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede que a exclusão de um produto afete um registro de venda
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE payment ( -- pagamento
    id_payment INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id INT UNSIGNED NOT NULL, -- FK
    payment_method ENUM(
        'CASH',
        'PIX',
        'CREDIT_CARD',
        'DEBIT_CARD',
        'BANK_TRANSFER'
        ) NOT NULL,
    amount DECIMAL(14,2) NOT NULL,
    status ENUM(
        'PENDING',
        'APPROVED',
        'DECLINED',
        'REFUNDED'
        ) NOT NULL DEFAULT 'PENDING',
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- data de criação no BD e não de quando o pagamento foi realizado

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0), -- checa se a quantidade da movimentação é positiva
    CONSTRAINT fk_payment_sale
        FOREIGN KEY (sale_id)
            REFERENCES sale(id_sale)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE RESTRICT -- impede excluir uma venda que tem pagamentos associados
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

-- =================================
--        AUDITORIA E LOGS
-- =================================

CREATE TABLE access_log ( -- log de acessos
    id_access_log INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED, -- FK,  não tem o "NOT NULL" aqui pra poder registrar também as tentativas de usuários inexistentes
    provided_username VARCHAR(50) NOT NULL, -- o user_name informado na tentativa de acesso
    event ENUM('LOGIN', 'LOGOUT', 'FAILED_ATTEMPT') NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_access_log_user
        FOREIGN KEY (user_id)
            REFERENCES user(id_user)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE SET NULL -- se o usuário for excluído, ele vira "NULL" e não afeta um log de acesso
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE audit_log ( -- log de auditoria
    id_audit_log INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED, -- FK, não tem "NOT NULL" porque o sistema tmabém pode alterar valores
    operation ENUM(
        'INSERT',
        'UPDATE',
        'DELETE'
        ) NOT NULL,
    table_name VARCHAR(64) NOT NULL, -- tabela que sofreu a operação
    record_id INT UNSIGNED NOT NULL, -- id do registro alterado
    old_value LONGTEXT,
    new_value LONGTEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_log_user
        FOREIGN KEY (user_id)
            REFERENCES user(id_user)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE SET NULL -- se o usuário for excluído, ele vira "NULL" e não afeta um log de auditoria
) ENGINE=InnoDB; -- mecanismo de armazenamento utilizado pela tabela

CREATE TABLE operation_log ( -- log de operações
    id_operation_log INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED, -- FK, não tem "NOT NULL" porque o sistema tmabém pode alterar valores
    operation VARCHAR(100) NOT NULL,
    description TEXT,
    result ENUM(
        'SUCCESS',
        'ERROR',
        'ROLLBACK',
        'PERMISSION_DENIED'
        ) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_operation_log_user
        FOREIGN KEY (user_id)
            REFERENCES user(id_user)
            ON UPDATE CASCADE -- se o ID da role mudar, atualiza as FKs correspondentes
            ON DELETE SET NULL -- se o usuário for excluído, ele vira "NULL" e não afeta um log de operação
) ENGINE=InnoDB;