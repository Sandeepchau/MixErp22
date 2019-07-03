IF OBJECT_ID('sales.get_payable_account_id_by_gift_card_id') IS NOT NULL
DROP FUNCTION sales.get_payable_account_id_by_gift_card_id;

GO

CREATE FUNCTION sales.get_payable_account_id_by_gift_card_id(@gift_card_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.gift_cards.payable_account_id
	    FROM sales.gift_cards
	    WHERE sales.gift_cards.deleted = 0
	    AND sales.gift_cards.gift_card_id = @gift_card_id
   	);
END



GO
