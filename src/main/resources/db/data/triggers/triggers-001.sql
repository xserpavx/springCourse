DROP TRIGGER IF EXISTS book2user_after_iud ON book2user;

CREATE TRIGGER book2user_after_iud
    AFTER INSERT OR UPDATE OR DELETE ON book2user
    FOR EACH ROW EXECUTE PROCEDURE calcbookpopulartrigger();

DROP TRIGGER IF EXISTS book_user_rating_after_iud ON book_user_rating;

CREATE TRIGGER book_user_rating_after_iud
    AFTER INSERT OR UPDATE OR DELETE ON book_user_rating
    FOR EACH ROW EXECUTE PROCEDURE calc_book_rating_trigger();

CREATE OR REPLACE FUNCTION generateSlug()
    RETURNS trigger

    COST 100
AS '
    BEGIN
        new.slug = reverse(to_hex(new.id));
        RETURN NEW;
    END;'
    LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS book_before_i ON books;

CREATE TRIGGER book_before_i
    BEFORE INSERT ON books
    FOR EACH ROW EXECUTE PROCEDURE generateSlug();

DROP TRIGGER IF EXISTS author_before_i ON authors;

CREATE TRIGGER author_before_i
    BEFORE INSERT ON authors
    FOR EACH ROW EXECUTE PROCEDURE generateSlug();