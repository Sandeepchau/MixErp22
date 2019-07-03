IF OBJECT_ID('sales.get_payable_account_for_gift_card') IS NOT NULL
DROP FUNCTION sales.get_payable_account_for_gift_card;

GO

CREATE FUNCTION sales.get_payable_account_for_gift_card(@gift_card_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.gift_cards.payable_account_id
	    FROM sales.gift_cards
	    WHERE sales.gift_cards.gift_card_id= @gift_card_id
	    AND sales.gift_cards.deleted = 0
    );
END;





GO
