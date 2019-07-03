DROP FUNCTION IF EXISTS sales.get_gift_card_id_by_gift_card_number(_gift_card_number national character varying(100));

CREATE FUNCTION sales.get_gift_card_id_by_gift_card_number(_gift_card_number national character varying(100))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.gift_card_id
    FROM sales.gift_cards
    WHERE sales.gift_cards.gift_card_number = _gift_card_number
    AND NOT sales.gift_cards.deleted;
END
$$
LANGUAGE plpgsql;

