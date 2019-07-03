DROP FUNCTION IF EXISTS sales.get_payable_account_id_by_gift_card_id(_gift_card_id integer);

CREATE FUNCTION sales.get_payable_account_id_by_gift_card_id(_gift_card_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.payable_account_id
    FROM sales.gift_cards
    WHERE NOT sales.gift_cards.deleted
    AND sales.gift_cards.gift_card_id = _gift_card_id;
END
$$
LANGUAGE plpgsql;