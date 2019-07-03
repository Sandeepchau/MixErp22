IF OBJECT_ID('sales.gift_card_search_view') IS NOT NULL
DROP VIEW sales.gift_card_search_view;

GO



CREATE VIEW sales.gift_card_search_view
AS
SELECT
    sales.gift_cards.gift_card_id,
    sales.gift_cards.gift_card_number,
    REPLACE(COALESCE(sales.gift_cards.first_name + ' ', '') + COALESCE(sales.gift_cards.middle_name + ' ', '') + COALESCE(sales.gift_cards.last_name, ''), '  ', ' ') AS name,
    REPLACE(COALESCE(sales.gift_cards.address_line_1 + ' ', '') + COALESCE(sales.gift_cards.address_line_2 + ' ', '') + COALESCE(sales.gift_cards.street, ''), '  ', ' ') AS address,
    sales.gift_cards.city,
    sales.gift_cards.state,
    sales.gift_cards.country,
    sales.gift_cards.po_box,
    sales.gift_cards.zip_code,
    sales.gift_cards.phone_numbers,
    sales.gift_cards.fax    
FROM sales.gift_cards
WHERE sales.gift_cards.deleted = 0;



GO
