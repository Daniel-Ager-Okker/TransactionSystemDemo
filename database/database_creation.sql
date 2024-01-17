--Table for currencies
CREATE TABLE currency_codes (
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(127) NOT NULL,
    str_code VARCHAR(4) UNIQUE NOT NULL
);

INSERT INTO currency_codes (name, str_code)
VALUES
    ('Tether',         'USDT'),
    ('Russian ruble',  'RUB'),
    ('European Union', 'EUR');
----------------------

--Table for the system clients
CREATE TABLE system_clients (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(127) NOT NULL,
    wallet_number NUMERIC(10,0) UNIQUE NOT NULL,
    card_number   NUMERIC(16,0) UNIQUE NOT NULL
);

INSERT INTO system_clients (name, wallet_number, card_number)
VALUES
    ('Vladimir', 9876543210, 4276553697845231),
    ('Alexey',   9876543211, 4276987412319999),
    ('Daniel',   9877745613, 4276553698798774),
    ('Daniil',   1234567890, 5536427699992222);
------------------------------

--Table for clients balances
CREATE TABLE clients_balances (
    id          SERIAL PRIMARY KEY,
    id_client   INT REFERENCES system_clients(id) NOT NULL,
    id_currency INT REFERENCES currency_codes(id) NOT NULL,
    actual      MONEY NOT NULL,
    frozen      MONEY NOT NULL
);

INSERT INTO clients_balances (id_client, id_currency, actual, frozen)
VALUES
    (1, 1, 100000.00, 0.00),
    (2, 3, 555.00,    0.00),
    (3, 2, 87000.00,  0.00),
    (4, 2, 43500.00,  0.00);
----------------------------

--IsClientInDB function
CREATE OR REPLACE FUNCTION isClientInDB(clientID NUMERIC) RETURNS BOOLEAN AS $BODY$
DECLARE
    clientExists BOOLEAN;
BEGIN
    clientExists := FALSE;
    SELECT INTO clientExists EXISTS (SELECT 1 FROM system_clients WHERE id = clientID);
    RETURN clientExists;
END;
$BODY$ LANGUAGE 'plpgsql';
--end IsClientInDB function

--GetBalance function
CREATE OR REPLACE FUNCTION getBalance(client_id NUMERIC) RETURNS TABLE (
    currency_code VARCHAR(3),
    actual        MONEY,
    frozen        MONEY
) AS $BODY$
DECLARE
    thereIsSuchClient BOOLEAN;
BEGIN
    -- 1.Check if there is a client with client_id
    thereIsSuchClient := isClientInDB(client_id);
    IF thereIsSuchClient != TRUE THEN
        RAISE EXCEPTION 'No such client in database';
    END IF;

    -- 2.If have such client - return needed query table
    RETURN QUERY 
    SELECT currCode.str_code, balance.actual, balance.frozen
    FROM  clients_balances balance
    JOIN  system_clients client   ON balance.id_client = client.id
    JOIN  currency_codes currCode ON balance.id_currency = currCode.id
    WHERE client.id = client_id;
END;
$BODY$ LANGUAGE 'plpgsql';
--end GetBalance function

--invoice function
CREATE OR REPLACE FUNCTION updateBalance(
    clientID          INT,
    str_code_currency VARCHAR,
    cashValue         MONEY,
    operationType     VARCHAR
) RETURNS BOOLEAN AS $BODY$
DECLARE
    clientCurrencyID INT;
    paramCurrencyID  INT;
    statusFlag       BOOLEAN;
BEGIN
    -- 1.Get client currency code by id
    SELECT id_currency INTO clientCurrencyID FROM system_clients WHERE id_client = clientID;

    -- 3.Compare str_code_currency from params with real clientCurrencyID, which is in databse
    SELECT id INTO paramCurrencyID FROM currency_codes WHERE str_code = str_code_currency;
    IF clientCurrencyID != paramCurrencyID THEN
        RAISE EXCEPTION 'Client has another currency in the wallet. Choose other currency for invoice';
    END IF;

    -- 4.Increase or decrease client's cash value
    IF operationType == 'INVOICE' THEN
        UPDATE clients_balances SET actual = actual + cashValue WHERE id_client = clientID;
    ELSE
        UPDATE clients_balances SET actual = actual - cashValue WHERE id_client = clientID;
    END IF;
    RETURN TRUE;
END;
$BODY$ LANGUAGE 'plpgsql';
--end invoice function

--invoiceByWalllet function
CREATE OR REPLACE FUNCTION invoiceByWalllet(
    number_wallet     NUMERIC,
    str_code_currency VARCHAR,
    cash_value        MONEY
) RETURNS BOOLEAN AS $BODY$
DECLARE
    clientID   INT;
    statusFlag BOOLEAN;
BEGIN
    -- 1.Check if number_wallet us valid param
    SELECT id INTO clientID FROM system_clients WHERE wallet_number = number_wallet;
    IF clientID IS NULL THEN
        RAISE EXCEPTION 'Wallet number is invalid';
    END IF;
    --

    statusFlag := updateBalance(clientID, str_code_currency, cash_value, 'INVOICE');
    RETURN statusFlag;
END;
$BODY$ LANGUAGE 'plpgsql';
--end invoiceByWalllet function

--invoiceByCard function
CREATE OR REPLACE FUNCTION invoiceByCard(
    number_card       NUMERIC,
    str_code_currency VARCHAR,
    cash_value        MONEY
) RETURNS BOOLEAN AS $BODY$
DECLARE
    clientID   INT;
    statusFlag BOOLEAN;
BEGIN
    -- 1.Check if number_card us valid param
    SELECT id INTO clientID FROM system_clients WHERE card_number = number_card;
    IF clientID IS NULL THEN
        RAISE EXCEPTION 'Wallet number is invalid';
    END IF;
    --

    statusFlag := updateBalance(clientID, str_code_currency, cash_value, 'INVOICE');
    RETURN statusFlag;
END;
$BODY$ LANGUAGE 'plpgsql';
-- end invoiceByCard function

--withdraw function
--end withdraw function

--withdrawByWallet function
CREATE OR REPLACE FUNCTION withdrawByWallet(
    str_code_currency VARCHAR,
    cash_value        MONEY,
    number_wallet     NUMERIC
) RETURNS BOOLEAN AS $BODY$
DECLARE
    clientID   INT;
    statusFlag BOOLEAN;
BEGIN
    -- 1.Check if number_wallet us valid param
    SELECT id INTO clientID FROM system_clients WHERE wallet_number = number_wallet;
    IF clientID IS NULL THEN
        RAISE EXCEPTION 'Wallet number is invalid';
    END IF;
    --

    statusFlag := updateBalance(clientID, str_code_currency, cash_value, 'WITHDRAW');
    RETURN statusFlag; 
END;
$BODY$ LANGUAGE 'plpgsql';
-- end withdrawByWallet function

--withdrawByCard function
CREATE OR REPLACE FUNCTION withdrawByCard(
    str_code_currency VARCHAR,
    cash_value        MONEY,
    number_card     NUMERIC
) RETURNS BOOLEAN AS $BODY$
DECLARE
    clientID   INT;
    statusFlag BOOLEAN;
BEGIN
    -- 1.Check if number_card us valid param
    SELECT id INTO clientID FROM system_clients WHERE card_number = number_card;
    IF clientID IS NULL THEN
        RAISE EXCEPTION 'Wallet card is invalid';
    END IF;
    --

    statusFlag := updateBalance(clientID, str_code_currency, cash_value, 'WITHDRAW');
    RETURN statusFlag; 
END;
$BODY$ LANGUAGE 'plpgsql';
-- end withdrawByCard function

--GRANT ALL PRIVILEGES ON DATABASE TransactionSystemDB TO fake;