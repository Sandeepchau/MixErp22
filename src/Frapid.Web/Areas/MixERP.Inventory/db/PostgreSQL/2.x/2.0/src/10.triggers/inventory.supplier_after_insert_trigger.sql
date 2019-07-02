DROP FUNCTION IF EXISTS inventory.supplier_after_insert_trigger() CASCADE;

CREATE FUNCTION inventory.supplier_after_insert_trigger()
RETURNS TRIGGER
AS
$$
    DECLARE _parent_account_id          integer;
    DECLARE _supplier_code              text;
    DECLARE _account_id                 integer;
BEGIN    
    _parent_account_id      := inventory.get_account_id_by_supplier_type_id(NEW.supplier_type_id);

    IF(COALESCE(NEW.supplier_name, '') = '') THEN
		RAISE EXCEPTION 'The supplier name cannot be left empty.';
    END IF;

    --Create a new account
    IF(NEW.account_id IS NULL) THEN
        RAISE NOTICE '% %', NEW.supplier_name, _account_id;

        INSERT INTO finance.accounts(account_master_id, account_number, currency_code, account_name, parent_account_id)
        SELECT finance.get_account_master_id_by_account_id(_parent_account_id),  '10110-' || NEW.supplier_id, NEW.currency_code, NEW.supplier_name, _parent_account_id
        RETURNING account_id INTO _account_id;
    
        UPDATE inventory.suppliers
        SET 
            account_id = _account_id
        WHERE inventory.suppliers.supplier_id = NEW.supplier_id;

        RETURN NEW;
    END IF;

    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER supplier_after_insert_trigger
AFTER INSERT
ON inventory.suppliers
FOR EACH ROW EXECUTE PROCEDURE inventory.supplier_after_insert_trigger();

