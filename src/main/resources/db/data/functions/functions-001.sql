CREATE OR REPLACE FUNCTION public."calcBookRating"(IN id_book bigint DEFAULT 0)
    RETURNS numeric
    LANGUAGE 'sql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100

AS $BODY$
select round(avg(rate)) from book_user_rating where id_book = $1
$BODY$;

CREATE OR REPLACE FUNCTION public."calcPopularWeight"(IN id_book bigint DEFAULT 0,IN book_user_type bigint DEFAULT  0)
    RETURNS bigint
    LANGUAGE 'sql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100

AS $BODY$
select count(*) from book2user where id_book = $1 and id_type = $2
$BODY$;

CREATE OR REPLACE FUNCTION public."calcBookPopular"(IN id_book bigint DEFAULT 0)
    RETURNS numeric
    LANGUAGE 'sql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100

AS $BODY$
select 0.4 * "calcPopularWeight"($1, 1) +
       0.7 * "calcPopularWeight"($1, 2) +
       "calcPopularWeight"($1, 3)
$BODY$;

create or replace function calcbookpopulartrigger() RETURNS trigger AS '
    begin
        update books set popular = "calcBookPopular"(new.id_book) where id = new.id_book;
        RETURN new;
    end;
' LANGUAGE  plpgsql;

create or replace function calc_book_rating_trigger() RETURNS trigger AS '
    begin
        update books set rating = "calcBookRating"(new.id_book) where id = new.id_book;
        RETURN new;
    end;
' LANGUAGE  plpgsql;