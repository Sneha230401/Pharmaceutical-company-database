
\c pharmacompany



CREATE OR REPLACE FUNCTION quantity() 
RETURNS trigger AS $$
BEGIN	
IF (old.status = 'Complete') THEN
	UPDATE exports 
	SET quantity = quantity + 10
	WHERE exports.drug_identification =old.d_id;
	return new;
END IF;
return null;    
END;
$$ LANGUAGE plpgsql;


create or replace TRIGGER t AFTER update on manufacturing for each row execute procedure quantity();
