CREATE OR REPLACE FUNCTION user_reg_datetime()
    RETURNS trigger

    COST 100
AS '
    BEGIN
        new.reg_time = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;'
    LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS user_before_i ON users;

CREATE TRIGGER user_before_i
    BEFORE INSERT ON users
    FOR EACH ROW
EXECUTE PROCEDURE user_reg_datetime();

