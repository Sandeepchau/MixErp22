DROP FUNCTION IF EXISTS sales.get_payable_account_for_gift_card(_gift_card_id integer);

CREATE FUNCTION sales.get_payable_account_for_gift_card(_gift_card_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN sales.gift_cards.payable_account_id
    FROM sales.gift_cards
    WHERE sales.gift_cards.gift_card_id= _gift_card_id
    AND NOT sales.gift_cards.deleted;
END
$$
LANGUAGE plpgsql;

