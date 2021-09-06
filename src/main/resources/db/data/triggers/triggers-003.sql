CREATE OR REPLACE FUNCTION gen_datetime()
    RETURNS trigger

    COST 100
AS '
    BEGIN
        new.time = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;'
    LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS book_review_like_before_iu ON book_review_like;

CREATE TRIGGER book_review_like_before_iu
    BEFORE INSERT OR UPDATE ON book_review_like
    FOR EACH ROW
EXECUTE PROCEDURE gen_datetime();

DROP TRIGGER IF EXISTS book_review_before_iu ON book_review;

CREATE TRIGGER book_review_before_iu
    BEFORE INSERT OR UPDATE ON book_review
    FOR EACH ROW
EXECUTE PROCEDURE gen_datetime();

