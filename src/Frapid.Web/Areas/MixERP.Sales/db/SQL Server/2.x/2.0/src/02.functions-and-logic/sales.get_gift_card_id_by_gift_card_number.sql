IF OBJECT_ID('sales.get_gift_card_id_by_gift_card_number') IS NOT NULL
DROP FUNCTION sales.get_gift_card_id_by_gift_card_number;

GO

CREATE FUNCTION sales.get_gift_card_id_by_gift_card_number(@gift_card_number national character varying(100))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.gift_cards.gift_card_id
	    FROM sales.gift_cards
	    WHERE sales.gift_cards.gift_card_number = @gift_card_number
	    AND sales.gift_cards.deleted = 0
    );
END;





GO
