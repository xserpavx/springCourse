delete from book2user;
delete from book2genre;
delete from book2tag;
delete from book2tag2;
delete from users;
delete from genres;
delete from books;
delete from book_file_types;
delete from authors;
delete from tags;
delete from book_user_rating;

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

DROP TRIGGER IF EXISTS book2user_after_iud ON book2user;

CREATE TRIGGER book2user_after_iud
    AFTER INSERT OR UPDATE OR DELETE ON book2user
    FOR EACH ROW EXECUTE PROCEDURE calcbookpopulartrigger();

create or replace function calc_book_rating_trigger() RETURNS trigger AS '
    begin
        update books set rating = "calcBookRating"(new.id_book) where id = new.id_book;
        RETURN new;
    end;
' LANGUAGE  plpgsql;

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

insert into authors(id,name,description,photo) values (1, 'Артур Конан Дойль','','/assets/img/content/authors/acd.jpg');
insert into authors(id,name,description,photo) values (2, 'О. Генри','','/assets/img/content/authors/oHenry.jpg');
insert into authors(id,name,description,photo) values (3, 'Жюль Верн','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (4, 'Дж.Р.Р. Толкиен','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (5, 'Борис Заходер','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (6, 'Станислав Лем','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (7, 'Жорж Симеон','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (8, 'Алистер Маклин','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (9, 'Андрэ Нортон','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (10, 'Вальтер Скотт','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (11, 'Фенимор Купер','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (12, 'Туве Яннсен','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (13, 'Майн Рид','','/assets/img/content/main/card.jpg');
insert into authors(id,name,description,photo) values (14, 'Роберт Льюис Стивенсон','','/assets/img/content/main/card.jpg');


insert into tags(id, tag_name) values(1, 'авторы ru');
insert into tags(id, tag_name) values(2, 'авторы uk');
insert into tags(id, tag_name) values(3, 'авторы eng');
insert into tags(id, tag_name) values(4, 'авторы fr');
insert into tags(id, tag_name) values(5, 'детективы');
insert into tags(id, tag_name) values(6, 'роман');
insert into tags(id, tag_name) values(7, 'исторический');
insert into tags(id, tag_name) values(8, 'детские');
insert into tags(id, tag_name) values(9, 'приключения');
insert into tags(id, tag_name) values(10, 'фантастика');
insert into tags(id, tag_name) values(11, 'фэнтези');
insert into tags(id, tag_name) values(12, 'юмор');
insert into tags(id, tag_name) values(13, 'философия');

insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description)
values (1, 'Приключения Шерлока Холмса', 1, '2005-08-29', true, 404.21, 32,'/assets/img/content/main/SH.png','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description)
values (2,'Записки о Шерлоке Холмсе', 1, '2002-03-13', true, 182.0, 0,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description)
values (3,'Этюд в багровых тонах', 1, '2001-10-27', false, 285.75, 22,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description)
values (4,'Собака Баскервилей', 1, '2010-02-26', true, 662.09, 11,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (5,'Проштемпелевано звездами', 9, '2018-07-28', false, 619.27, 0,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (6,'Айвенго', 10, '2017-03-23', false, 441.02, 30,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (7,'Последний из могикан', 11, '2017-05-09', true, 178.28, 45,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (8,'Зверобой', 11, '2009-07-02', true, 289.83, 45,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (9,'Мумми Тролль и комета', 12, '2010-07-10', true, 141.25, 0,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (10,'Всадник без головы', 13, '2007-05-05', false, 495.48, 0,'/assets/img/content/main/Headless horseman.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (11,'Затерянные в океане', 13, '2017-06-27', true, 208.49, 10,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (12,'Белый вождь', 13, '2001-05-08', true, 572.52, 37,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (13,'Короли и капуста', 2, '2010-02-26', true, 662.09, 10,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (14,'Благородный Жулик', 2, '2007-05-26', true, 501.99, 33,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (15,'Горящий светильник', 2, '2000-07-25', true, 223.47, 34,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (16,'Дороги судьбы', 2, '2018-08-18', true, 254.09, 34,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (17,'Деловые люди', 2, '2011-09-13', true, 258.37, 30,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (18,'Дети капитана Гранта', 3, '2016-07-17', true, 495.55, 13,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (19,'20 тысяч лье под водой', 3, '2005-06-12', false, 439.95, 13,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (20,'Таинственный остров', 3, '2021-06-13', true, 683.14, 13,'/assets/img/content/main/secretIsland.png','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (21,'Хоббит или туда и обратно', 4, '2009-04-16', false, 459.37, 21,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (22,'Братство кольца', 4, '2014-12-14', false, 494.25, 13,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (23,'Две твердыни', 4, '2018-09-01', true, 535.68, 18,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (24,'Возвращение короля', 4, '2014-06-17', false, 634.61, 20,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (25,'А.Милн. Винни Пух и Все-Все-Все', 5, '2014-06-17', false, 634.61, 20,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (26,'Л.Кэррол. Алиса в стране чудес', 5, '2002-03-02', false, 125.49, 29,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (27,'Рассказы о пилоте Пирксе', 6, '2017-02-28', true, 398.2, 42,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (28,'Звездные дневники Йона Тихого', 6, '2018-07-03', false, 520.99, 14,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (29,'Солярис', 6, '2015-09-09', false, 595.25, 30,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (30,'Маньяк из Бержерака', 7, '2009-01-23', false, 560.58, 35,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (31,'Тайна перекрестка «Трех вдов»', 7, '2008-07-20', true, 191.68, 31,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (32,'Висельник из Сен-Фольена', 7, '2020-11-15', false, 263.19, 31,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (33,'Золотое рандеву', 8, '2012-09-11', false, 546.64, 17,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (34,'Полярная станция зебра', 8, '2006-06-18', false, 128.91, 45,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (35,'Пушки острова Наваррон', 8, '2014-01-30', false, 206.44, 18,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (36,'10 баллов с острова Наваррон', 8, '2000-05-18', true, 251.36, 21,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (37,'Саргассы в космосе', 9, '2000-06-03', true, 331.83, 15,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (38,'Зачумленный корабль', 9, '2006-04-23', false, 563.72, 0,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (39,'Остров сокровищ', 14, '2002-08-26', true, 343.6, 46,'/assets/img/content/main/TreasureIsland.png','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (40,'Странная история доктора Джекила и мистера Хайда', 14, '2016-04-01', true, 600.31, 3,'/assets/img/content/main/card.jpg','');
insert into authors(id,name,description,photo) values (15, 'Рафаэль Сабатини','','/assets/img/content/main/card.jpg');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (41,'Одиссея капитана Блада', 15, '2021-04-01', true, 343.6, 46,'/assets/img/content/main/cptBlood.png','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (42,'Хроника капитана Блада', 15, '2021-06-01', true, 343.6, 46,'/assets/img/content/main/cptBlood.png','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (43,'Удачи капитана Блада', 15, '2021-04-01', true, 600.31, 3,'/assets/img/content/main/card.jpg','');
insert into authors(id,name,description,photo) values (16, 'Джордж Мартин','','/assets/img/content/main/card.jpg');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (44,'Игра престолов', 16, '2020-11-03', true, 583.98, 7,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (45,'Битва королей', 16, '2020-08-15', false, 481.6, 29,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (46,'Буря мечей', 16, '2021-06-06', true, 114.84, 7,'/assets/img/content/main/swordStorm.png','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (47,'Пир стервятников', 16, '2020-06-26', true, 581.16, 31,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (48,'Танец с драконами', 16, '2021-04-06', true, 481.65, 45,'/assets/img/content/main/card.jpg','');
insert into authors(id,name,description,photo) values (17, 'Энн Маккефри','','/assets/img/content/authors/am.jpg');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (50,'Полёт дракона', 17, '2006-07-25', true, 576.77, 14,'/assets/img/content/main/dragonFly.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (51,'Странствия дракона', 17, '2009-01-17', true, 204.13, 14,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (52,'Белый дракон', 17, '2009-04-07', false, 186.85, 13,'/assets/img/content/main/whiteDragon.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (53,'Морита — повелительница драконов', 17, '2014-11-26', true, 460.65, 50,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (54,'История Нерилки', 17, '2001-03-28', false, 370.9, 32,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (55,'Песни Перна', 17, '2017-09-12', true, 605.75, 8,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (56,'Арфистка Менолли', 17, '2010-06-04', true, 244.5, 50,'/assets/img/content/main/menolly.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (57,'Барабаны Перна', 17, '2010-05-21', true, 576.77, 14,'/assets/img/content/main/card.jpg','');

insert into authors(id,name,description,photo) values (19, 'Марк Твен','','/assets/img/content/authors/mt.jpg');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (61,'Приключения Тома Сойера', 19,'19.03.2021', true, 995.26, 41,'/assets/img/content/main/TS.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (62,'Приключения Геккльбери Финна', 19,'11.11.2021', true, 447.76, 25,'/assets/img/content/main/GF.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (63,'Том Сойер на воздушном шаре', 19,'17.12.2021', true, 744.07, 38,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (64,'Том Сойер сыщик', 19,'15.02.2021', true, 675.79, 9,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (65,'Приключения янки при дворе короля Артура', 19,'19.02.2021', true, 517.68, 19,'/assets/img/content/main/card.jpg','');

insert into authors(id,name,description,photo) values (18, 'Александр Беляев','','/assets/img/content/authors/ab.jpg');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (58,'Человек амфибия', 18,'23.12.2021', true, 698.84, 46,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (59,'Голова профессора Доуэля', 18,'13.06.2021', true, 298.81, 5,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (60,'Продавец воздуха', 18,'03.05.2021', true, 930.07, 2,'/assets/img/content/main/card.jpg','');

insert into authors(id,name,description,photo) values (20, 'Фредерик Форсайт','','/assets/img/content/authors/ff.jpg');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (66, 'День Шакала', 20, '31.01.2021', false, 288.14, 29,'/assets/img/content/main/card.jpg','');
insert into books (id, title, id_author, pub_date, bestseller, price, discount, image, description) values (67, 'Псы войны', 20, '31.01.2021', false, 948.45, 19,'/assets/img/content/main/card.jpg','');

insert into book2tag(id_book, id_tag) values(58, 1);
insert into book2tag(id_book, id_tag) values(59, 1);
insert into book2tag(id_book, id_tag) values(60, 1);
insert into book2tag(id_book, id_tag) values(25, 1);
insert into book2tag(id_book, id_tag) values(26, 1);
insert into book2tag(id_book, id_tag) values(1, 2);
insert into book2tag(id_book, id_tag) values(2, 2);
insert into book2tag(id_book, id_tag) values(3, 2);
insert into book2tag(id_book, id_tag) values(4, 2);
insert into book2tag(id_book, id_tag) values(6, 2);
insert into book2tag(id_book, id_tag) values(21, 2);
insert into book2tag(id_book, id_tag) values(22, 2);
insert into book2tag(id_book, id_tag) values(23, 2);
insert into book2tag(id_book, id_tag) values(24, 2);
insert into book2tag(id_book, id_tag) values(25, 2);
insert into book2tag(id_book, id_tag) values(26, 2);
insert into book2tag(id_book, id_tag) values(33, 2);
insert into book2tag(id_book, id_tag) values(34, 2);
insert into book2tag(id_book, id_tag) values(35, 2);
insert into book2tag(id_book, id_tag) values(36, 2);
insert into book2tag(id_book, id_tag) values(39, 2);
insert into book2tag(id_book, id_tag) values(40, 2);
insert into book2tag(id_book, id_tag) values(41, 2);
insert into book2tag(id_book, id_tag) values(42, 2);
insert into book2tag(id_book, id_tag) values(43, 2);
insert into book2tag(id_book, id_tag) values(5, 3);
insert into book2tag(id_book, id_tag) values(7, 3);
insert into book2tag(id_book, id_tag) values(8, 3);
insert into book2tag(id_book, id_tag) values(10, 3);
insert into book2tag(id_book, id_tag) values(11, 3);
insert into book2tag(id_book, id_tag) values(12, 3);
insert into book2tag(id_book, id_tag) values(13, 3);
insert into book2tag(id_book, id_tag) values(14, 3);
insert into book2tag(id_book, id_tag) values(15, 3);
insert into book2tag(id_book, id_tag) values(16, 3);
insert into book2tag(id_book, id_tag) values(17, 3);
insert into book2tag(id_book, id_tag) values(37, 3);
insert into book2tag(id_book, id_tag) values(38, 3);
insert into book2tag(id_book, id_tag) values(44, 3);
insert into book2tag(id_book, id_tag) values(45, 3);
insert into book2tag(id_book, id_tag) values(46, 3);
insert into book2tag(id_book, id_tag) values(47, 3);
insert into book2tag(id_book, id_tag) values(48, 3);
insert into book2tag(id_book, id_tag) values(50, 3);
insert into book2tag(id_book, id_tag) values(51, 3);
insert into book2tag(id_book, id_tag) values(52, 3);
insert into book2tag(id_book, id_tag) values(53, 3);
insert into book2tag(id_book, id_tag) values(54, 3);
insert into book2tag(id_book, id_tag) values(55, 3);
insert into book2tag(id_book, id_tag) values(56, 3);
insert into book2tag(id_book, id_tag) values(57, 3);
insert into book2tag(id_book, id_tag) values(61, 3);
insert into book2tag(id_book, id_tag) values(62, 3);
insert into book2tag(id_book, id_tag) values(63, 3);
insert into book2tag(id_book, id_tag) values(64, 3);
insert into book2tag(id_book, id_tag) values(65, 3);
insert into book2tag(id_book, id_tag) values(18, 4);
insert into book2tag(id_book, id_tag) values(19, 4);
insert into book2tag(id_book, id_tag) values(20, 4);
insert into book2tag(id_book, id_tag) values(30, 4);
insert into book2tag(id_book, id_tag) values(31, 4);
insert into book2tag(id_book, id_tag) values(32, 4);
insert into book2tag(id_book, id_tag) values(1, 5);
insert into book2tag(id_book, id_tag) values(2, 5);
insert into book2tag(id_book, id_tag) values(3, 5);
insert into book2tag(id_book, id_tag) values(4, 5);
insert into book2tag(id_book, id_tag) values(5, 10);
insert into book2tag(id_book, id_tag) values(6, 6);			insert into book2tag(id_book, id_tag) values(6, 7);
insert into book2tag(id_book, id_tag) values(7, 6);			insert into book2tag(id_book, id_tag) values(7, 7);
insert into book2tag(id_book, id_tag) values(8, 6);			insert into book2tag(id_book, id_tag) values(8, 7);
insert into book2tag(id_book, id_tag) values(9, 8);
insert into book2tag(id_book, id_tag) values(10, 9);
insert into book2tag(id_book, id_tag) values(11, 9);
insert into book2tag(id_book, id_tag) values(12, 9);
insert into book2tag(id_book, id_tag) values(13, 12);
insert into book2tag(id_book, id_tag) values(14, 12);
insert into book2tag(id_book, id_tag) values(15, 12);
insert into book2tag(id_book, id_tag) values(16, 12);
insert into book2tag(id_book, id_tag) values(17, 9);
insert into book2tag(id_book, id_tag) values(18, 9);
insert into book2tag(id_book, id_tag) values(19, 10);				insert into book2tag(id_book, id_tag) values(19, 9);
insert into book2tag(id_book, id_tag) values(20, 9);
insert into book2tag(id_book, id_tag) values(21, 11);	insert into book2tag(id_book, id_tag) values(21, 7);
insert into book2tag(id_book, id_tag) values(22, 11);
insert into book2tag(id_book, id_tag) values(23, 11);
insert into book2tag(id_book, id_tag) values(24, 11);
insert into book2tag(id_book, id_tag) values(25, 8);
insert into book2tag(id_book, id_tag) values(26, 8);
insert into book2tag(id_book, id_tag) values(27, 10);				insert into book2tag(id_book, id_tag) values(27, 9);
insert into book2tag(id_book, id_tag) values(28, 10);				insert into book2tag(id_book, id_tag) values(28, 9);
insert into book2tag(id_book, id_tag) values(29, 6);	insert into book2tag(id_book, id_tag) values(29, 10);						insert into book2tag(id_book, id_tag) values(29, 13);
insert into book2tag(id_book, id_tag) values(30, 5);
insert into book2tag(id_book, id_tag) values(31, 5);
insert into book2tag(id_book, id_tag) values(32, 5);
insert into book2tag(id_book, id_tag) values(33, 5);						insert into book2tag(id_book, id_tag) values(33, 9);
insert into book2tag(id_book, id_tag) values(34, 5);						insert into book2tag(id_book, id_tag) values(34, 9);
insert into book2tag(id_book, id_tag) values(35, 7);		insert into book2tag(id_book, id_tag) values(35, 9);
insert into book2tag(id_book, id_tag) values(36, 7);		insert into book2tag(id_book, id_tag) values(36, 9);
insert into book2tag(id_book, id_tag) values(37, 10);
insert into book2tag(id_book, id_tag) values(38, 10);
insert into book2tag(id_book, id_tag) values(39, 6);			insert into book2tag(id_book, id_tag) values(39, 7);		insert into book2tag(id_book, id_tag) values(39, 9);
insert into book2tag(id_book, id_tag) values(40, 7);		insert into book2tag(id_book, id_tag) values(40, 9);
insert into book2tag(id_book, id_tag) values(41, 7);		insert into book2tag(id_book, id_tag) values(41, 9);
insert into book2tag(id_book, id_tag) values(42, 7);		insert into book2tag(id_book, id_tag) values(42, 9);
insert into book2tag(id_book, id_tag) values(43, 7);		insert into book2tag(id_book, id_tag) values(43, 9);
insert into book2tag(id_book, id_tag) values(44, 6);		insert into book2tag(id_book, id_tag) values(44, 11);
insert into book2tag(id_book, id_tag) values(45, 6);		insert into book2tag(id_book, id_tag) values(45, 11);
insert into book2tag(id_book, id_tag) values(46, 6);		insert into book2tag(id_book, id_tag) values(46, 11);
insert into book2tag(id_book, id_tag) values(47, 6);		insert into book2tag(id_book, id_tag) values(47, 11);
insert into book2tag(id_book, id_tag) values(48, 6);		insert into book2tag(id_book, id_tag) values(48, 11);
insert into book2tag(id_book, id_tag) values(50, 10);	insert into book2tag(id_book, id_tag) values(50, 11);
insert into book2tag(id_book, id_tag) values(51, 10);	insert into book2tag(id_book, id_tag) values(51, 11);
insert into book2tag(id_book, id_tag) values(52, 10);	insert into book2tag(id_book, id_tag) values(52, 11);
insert into book2tag(id_book, id_tag) values(53, 10);	insert into book2tag(id_book, id_tag) values(53, 11);
insert into book2tag(id_book, id_tag) values(54, 10);	insert into book2tag(id_book, id_tag) values(54, 11);
insert into book2tag(id_book, id_tag) values(55, 10);	insert into book2tag(id_book, id_tag) values(55, 11);
insert into book2tag(id_book, id_tag) values(56, 10);	insert into book2tag(id_book, id_tag) values(56, 11);
insert into book2tag(id_book, id_tag) values(57, 10);	insert into book2tag(id_book, id_tag) values(57, 11);
insert into book2tag(id_book, id_tag) values(61, 8);	insert into book2tag(id_book, id_tag) values(61, 9);	insert into book2tag(id_book, id_tag) values(61, 12);
insert into book2tag(id_book, id_tag) values(62, 8);	insert into book2tag(id_book, id_tag) values(62, 9);	insert into book2tag(id_book, id_tag) values(62, 12);
insert into book2tag(id_book, id_tag) values(63, 8);	insert into book2tag(id_book, id_tag) values(63, 9);	insert into book2tag(id_book, id_tag) values(63, 12);
insert into book2tag(id_book, id_tag) values(64, 8);	insert into book2tag(id_book, id_tag) values(64, 9);	insert into book2tag(id_book, id_tag) values(64, 12);
insert into book2tag(id_book, id_tag) values(65, 6);			insert into book2tag(id_book, id_tag) values(65, 7);			insert into book2tag(id_book, id_tag) values(65, 12);
insert into book2tag(id_book, id_tag) values(58, 10);
insert into book2tag(id_book, id_tag) values(59, 10);
insert into book2tag(id_book, id_tag) values(60, 10);
insert into book2tag(id_book, id_tag) values(66, 5);	insert into book2tag(id_book, id_tag) values(66, 6);			insert into book2tag(id_book, id_tag) values(66, 7);
insert into book2tag(id_book, id_tag) values(67, 6);


insert into book_file_types(name, description) values('FB2','Межплатформенный  формат электронных документов с использованием ряда возможностей языка PostScript.');
insert into book_file_types(name, description) values('PDF','Формат электронных версий книг, обеспечивает совместимость с любыми устройствами и форматами.');
insert into book_file_types(name, description) values('EPUB','Формат электронных версий книг, позволяет воспроизведить цифровые книги и другие публикации с плавающей вёрсткой.');

insert into genres(id, id_parent, slug, name) values(1, 17, 'det', 'Детективы');
insert into genres(id, id_parent, slug, name) values(2, 1, 'detc', 'Классический детектив');
insert into genres(id, id_parent, slug, name) values(3, 1, 'deto', 'Остросюжетный детектив');
insert into genres(id, id_parent, slug, name) values(4, 1, 'dets', 'Шпионский детектив');
insert into genres(id, id_parent, slug, name) values(5, 17, 'fant', 'Фантастика');
insert into genres(id, id_parent, slug, name) values(6, 5, 'fants', 'Научная фантастика');
insert into genres(id, id_parent, slug, name) values(7, 5, 'fantf', 'Фэнтези');

insert into genres(id, id_parent, slug, name) values(8, null, 'child', 'Детские');
insert into genres(id, id_parent, slug, name) values(9, 8, 'child1', 'Для детей дошкольного возраста');
insert into genres(id, id_parent, slug, name) values(10, 8, 'child2', 'Для детей младшего школьного возраста');
insert into genres(id, id_parent, slug, name) values(11, 8, 'child3', 'Для детей среднего школьного возраста');
insert into genres(id, id_parent, slug, name) values(12, 8, 'child4', 'Для детей старшего школьного возраста');

insert into genres(id, id_parent, slug, name) values(13, null, 'adv', 'Приключения');
insert into genres(id, id_parent, slug, name) values(14, null, 'hum', 'Юмор');

insert into genres(id, id_parent, slug, name) values(15, 13, 'advsea', 'На море');
insert into genres(id, id_parent, slug, name) values(16, 13, 'advland', 'На суше');
insert into genres(id, id_parent, slug, name) values(17, null, 'class', 'Классическая проза');
insert into genres(id, id_parent, slug, name) values(18, null, 'now', 'Современная проза');

insert into book2genre(id_book, id_genre) values(1, 1);	insert into book2genre(id_book, id_genre) values(1, 2);
insert into book2genre(id_book, id_genre) values(2, 1);	insert into book2genre(id_book, id_genre) values(2, 2);
insert into book2genre(id_book, id_genre) values(3, 1);	insert into book2genre(id_book, id_genre) values(3, 2);
insert into book2genre(id_book, id_genre) values(4, 1);	insert into book2genre(id_book, id_genre) values(4, 2);
insert into book2genre(id_book, id_genre) values(5, 5);
insert into book2genre(id_book, id_genre) values(6, 8);				insert into book2genre(id_book, id_genre) values(6, 12);
insert into book2genre(id_book, id_genre) values(7, 8);				insert into book2genre(id_book, id_genre) values(7, 12);
insert into book2genre(id_book, id_genre) values(8, 8);				insert into book2genre(id_book, id_genre) values(8, 12);
insert into book2genre(id_book, id_genre) values(9, 8);	insert into book2genre(id_book, id_genre) values(9, 9);	insert into book2genre(id_book, id_genre) values(9, 10);
insert into book2genre(id_book, id_genre) values(10, 1);												insert into book2genre(id_book, id_genre) values(10, 13);			insert into book2genre(id_book, id_genre) values(10, 16);
insert into book2genre(id_book, id_genre) values(11, 13);		insert into book2genre(id_book, id_genre) values(11, 15);
insert into book2genre(id_book, id_genre) values(12, 13);			insert into book2genre(id_book, id_genre) values(12, 16);
insert into book2genre(id_book, id_genre) values(13, 14);
insert into book2genre(id_book, id_genre) values(14, 14);
insert into book2genre(id_book, id_genre) values(15, 14);
insert into book2genre(id_book, id_genre) values(16, 14);
insert into book2genre(id_book, id_genre) values(17, 14);
insert into book2genre(id_book, id_genre) values(18, 13);		insert into book2genre(id_book, id_genre) values(18, 15);	insert into book2genre(id_book, id_genre) values(18, 16);
insert into book2genre(id_book, id_genre) values(19, 6);							insert into book2genre(id_book, id_genre) values(19, 13);		insert into book2genre(id_book, id_genre) values(19, 15);
insert into book2genre(id_book, id_genre) values(20, 13);			insert into book2genre(id_book, id_genre) values(20, 16);
insert into book2genre(id_book, id_genre) values(21, 5);		insert into book2genre(id_book, id_genre) values(21, 7);	insert into book2genre(id_book, id_genre) values(21, 8);	insert into book2genre(id_book, id_genre) values(21, 9);	insert into book2genre(id_book, id_genre) values(21, 10);
insert into book2genre(id_book, id_genre) values(22, 5);
insert into book2genre(id_book, id_genre) values(23, 5);
insert into book2genre(id_book, id_genre) values(24, 5);
insert into book2genre(id_book, id_genre) values(25, 8);	insert into book2genre(id_book, id_genre) values(25, 9);	insert into book2genre(id_book, id_genre) values(25, 10);
insert into book2genre(id_book, id_genre) values(26, 8);	insert into book2genre(id_book, id_genre) values(26, 9);	insert into book2genre(id_book, id_genre) values(26, 10);
insert into book2genre(id_book, id_genre) values(27, 5);	insert into book2genre(id_book, id_genre) values(27, 6);
insert into book2genre(id_book, id_genre) values(28, 5);	insert into book2genre(id_book, id_genre) values(28, 6);
insert into book2genre(id_book, id_genre) values(29, 5);	insert into book2genre(id_book, id_genre) values(29, 6);
insert into book2genre(id_book, id_genre) values(30, 1);	insert into book2genre(id_book, id_genre) values(30, 2);
insert into book2genre(id_book, id_genre) values(31, 1);	insert into book2genre(id_book, id_genre) values(31, 2);
insert into book2genre(id_book, id_genre) values(32, 1);	insert into book2genre(id_book, id_genre) values(32, 2);
insert into book2genre(id_book, id_genre) values(33, 1);	insert into book2genre(id_book, id_genre) values(33, 2);	insert into book2genre(id_book, id_genre) values(33, 3);
insert into book2genre(id_book, id_genre) values(34, 1);	insert into book2genre(id_book, id_genre) values(34, 2);	insert into book2genre(id_book, id_genre) values(34, 3);
insert into book2genre(id_book, id_genre) values(35, 13);
insert into book2genre(id_book, id_genre) values(36, 13);
insert into book2genre(id_book, id_genre) values(37, 5);	insert into book2genre(id_book, id_genre) values(37, 6);
insert into book2genre(id_book, id_genre) values(38, 5);	insert into book2genre(id_book, id_genre) values(38, 6);
insert into book2genre(id_book, id_genre) values(39, 13);		insert into book2genre(id_book, id_genre) values(39, 15);
insert into book2genre(id_book, id_genre) values(40, 13);			insert into book2genre(id_book, id_genre) values(40, 16);
insert into book2genre(id_book, id_genre) values(41, 13);		insert into book2genre(id_book, id_genre) values(41, 15);
insert into book2genre(id_book, id_genre) values(42, 13);		insert into book2genre(id_book, id_genre) values(42, 15);
insert into book2genre(id_book, id_genre) values(43, 13);		insert into book2genre(id_book, id_genre) values(43, 15);
insert into book2genre(id_book, id_genre) values(44, 5);		insert into book2genre(id_book, id_genre) values(44, 7);
insert into book2genre(id_book, id_genre) values(45, 5);		insert into book2genre(id_book, id_genre) values(45, 7);
insert into book2genre(id_book, id_genre) values(46, 5);		insert into book2genre(id_book, id_genre) values(46, 7);
insert into book2genre(id_book, id_genre) values(47, 5);		insert into book2genre(id_book, id_genre) values(47, 7);
insert into book2genre(id_book, id_genre) values(48, 5);		insert into book2genre(id_book, id_genre) values(48, 7);
insert into book2genre(id_book, id_genre) values(50, 5);
insert into book2genre(id_book, id_genre) values(51, 5);
insert into book2genre(id_book, id_genre) values(52, 5);
insert into book2genre(id_book, id_genre) values(53, 5);
insert into book2genre(id_book, id_genre) values(54, 5);
insert into book2genre(id_book, id_genre) values(55, 5);
insert into book2genre(id_book, id_genre) values(56, 5);
insert into book2genre(id_book, id_genre) values(57, 5);
insert into book2genre(id_book, id_genre) values(61, 8);		insert into book2genre(id_book, id_genre) values(61, 10);	insert into book2genre(id_book, id_genre) values(61, 11);			insert into book2genre(id_book, id_genre) values(61, 14);
insert into book2genre(id_book, id_genre) values(62, 8);		insert into book2genre(id_book, id_genre) values(62, 10);	insert into book2genre(id_book, id_genre) values(62, 11);			insert into book2genre(id_book, id_genre) values(62, 14);
insert into book2genre(id_book, id_genre) values(63, 8);		insert into book2genre(id_book, id_genre) values(63, 10);	insert into book2genre(id_book, id_genre) values(63, 11);			insert into book2genre(id_book, id_genre) values(63, 14);
insert into book2genre(id_book, id_genre) values(64, 8);		insert into book2genre(id_book, id_genre) values(64, 10);	insert into book2genre(id_book, id_genre) values(64, 11);			insert into book2genre(id_book, id_genre) values(64, 14);
insert into book2genre(id_book, id_genre) values(65, 13);	insert into book2genre(id_book, id_genre) values(65, 14);
insert into book2genre(id_book, id_genre) values(58, 5);	insert into book2genre(id_book, id_genre) values(58, 6);
insert into book2genre(id_book, id_genre) values(59, 5);	insert into book2genre(id_book, id_genre) values(59, 6);
insert into book2genre(id_book, id_genre) values(60, 5);	insert into book2genre(id_book, id_genre) values(60, 6);
insert into book2genre(id_book, id_genre) values(2, 17);
insert into book2genre(id_book, id_genre) values(3, 17);
insert into book2genre(id_book, id_genre) values(4, 17);
insert into book2genre(id_book, id_genre) values(5, 17);
insert into book2genre(id_book, id_genre) values(6, 17);
insert into book2genre(id_book, id_genre) values(7, 17);
insert into book2genre(id_book, id_genre) values(8, 17);
insert into book2genre(id_book, id_genre) values(9, 17);
insert into book2genre(id_book, id_genre) values(10, 17);
insert into book2genre(id_book, id_genre) values(11, 17);
insert into book2genre(id_book, id_genre) values(12, 17);
insert into book2genre(id_book, id_genre) values(13, 17);
insert into book2genre(id_book, id_genre) values(14, 17);
insert into book2genre(id_book, id_genre) values(15, 17);
insert into book2genre(id_book, id_genre) values(16, 17);
insert into book2genre(id_book, id_genre) values(17, 17);
insert into book2genre(id_book, id_genre) values(18, 17);
insert into book2genre(id_book, id_genre) values(19, 17);
insert into book2genre(id_book, id_genre) values(20, 17);
insert into book2genre(id_book, id_genre) values(21, 17);
insert into book2genre(id_book, id_genre) values(22, 17);
insert into book2genre(id_book, id_genre) values(23, 17);
insert into book2genre(id_book, id_genre) values(24, 17);
insert into book2genre(id_book, id_genre) values(25, 17);
insert into book2genre(id_book, id_genre) values(26, 17);
insert into book2genre(id_book, id_genre) values(27, 17);
insert into book2genre(id_book, id_genre) values(28, 17);
insert into book2genre(id_book, id_genre) values(29, 17);
insert into book2genre(id_book, id_genre) values(30, 17);
insert into book2genre(id_book, id_genre) values(31, 17);
insert into book2genre(id_book, id_genre) values(32, 17);
insert into book2genre(id_book, id_genre) values(33, 17);
insert into book2genre(id_book, id_genre) values(34, 17);
insert into book2genre(id_book, id_genre) values(35, 17);
insert into book2genre(id_book, id_genre) values(36, 17);
insert into book2genre(id_book, id_genre) values(37, 17);
insert into book2genre(id_book, id_genre) values(38, 17);
insert into book2genre(id_book, id_genre) values(39, 17);
insert into book2genre(id_book, id_genre) values(40, 17);
insert into book2genre(id_book, id_genre) values(41, 17);
insert into book2genre(id_book, id_genre) values(42, 17);
insert into book2genre(id_book, id_genre) values(43, 17);
insert into book2genre(id_book, id_genre) values(44, 18);
insert into book2genre(id_book, id_genre) values(45, 18);
insert into book2genre(id_book, id_genre) values(46, 18);
insert into book2genre(id_book, id_genre) values(47, 18);
insert into book2genre(id_book, id_genre) values(48, 18);
insert into book2genre(id_book, id_genre) values(50, 17);
insert into book2genre(id_book, id_genre) values(51, 17);
insert into book2genre(id_book, id_genre) values(52, 17);
insert into book2genre(id_book, id_genre) values(53, 17);
insert into book2genre(id_book, id_genre) values(54, 17);
insert into book2genre(id_book, id_genre) values(55, 17);
insert into book2genre(id_book, id_genre) values(56, 17);
insert into book2genre(id_book, id_genre) values(57, 17);
insert into book2genre(id_book, id_genre) values(61, 17);
insert into book2genre(id_book, id_genre) values(62, 17);
insert into book2genre(id_book, id_genre) values(63, 17);
insert into book2genre(id_book, id_genre) values(64, 17);
insert into book2genre(id_book, id_genre) values(65, 17);
insert into book2genre(id_book, id_genre) values(58, 17);
insert into book2genre(id_book, id_genre) values(59, 17);
insert into book2genre(id_book, id_genre) values(60, 17);
insert into book2genre(id_book, id_genre) values(66, 18);		insert into book2genre(id_book, id_genre) values(66, 1);		insert into book2genre(id_book, id_genre) values(66, 3);	insert into book2genre(id_book, id_genre) values(66, 4);												insert into book2genre(id_book, id_genre) values(66, 16);
insert into book2genre(id_book, id_genre) values(67, 18);														insert into book2genre(id_book, id_genre) values(67, 13);			insert into book2genre(id_book, id_genre) values(67, 16);


insert into book_user_types(code, name) values (1, 'Отложена');
insert into book_user_types(code, name) values (2, 'В корзине');
insert into book_user_types(code, name) values (3, 'Куплена');
insert into book_user_types(code, name) values (4, 'В архиве');

insert into users (id, balance, hash, name, reg_time) values (1, 897.61, 'WBA6B2C51ED363444', 'Daphna', '21/05/2020');
insert into users (id, balance, hash, name, reg_time) values (2, 584.83, 'WAUSH94F88N551311', 'Bartolemo', '21/10/2020');
insert into users (id, balance, hash, name, reg_time) values (3, 3844.4, '3D7LP2ET9BG134646', 'Cloe', '25/11/2021');
insert into users (id, balance, hash, name, reg_time) values (4, 3362.7, 'WBAUC9C56BV086647', 'Harriott', '29/04/2020');
insert into users (id, balance, hash, name, reg_time) values (5, 1248.73, '1GD01XEG4FZ463562', 'Christoffer', '27/11/2021');
insert into users (id, balance, hash, name, reg_time) values (6, 1223.38, 'SAJWA0JH1EM282730', 'Orel', '29/09/2021');
insert into users (id, balance, hash, name, reg_time) values (7, 4666.44, 'SCBZB25E72C238076', 'Harriett', '02/12/2021');
insert into users (id, balance, hash, name, reg_time) values (8, 299.68, '3D7JV1EP3AG036382', 'Pavia', '21/01/2020');
insert into users (id, balance, hash, name, reg_time) values (9, 776.9, 'WA1WGAFP4EA603707', 'Nevil', '22/04/2021');
insert into users (id, balance, hash, name, reg_time) values (10, 890.32, '4T1BF1FK2DU417197', 'Sukey', '27/11/2020');
insert into users (id, balance, hash, name, reg_time) values (11, 3532.61, '19UUA66268A147814', 'Dion', '17/04/2020');
insert into users (id, balance, hash, name, reg_time) values (12, 2084.97, '1N6AA0EC1DN022793', 'Ajay', '05/05/2020');
insert into users (id, balance, hash, name, reg_time) values (13, 388.46, '1GTG5AEA3F1373091', 'Norean', '30/06/2021');
insert into users (id, balance, hash, name, reg_time) values (14, 161.07, '1GKS2GEJ6BR956048', 'Jarrod', '29/12/2021');
insert into users (id, balance, hash, name, reg_time) values (15, 1026.26, '3N1BC1CP9CK787982', 'Ive', '24/11/2021');
insert into users (id, balance, hash, name, reg_time) values (16, 892.82, 'SCFFDCCDXCG147678', 'Brew', '15/11/2020');
insert into users (id, balance, hash, name, reg_time) values (17, 4471.46, 'WBXPA73445W616035', 'Neale', '24/12/2020');
insert into users (id, balance, hash, name, reg_time) values (18, 4012.65, '1G6DF8E50D0940889', 'Barbee', '08/01/2021');
insert into users (id, balance, hash, name, reg_time) values (19, 4537.11, 'YV1982BW4A1351772', 'Sophie', '16/06/2020');
insert into users (id, balance, hash, name, reg_time) values (20, 3578.87, '1G6YV36A795749208', 'Duffy', '12/10/2021');
insert into users (id, balance, hash, name, reg_time) values (21, 933.43, 'JH4DC44551S400257', 'Patrice', '27/07/2020');
insert into users (id, balance, hash, name, reg_time) values (22, 2814.95, 'W04GX5GV0B1628866', 'Barbe', '22/10/2020');
insert into users (id, balance, hash, name, reg_time) values (23, 2502.53, 'KNALN4D70F5237044', 'Stinky', '21/04/2021');
insert into users (id, balance, hash, name, reg_time) values (24, 3252.5, 'WDDPK4HA2DF264472', 'Minette', '15/05/2020');
insert into users (id, balance, hash, name, reg_time) values (25, 919.58, 'WP0AA2A89CU867265', 'Moritz', '26/12/2020');
insert into users (id, balance, hash, name, reg_time) values (26, 2428.64, '3C4PDDDG1FT445490', 'Mireielle', '20/01/2021');
insert into users (id, balance, hash, name, reg_time) values (27, 3344.57, '1N4AB7AP2DN260076', 'Constantine', '20/03/2021');
insert into users (id, balance, hash, name, reg_time) values (28, 174.7, '5GAKVBKD4EJ327459', 'Braden', '09/01/2020');
insert into users (id, balance, hash, name, reg_time) values (29, 3577.79, 'WA1WMAFE9FD638606', 'Leif', '11/05/2020');
insert into users (id, balance, hash, name, reg_time) values (30, 1801.9, '1G6DX6ED8B0495792', 'Darbie', '23/08/2020');
insert into users (id, balance, hash, name, reg_time) values (31, 4249.28, '1YVHZ8BH0B5222936', 'Remus', '13/03/2021');
insert into users (id, balance, hash, name, reg_time) values (32, 1093.4, '19UUA8F25DA945789', 'Charlotte', '11/03/2020');
insert into users (id, balance, hash, name, reg_time) values (33, 3378.6, 'WBAPH7C55BE337242', 'Dania', '26/08/2021');
insert into users (id, balance, hash, name, reg_time) values (34, 1301.29, '2HNYD2H20CH318283', 'Nadia', '25/04/2021');
insert into users (id, balance, hash, name, reg_time) values (35, 3221.79, 'WAUHGBFC5DN894482', 'Myron', '26/02/2020');
insert into users (id, balance, hash, name, reg_time) values (36, 3849.77, 'WBAUP7C54BV705156', 'Elvis', '04/07/2020');
insert into users (id, balance, hash, name, reg_time) values (37, 3002.57, 'WAUBF98E08A895200', 'Agosto', '07/11/2021');
insert into users (id, balance, hash, name, reg_time) values (38, 1869.87, 'JTMHY7AJ3B4929834', 'Reuven', '23/12/2020');
insert into users (id, balance, hash, name, reg_time) values (39, 240.88, 'JM1NC2SF9F0935486', 'Karrah', '26/06/2020');
insert into users (id, balance, hash, name, reg_time) values (40, 4600.75, 'WAUAH94F27N555994', 'Enid', '08/09/2021');
insert into users (id, balance, hash, name, reg_time) values (41, 1481.67, '1G6DB1EDXB0226579', 'Norean', '03/04/2021');
insert into users (id, balance, hash, name, reg_time) values (42, 4217.93, '1GKKRNED4CJ124718', 'L;urette', '09/01/2021');
insert into users (id, balance, hash, name, reg_time) values (43, 4618.29, '1GYS4PKJ3FR809079', 'Caro', '24/05/2020');
insert into users (id, balance, hash, name, reg_time) values (44, 1914.74, '3C4PDCAB2FT457909', 'Ddene', '28/06/2020');
insert into users (id, balance, hash, name, reg_time) values (45, 3944.8, 'WAU2GAFC6CN256899', 'Myles', '22/02/2020');
insert into users (id, balance, hash, name, reg_time) values (46, 3852.76, '1G6AM5SX1E0004424', 'Sybil', '27/03/2020');
insert into users (id, balance, hash, name, reg_time) values (47, 2923.52, '5LMJJ3J59DE710268', 'Shandie', '19/07/2020');
insert into users (id, balance, hash, name, reg_time) values (48, 1816.48, '1G6DA1E36E0600832', 'Xylia', '30/04/2020');
insert into users (id, balance, hash, name, reg_time) values (49, 895.68, '1N6AA0CJ7DN878374', 'Iormina', '17/08/2021');
insert into users (id, balance, hash, name, reg_time) values (50, 316.42, '1G4GC5ER5CF802549', 'Jessie', '02/01/2020');
insert into users (id, balance, hash, name, reg_time) values (51, 2598.73, 'WAUJFAFH3DN199881', 'Teodorico', '25/01/2021');
insert into users (id, balance, hash, name, reg_time) values (52, 2283.91, '19UUA65524A139358', 'Mauricio', '18/02/2021');
insert into users (id, balance, hash, name, reg_time) values (53, 3153.84, '2HKRM3H37CH106013', 'Page', '20/10/2020');
insert into users (id, balance, hash, name, reg_time) values (54, 3872.94, 'JN8AZ2ND8F9376830', 'Shannon', '21/11/2021');
insert into users (id, balance, hash, name, reg_time) values (55, 2801.85, 'WAUFGBFB6BN608702', 'Carie', '06/05/2020');
insert into users (id, balance, hash, name, reg_time) values (56, 511.16, '5UXFG8C57EL933832', 'Aaren', '31/10/2021');
insert into users (id, balance, hash, name, reg_time) values (57, 999.81, '3N1AB7AP3FY815717', 'Lari', '18/12/2021');
insert into users (id, balance, hash, name, reg_time) values (58, 4623.57, 'WBS3R9C5XFK518556', 'Cleon', '30/05/2021');
insert into users (id, balance, hash, name, reg_time) values (59, 1502.99, '1FTEX1CW1AF754463', 'Doro', '12/09/2021');
insert into users (id, balance, hash, name, reg_time) values (60, 128.01, 'WBA3T3C58EJ478307', 'Leona', '04/04/2021');
insert into users (id, balance, hash, name, reg_time) values (61, 1741.31, '1G6YV36A375580365', 'Dwight', '08/03/2020');
insert into users (id, balance, hash, name, reg_time) values (62, 3245.64, 'SCFAD02A56G468094', 'Saxon', '01/12/2020');
insert into users (id, balance, hash, name, reg_time) values (63, 1078.16, 'WP1AA2AP0AL653304', 'Agustin', '13/05/2021');
insert into users (id, balance, hash, name, reg_time) values (64, 1591.34, 'NM0KS6AN0AT745246', 'Jackie', '25/06/2020');
insert into users (id, balance, hash, name, reg_time) values (65, 1034.65, 'WAUJGBFCXDN765770', 'Ruddy', '28/06/2021');
insert into users (id, balance, hash, name, reg_time) values (66, 1561.67, 'KL4CJHSB2FB853840', 'Lezley', '09/10/2021');
insert into users (id, balance, hash, name, reg_time) values (67, 3985.45, '5GADV33LX6D301923', 'Tadio', '28/10/2020');
insert into users (id, balance, hash, name, reg_time) values (68, 2169.3, '5N1AZ2MH6FN079980', 'Candace', '25/11/2021');
insert into users (id, balance, hash, name, reg_time) values (69, 2613.45, 'WAUMV94E28N497898', 'Maire', '11/10/2021');
insert into users (id, balance, hash, name, reg_time) values (70, 3189.4, 'WAULD54B04N644002', 'Allsun', '15/06/2021');
insert into users (id, balance, hash, name, reg_time) values (71, 1636.37, '1D7RE3GK0AS463673', 'Whitaker', '07/05/2021');
insert into users (id, balance, hash, name, reg_time) values (72, 3130.48, '1VWAH7A35EC977135', 'Noella', '23/01/2020');
insert into users (id, balance, hash, name, reg_time) values (73, 4489.18, '3VWF17ATXFM998265', 'Marielle', '29/05/2020');
insert into users (id, balance, hash, name, reg_time) values (74, 1366.97, '2C3CDXHG0DH450202', 'Nancy', '21/01/2021');
insert into users (id, balance, hash, name, reg_time) values (75, 787.4, 'WAUBFAFL1DA501829', 'Kippy', '05/06/2020');
insert into users (id, balance, hash, name, reg_time) values (76, 279.89, '5UXZV8C56BL431702', 'Nikki', '26/05/2021');
insert into users (id, balance, hash, name, reg_time) values (77, 3527.05, '1G6DS1ED5B0857661', 'Sileas', '05/05/2021');
insert into users (id, balance, hash, name, reg_time) values (78, 2293.61, 'YV4902BZ6B1122922', 'Brandy', '30/08/2020');
insert into users (id, balance, hash, name, reg_time) values (79, 2809.1, '4T1BF1FK1EU711501', 'Moises', '17/01/2021');
insert into users (id, balance, hash, name, reg_time) values (80, 2826.32, 'WBAAZ33493K622662', 'Roshelle', '14/12/2020');
insert into users (id, balance, hash, name, reg_time) values (81, 1792.5, 'SCBET9ZA6FC205412', 'Ede', '08/11/2020');
insert into users (id, balance, hash, name, reg_time) values (82, 4618.41, 'WBA3A9G56DN144030', 'Pietro', '27/08/2020');
insert into users (id, balance, hash, name, reg_time) values (83, 3467.39, 'WAUMF68P76A696571', 'Lorette', '28/02/2020');
insert into users (id, balance, hash, name, reg_time) values (84, 4056.31, '1G6DA67V290764287', 'Phineas', '29/04/2021');
insert into users (id, balance, hash, name, reg_time) values (85, 2021.41, 'WA1VGAFP0FA126920', 'Griff', '25/09/2020');
insert into users (id, balance, hash, name, reg_time) values (86, 2283.19, 'KNAFT4A28B5503299', 'Alessandro', '19/12/2020');
insert into users (id, balance, hash, name, reg_time) values (87, 2194.4, 'WBAEV53403K267079', 'Gaspar', '28/09/2020');
insert into users (id, balance, hash, name, reg_time) values (88, 406.0, 'WAUEFAFL0EA695171', 'Lanny', '20/02/2020');
insert into users (id, balance, hash, name, reg_time) values (89, 4313.71, 'JTJHY7AX7B4551339', 'Drusi', '21/08/2020');
insert into users (id, balance, hash, name, reg_time) values (90, 823.18, '5FRYD4H61FB023657', 'Andrey', '14/10/2021');
insert into users (id, balance, hash, name, reg_time) values (91, 57.84, 'WBAPH57509N060928', 'Tanya', '15/09/2020');
insert into users (id, balance, hash, name, reg_time) values (92, 3554.61, 'JHMZE2H57DS712454', 'Bekki', '15/02/2021');
insert into users (id, balance, hash, name, reg_time) values (93, 762.79, 'JH4KA96631C096808', 'West', '06/01/2020');
insert into users (id, balance, hash, name, reg_time) values (94, 800.88, 'WAUVFAFR9DA894903', 'Sasha', '26/01/2021');
insert into users (id, balance, hash, name, reg_time) values (95, 4042.43, '5N1AA0ND5EN239143', 'Lazare', '14/12/2020');
insert into users (id, balance, hash, name, reg_time) values (96, 3137.99, 'WBAVB73557V594837', 'Harli', '30/03/2021');
insert into users (id, balance, hash, name, reg_time) values (97, 499.77, 'JTJBARBZ5F2167132', 'Teddie', '16/04/2020');
insert into users (id, balance, hash, name, reg_time) values (98, 4776.55, 'WP0AB2A84FK916191', 'Gweneth', '01/12/2020');
insert into users (id, balance, hash, name, reg_time) values (99, 1821.59, 'WBAKX8C57CC277321', 'Murdoch', '29/09/2021');
insert into users (id, balance, hash, name, reg_time) values (100, 3117.81, 'WBALZ3C51CC451921', 'Neil', '29/10/2021');
insert into users (id, balance, hash, name, reg_time) values (101, 2780.3, '3C6JD7AP8CG413434', 'Franky', '04/08/2020');
insert into users (id, balance, hash, name, reg_time) values (102, 1032.07, '3D7TP2CT5BG683232', 'Cherilyn', '24/09/2020');
insert into users (id, balance, hash, name, reg_time) values (103, 1322.99, 'WBAWL7C52AP410404', 'Rochelle', '14/12/2021');
insert into users (id, balance, hash, name, reg_time) values (104, 3019.64, 'WAUDFAFLXAN515600', 'Lionel', '04/01/2020');
insert into users (id, balance, hash, name, reg_time) values (105, 1849.06, 'KNADH5A3XA6324603', 'Modestine', '04/11/2021');
insert into users (id, balance, hash, name, reg_time) values (106, 853.65, 'WAUDG74F39N582998', 'Abram', '21/04/2020');
insert into users (id, balance, hash, name, reg_time) values (107, 946.14, 'WBAEN33494P203910', 'Pippo', '15/01/2020');
insert into users (id, balance, hash, name, reg_time) values (108, 3843.17, 'WDDEJ7EB1CA596181', 'Erminia', '19/06/2020');
insert into users (id, balance, hash, name, reg_time) values (109, 250.92, 'WAUNF98P28A802093', 'Allister', '17/08/2020');
insert into users (id, balance, hash, name, reg_time) values (110, 2298.89, '1G6AP5SX2F0300349', 'Stephi', '27/02/2020');
insert into users (id, balance, hash, name, reg_time) values (111, 2092.65, '1D7CW3GKXAS390590', 'Wendie', '30/08/2021');
insert into users (id, balance, hash, name, reg_time) values (112, 4941.86, '1G4HE57Y88U503790', 'Patrice', '17/03/2020');
insert into users (id, balance, hash, name, reg_time) values (113, 251.01, 'WA1DGBFE7ED506978', 'Gwendolen', '01/09/2021');
insert into users (id, balance, hash, name, reg_time) values (114, 3131.09, '3N1AB6AP0BL580534', 'Nealy', '09/12/2020');
insert into users (id, balance, hash, name, reg_time) values (115, 3098.11, '1G6YV34A955699411', 'Sarina', '06/01/2020');
insert into users (id, balance, hash, name, reg_time) values (116, 4822.17, '2C4RDGCG9DR704559', 'Isa', '19/04/2021');
insert into users (id, balance, hash, name, reg_time) values (117, 255.52, '1C6RD6FP7CS878186', 'Elissa', '28/03/2020');
insert into users (id, balance, hash, name, reg_time) values (118, 4304.3, '1G6DK8E37D0832635', 'Nicolis', '29/01/2021');
insert into users (id, balance, hash, name, reg_time) values (119, 4153.58, '1FTMF1C84AK130342', 'Way', '16/02/2020');
insert into users (id, balance, hash, name, reg_time) values (120, 535.96, '19XFB4F24DE326840', 'Codi', '26/07/2020');
insert into users (id, balance, hash, name, reg_time) values (121, 4218.78, '3VW467AT9DM115147', 'Gabbie', '09/07/2021');
insert into users (id, balance, hash, name, reg_time) values (122, 1610.36, 'JA32U1FU2CU049595', 'Luce', '12/01/2021');
insert into users (id, balance, hash, name, reg_time) values (123, 1363.14, '5N1AA0NC1BN999329', 'Maxwell', '20/01/2020');
insert into users (id, balance, hash, name, reg_time) values (124, 1840.18, 'JTEBU5JR5C5366093', 'Dorree', '30/04/2021');
insert into users (id, balance, hash, name, reg_time) values (125, 94.44, 'WAUSG74F19N685845', 'Ania', '09/01/2021');
insert into users (id, balance, hash, name, reg_time) values (126, 1510.04, 'WP0CA2A85EK771771', 'Dagny', '16/05/2021');
insert into users (id, balance, hash, name, reg_time) values (127, 4955.95, '1C6RD7LP9CS695916', 'Kippie', '15/08/2021');
insert into users (id, balance, hash, name, reg_time) values (128, 2975.33, '1FMJK1G58BE396375', 'Blakeley', '25/09/2021');
insert into users (id, balance, hash, name, reg_time) values (129, 1552.29, '1GD312CGXBF950795', 'Lawry', '01/07/2020');
insert into users (id, balance, hash, name, reg_time) values (130, 4253.51, 'WAUEFAFL4EN781088', 'Thatch', '22/08/2020');
insert into users (id, balance, hash, name, reg_time) values (131, 610.69, 'SCFAD22333K523549', 'Witty', '08/04/2021');
insert into users (id, balance, hash, name, reg_time) values (132, 3740.54, '1GKMCCE34AR263428', 'Jordan', '10/03/2020');
insert into users (id, balance, hash, name, reg_time) values (133, 3954.53, 'JM1CR2W30A0892168', 'Court', '02/06/2021');
insert into users (id, balance, hash, name, reg_time) values (134, 627.77, '3C63D2GL3CG910424', 'Laraine', '05/11/2020');
insert into users (id, balance, hash, name, reg_time) values (135, 1404.03, '3D7TP2HTXAG391891', 'Darci', '08/08/2020');
insert into users (id, balance, hash, name, reg_time) values (136, 4221.5, '1N6AA0CJ2FN859735', 'Avivah', '23/01/2021');
insert into users (id, balance, hash, name, reg_time) values (137, 1976.87, '3FAHP0CGXCR760454', 'Levon', '28/06/2020');
insert into users (id, balance, hash, name, reg_time) values (138, 2059.5, '3MZBM1L7XEM590950', 'Roley', '10/09/2021');
insert into users (id, balance, hash, name, reg_time) values (139, 1697.98, 'WAUYGBFC2CN466299', 'Iggie', '01/05/2021');
insert into users (id, balance, hash, name, reg_time) values (140, 4158.95, 'WBAPK7C59BA768658', 'Theodore', '19/01/2020');
insert into users (id, balance, hash, name, reg_time) values (141, 1361.66, '3D73Y3CL2AG140938', 'Janine', '18/10/2021');
insert into users (id, balance, hash, name, reg_time) values (142, 884.36, 'JTHBC1KS9B5836768', 'Winona', '22/02/2021');
insert into users (id, balance, hash, name, reg_time) values (143, 1609.31, '2HNYD28898H683170', 'Isahella', '11/09/2021');
insert into users (id, balance, hash, name, reg_time) values (144, 1460.29, 'WAUKG74F86N555167', 'Eudora', '14/07/2021');
insert into users (id, balance, hash, name, reg_time) values (145, 4955.77, '1FTSW3A56AE221395', 'Garrett', '29/01/2020');
insert into users (id, balance, hash, name, reg_time) values (146, 1270.73, '3C4PDCAB5FT582712', 'Magdalene', '13/04/2021');
insert into users (id, balance, hash, name, reg_time) values (147, 4501.95, 'WBAEN33434E407159', 'Rog', '31/08/2021');
insert into users (id, balance, hash, name, reg_time) values (148, 2922.14, '1G6AH5RX2E0506370', 'Kellina', '31/05/2021');
insert into users (id, balance, hash, name, reg_time) values (149, 2258.01, '2HNYD2H22AH292945', 'Betteann', '14/03/2020');
insert into users (id, balance, hash, name, reg_time) values (150, 1389.69, '1G6AV5S80F0003062', 'Datha', '16/07/2021');
insert into users (id, balance, hash, name, reg_time) values (151, 4298.43, '1FTEW1C8XAF521217', 'Jillayne', '29/05/2020');
insert into users (id, balance, hash, name, reg_time) values (152, 3842.13, '2D4RN4DG0BR707926', 'Hali', '09/02/2020');
insert into users (id, balance, hash, name, reg_time) values (153, 3577.83, 'WBA3T1C53FP781384', 'Jean', '31/07/2020');
insert into users (id, balance, hash, name, reg_time) values (154, 1095.83, '3VWJX7AJXAM965461', 'Nonah', '29/09/2020');
insert into users (id, balance, hash, name, reg_time) values (155, 1816.49, 'WAUKG74F06N240640', 'Belvia', '01/04/2021');
insert into users (id, balance, hash, name, reg_time) values (156, 4302.17, 'WAUKFBFL4DA477046', 'Kipp', '05/07/2021');
insert into users (id, balance, hash, name, reg_time) values (157, 1490.73, 'WAUSH98E87A781020', 'Glenda', '29/10/2021');
insert into users (id, balance, hash, name, reg_time) values (158, 1845.77, '2G61V5S82F9666395', 'Josephine', '02/12/2020');
insert into users (id, balance, hash, name, reg_time) values (159, 2954.1, 'KNDJT2A12A7076343', 'Chaim', '03/10/2021');
insert into users (id, balance, hash, name, reg_time) values (160, 4174.4, 'WA1YD64B65N278993', 'Buddie', '21/08/2020');
insert into users (id, balance, hash, name, reg_time) values (161, 1404.06, 'JTEBU5JR0A5893245', 'Elsbeth', '24/08/2020');
insert into users (id, balance, hash, name, reg_time) values (162, 4359.59, 'WAULFAFHXDN766581', 'Jan', '27/10/2020');
insert into users (id, balance, hash, name, reg_time) values (163, 4349.16, 'WBA3X5C51ED737833', 'Karlan', '08/09/2020');
insert into users (id, balance, hash, name, reg_time) values (164, 4482.69, 'SCFAD05D79G398141', 'Freeman', '16/09/2020');
insert into users (id, balance, hash, name, reg_time) values (165, 4406.09, '3C3CFFER5FT906683', 'Camella', '16/10/2020');
insert into users (id, balance, hash, name, reg_time) values (166, 821.84, 'WBALW7C54ED374524', 'Xylia', '23/09/2021');
insert into users (id, balance, hash, name, reg_time) values (167, 4104.89, 'SCFBB04B48G204674', 'Ivette', '10/09/2020');
insert into users (id, balance, hash, name, reg_time) values (168, 1540.17, '3D7TP2CTXAG935328', 'Bianka', '17/04/2021');
insert into users (id, balance, hash, name, reg_time) values (169, 2435.58, 'WBAVC73568A505296', 'Jeth', '17/05/2020');
insert into users (id, balance, hash, name, reg_time) values (170, 1216.23, 'WAUHF68PX6A095558', 'West', '16/06/2020');
insert into users (id, balance, hash, name, reg_time) values (171, 1872.67, '1GKS1AKC3FR445165', 'Dulcine', '02/06/2021');
insert into users (id, balance, hash, name, reg_time) values (172, 3646.69, 'WBAYP1C59DD765375', 'Reid', '07/12/2020');
insert into users (id, balance, hash, name, reg_time) values (173, 431.91, 'JH4CU2E67AC843752', 'Benny', '09/11/2021');
insert into users (id, balance, hash, name, reg_time) values (174, 3356.5, '1G6DE8EY4B0226581', 'Lorelei', '13/02/2021');
insert into users (id, balance, hash, name, reg_time) values (175, 2940.25, 'JH4DC53823C447552', 'Angelia', '15/12/2020');
insert into users (id, balance, hash, name, reg_time) values (176, 2108.45, '2D4RN1AG1BR065753', 'Engelbert', '24/09/2020');
insert into users (id, balance, hash, name, reg_time) values (177, 1432.75, 'JH4DC54845S010238', 'Caddric', '15/05/2021');
insert into users (id, balance, hash, name, reg_time) values (178, 3849.3, '1FMCU4K32AK201915', 'Brandon', '22/12/2020');
insert into users (id, balance, hash, name, reg_time) values (179, 1478.34, 'WAUFFAFL3BA076421', 'Pamela', '22/02/2020');
insert into users (id, balance, hash, name, reg_time) values (180, 4406.38, '1G6DF8E54E0042734', 'Bone', '12/06/2020');
insert into users (id, balance, hash, name, reg_time) values (181, 686.94, '3C6TD5LT5CG682708', 'Syd', '31/01/2020');
insert into users (id, balance, hash, name, reg_time) values (182, 1003.85, 'WAUAF78E56A076695', 'Brigham', '24/09/2020');
insert into users (id, balance, hash, name, reg_time) values (183, 2070.93, '1G6DL8EV6A0166510', 'Jemie', '28/12/2021');
insert into users (id, balance, hash, name, reg_time) values (184, 2960.63, 'JN1AJ0HP7AM277843', 'Leonelle', '24/09/2021');
insert into users (id, balance, hash, name, reg_time) values (185, 4221.89, '5TDBCRFH1FS963979', 'Robin', '02/12/2021');
insert into users (id, balance, hash, name, reg_time) values (186, 143.12, '4USBT53585L572146', 'Myrwyn', '04/09/2020');
insert into users (id, balance, hash, name, reg_time) values (187, 1831.31, '3C63D2GLXCG104189', 'Almeta', '12/12/2021');
insert into users (id, balance, hash, name, reg_time) values (188, 2397.35, 'WBA3A5C53FF184528', 'Danila', '12/09/2021');
insert into users (id, balance, hash, name, reg_time) values (189, 3074.38, 'WAUDF48HX7A934248', 'Jone', '11/02/2021');
insert into users (id, balance, hash, name, reg_time) values (190, 716.25, '3VW4A7AT2DM495804', 'Saunders', '01/12/2021');
insert into users (id, balance, hash, name, reg_time) values (191, 2864.87, '1G4CU541914283117', 'Isador', '22/05/2021');
insert into users (id, balance, hash, name, reg_time) values (192, 4286.31, 'WA1EY74L98D806395', 'Spenser', '18/02/2020');
insert into users (id, balance, hash, name, reg_time) values (193, 4458.92, 'SCFEDCAD4BG690943', 'Shay', '13/04/2021');
insert into users (id, balance, hash, name, reg_time) values (194, 3196.57, 'WA1CGAFE8DD951802', 'Dalis', '10/10/2020');
insert into users (id, balance, hash, name, reg_time) values (195, 1269.8, '1B3CB3HA7BD868628', 'Shaina', '08/08/2020');
insert into users (id, balance, hash, name, reg_time) values (196, 269.49, '1G6YV36A975615670', 'Elvira', '12/02/2021');
insert into users (id, balance, hash, name, reg_time) values (197, 1812.34, 'WAULK78K99N939327', 'Ferdinanda', '02/04/2020');
insert into users (id, balance, hash, name, reg_time) values (198, 1482.3, 'WBSBR93405P367845', 'Kaile', '11/11/2021');
insert into users (id, balance, hash, name, reg_time) values (199, 2091.14, '3FAHP0CGXBR784168', 'Brier', '23/12/2020');
insert into users (id, balance, hash, name, reg_time) values (200, 2422.28, 'WA1YD64B32N711410', 'Lise', '11/04/2021');
insert into users (id, balance, hash, name, reg_time) values (201, 3013.12, 'WAUAFAFL3FN912950', 'Baxy', '03/08/2020');
insert into users (id, balance, hash, name, reg_time) values (202, 3224.79, 'WAUEF98E08A414388', 'Immanuel', '05/01/2020');
insert into users (id, balance, hash, name, reg_time) values (203, 2473.32, 'WAUKF98E15A201724', 'Tome', '13/09/2021');
insert into users (id, balance, hash, name, reg_time) values (204, 4958.94, '1G4HA5EM7BU687820', 'Perla', '02/11/2020');
insert into users (id, balance, hash, name, reg_time) values (205, 3659.16, 'KNAFX6A84E5671658', 'Baily', '09/09/2020');
insert into users (id, balance, hash, name, reg_time) values (206, 3156.0, 'JTDZN3EU4EJ975205', 'Richard', '26/02/2021');
insert into users (id, balance, hash, name, reg_time) values (207, 3361.82, '1FMCU0D73AK372830', 'Ade', '14/10/2021');
insert into users (id, balance, hash, name, reg_time) values (208, 3435.65, 'JN8AZ1MUXEW762158', 'Danielle', '02/03/2021');
insert into users (id, balance, hash, name, reg_time) values (209, 160.45, 'WBA3X9C55ED664165', 'Dorthy', '12/10/2021');
insert into users (id, balance, hash, name, reg_time) values (210, 1914.32, 'WBSKG9C5XDJ067326', 'Shurlock', '14/08/2020');
insert into users (id, balance, hash, name, reg_time) values (211, 3315.71, '5UXFF03559L639422', 'Marissa', '26/09/2021');
insert into users (id, balance, hash, name, reg_time) values (212, 450.01, '1G6AL5S33D0229958', 'Lilllie', '23/10/2020');
insert into users (id, balance, hash, name, reg_time) values (213, 575.9, 'KMHHT6KD0BU861151', 'Gaspard', '28/03/2020');
insert into users (id, balance, hash, name, reg_time) values (214, 4871.54, '3D7LP2ET9AG754301', 'Brett', '27/02/2021');
insert into users (id, balance, hash, name, reg_time) values (215, 3429.48, '1D7RV1CP0BS358350', 'Allister', '22/06/2020');
insert into users (id, balance, hash, name, reg_time) values (216, 4777.1, 'WAUVT58E13A265578', 'Early', '27/12/2020');
insert into users (id, balance, hash, name, reg_time) values (217, 1779.28, '1N6AD0CU4EN300980', 'Hanson', '04/05/2020');
insert into users (id, balance, hash, name, reg_time) values (218, 3988.53, '3VW8S7AT4FM171092', 'Lynn', '20/07/2021');
insert into users (id, balance, hash, name, reg_time) values (219, 1164.76, '5NPET4AC7AH407198', 'Dorotea', '22/01/2021');
insert into users (id, balance, hash, name, reg_time) values (220, 3642.73, 'JN1AZ4EH1FM851972', 'Claiborne', '20/09/2020');
insert into users (id, balance, hash, name, reg_time) values (221, 2674.41, '1FTEW1C81FK356642', 'Theresina', '22/02/2020');
insert into users (id, balance, hash, name, reg_time) values (222, 3375.62, 'WBALM5C55BE430647', 'Fenelia', '29/09/2020');
insert into users (id, balance, hash, name, reg_time) values (223, 3303.05, '2C3CA1CV9AH876381', 'Delilah', '14/02/2020');
insert into users (id, balance, hash, name, reg_time) values (224, 2129.77, 'ZFF75VFA3F0274686', 'Giacinta', '07/02/2021');
insert into users (id, balance, hash, name, reg_time) values (225, 3599.56, '2T3BFREV8EW283038', 'Faina', '16/11/2021');
insert into users (id, balance, hash, name, reg_time) values (226, 1981.17, '5UXFA13586L222635', 'Saraann', '09/11/2020');
insert into users (id, balance, hash, name, reg_time) values (227, 198.9, 'JM3TB2BA3D0109428', 'Leonidas', '23/10/2020');
insert into users (id, balance, hash, name, reg_time) values (228, 3092.91, 'WAUVT58E03A655233', 'Shelley', '05/04/2020');
insert into users (id, balance, hash, name, reg_time) values (229, 3458.52, 'W06VR54R81R131242', 'Daisey', '19/11/2021');
insert into users (id, balance, hash, name, reg_time) values (230, 1940.25, 'WAUGGAFC8CN041546', 'Hynda', '22/02/2020');
insert into users (id, balance, hash, name, reg_time) values (231, 2086.43, '5XYZG3AB7BG192275', 'Luce', '11/04/2020');
insert into users (id, balance, hash, name, reg_time) values (232, 4088.86, 'YV4902BZ1B1312496', 'Jemmie', '21/04/2020');
insert into users (id, balance, hash, name, reg_time) values (233, 4346.29, 'WAUJFAFH9BN346136', 'Moss', '28/06/2020');
insert into users (id, balance, hash, name, reg_time) values (234, 4122.29, 'WBAFR9C51CC174901', 'Pauli', '16/11/2021');
insert into users (id, balance, hash, name, reg_time) values (235, 2550.8, '3MZBM1L75EM030947', 'Brendis', '26/11/2021');
insert into users (id, balance, hash, name, reg_time) values (236, 4710.69, '3C4PDCDG3CT590939', 'Kirbee', '26/05/2021');
insert into users (id, balance, hash, name, reg_time) values (237, 4639.68, 'WAUVT58E42A623304', 'Cecil', '12/02/2021');
insert into users (id, balance, hash, name, reg_time) values (238, 522.89, '3GYFNBE31CS584104', 'Charlean', '05/05/2021');
insert into users (id, balance, hash, name, reg_time) values (239, 3629.83, '4T3BA3BB4CU080991', 'Dahlia', '02/12/2021');
insert into users (id, balance, hash, name, reg_time) values (240, 587.32, 'KNAFU6A22B5250621', 'Lev', '10/04/2021');
insert into users (id, balance, hash, name, reg_time) values (241, 4212.58, 'KNADN5A35F6426245', 'Archibald', '04/04/2020');
insert into users (id, balance, hash, name, reg_time) values (242, 3096.84, '1G4HJ5EM4BU658470', 'Jonis', '30/01/2020');
insert into users (id, balance, hash, name, reg_time) values (243, 4152.53, 'WBAAV53421J928581', 'Zuzana', '30/12/2020');
insert into users (id, balance, hash, name, reg_time) values (244, 3109.13, '1G6DH5EY2B0021637', 'Margeaux', '14/07/2020');
insert into users (id, balance, hash, name, reg_time) values (245, 3875.27, 'JN8AE2KP7B9807128', 'Marguerite', '17/04/2020');
insert into users (id, balance, hash, name, reg_time) values (246, 3863.08, 'KNAFT4A26C5624592', 'Salomon', '23/05/2021');
insert into users (id, balance, hash, name, reg_time) values (247, 820.04, 'JN8AZ2NEXF9987435', 'Daniela', '29/05/2021');
insert into users (id, balance, hash, name, reg_time) values (248, 17.5, '1G6KH5E60BU922665', 'Garnette', '27/05/2020');
insert into users (id, balance, hash, name, reg_time) values (249, 2597.67, 'WBA1F9C51FV020121', 'Lucine', '17/09/2020');
insert into users (id, balance, hash, name, reg_time) values (250, 3751.25, '1FTMF1CW6AK355618', 'Clerkclaude', '23/12/2021');

insert into book2user (id_type, id_book, id_user, time) values (1, 53, 51, '13/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 12, 207, '12/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 59, 201, '03/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 39, 224, '23/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 25, 94, '14/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 4, 96, '30/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 63, 169, '23/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 52, 123, '17/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 64, 181, '19/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 11, 26, '05/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 29, 85, '03/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 26, 69, '11/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 1, 248, '31/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 31, 170, '23/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 10, 182, '20/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 21, 106, '10/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 39, 20, '15/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 33, 84, '03/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 52, 33, '28/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 6, 109, '28/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 28, 189, '09/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 2, 220, '18/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 10, 239, '19/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 57, 225, '08/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 58, 94, '09/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 26, 19, '02/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 59, 228, '08/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 19, 168, '31/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 10, 127, '04/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 54, 33, '08/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 42, 207, '18/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 49, 150, '23/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 6, 215, '24/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 35, 33, '04/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 33, 152, '09/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 64, 84, '16/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 14, 139, '22/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 12, 170, '07/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 33, 168, '11/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 50, 241, '24/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 16, 139, '21/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 9, 96, '05/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 27, 95, '08/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 53, 201, '15/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 36, 103, '15/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 40, 111, '03/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 23, 43, '17/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 50, 30, '28/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 37, 130, '13/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 40, 23, '01/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 22, 245, '10/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 14, 94, '15/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 196, '17/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 12, 217, '07/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 10, 221, '16/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 28, 107, '04/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 44, 109, '10/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 9, 106, '16/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 63, 213, '26/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 20, 80, '23/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 35, 16, '05/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 17, 63, '12/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 10, 114, '27/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 28, 11, '12/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 58, 59, '15/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 34, 61, '12/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 37, 36, '22/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 56, 88, '31/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 4, 231, '05/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 27, 239, '24/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 199, '29/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 46, 14, '16/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 14, 133, '13/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 21, 97, '25/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 51, 202, '21/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 49, 164, '13/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 35, 62, '03/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 59, 193, '20/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 36, 185, '23/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 45, 38, '24/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 40, 175, '01/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 28, 163, '04/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 50, 217, '11/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 42, 219, '10/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 6, 174, '12/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 177, '30/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 62, 202, '07/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 42, 9, '11/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 19, 120, '19/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 18, 212, '20/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 2, 91, '17/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 36, 92, '16/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 53, 103, '11/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 44, 246, '24/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 36, 144, '22/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 40, 163, '06/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 41, 41, '16/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 31, '09/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 27, 214, '09/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 55, 96, '16/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 51, 70, '24/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 39, 221, '25/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 13, 246, '28/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 7, 28, '29/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 10, 143, '13/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 46, 143, '21/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 11, 44, '24/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 6, 10, '06/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 22, 205, '29/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 5, 103, '09/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 3, 37, '15/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 61, 5, '12/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 3, 146, '04/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 9, 84, '06/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 12, 199, '25/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 57, 18, '20/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 24, 183, '18/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 42, 248, '10/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 5, 143, '31/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 49, 238, '12/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 56, 161, '12/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 37, 154, '17/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 27, 193, '04/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 52, 134, '17/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 35, 77, '07/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 32, 116, '12/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 15, 196, '11/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 18, 87, '06/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 41, 123, '24/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 16, 84, '22/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 48, 31, '08/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 42, 107, '22/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 51, 47, '08/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 47, 217, '29/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 19, 205, '27/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 8, 113, '23/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 8, 169, '08/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 36, 58, '04/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 23, 47, '09/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 48, 44, '15/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 80, '12/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 4, 175, '16/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 30, 184, '28/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 52, 178, '08/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 52, 160, '10/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 55, 3, '08/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 34, 65, '09/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 34, 229, '12/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 45, 97, '21/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 45, 196, '29/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 12, 17, '12/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 3, 83, '06/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 58, 185, '27/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 60, 84, '26/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 7, 87, '28/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 30, 128, '06/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 46, 35, '09/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 13, 162, '13/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 46, 126, '29/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 10, 13, '10/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 63, 58, '30/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 45, 1, '22/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 24, 73, '29/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 2, 160, '13/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 38, 129, '13/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 46, 106, '07/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 49, 106, '17/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 50, 172, '26/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 43, 154, '27/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 35, 24, '08/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 21, 216, '06/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 35, 72, '04/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 8, 2, '29/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 9, 119, '17/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 3, 1, '14/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 61, 63, '07/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 117, '14/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 24, 250, '28/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 21, 195, '09/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 24, 68, '25/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 53, 108, '07/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 36, 53, '29/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 52, 136, '19/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 25, 29, '20/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 54, 188, '16/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 46, 235, '23/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 58, 194, '29/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 2, 184, '21/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 8, 174, '03/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 18, 8, '14/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 19, 212, '02/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 48, 165, '11/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 55, 71, '01/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 32, 84, '14/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 48, 161, '02/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 46, 73, '10/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 13, 126, '30/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 59, 191, '04/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 1, 91, '01/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 35, 85, '02/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 24, 31, '01/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 13, 30, '27/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 39, 37, '30/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 18, 224, '09/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 4, 39, '24/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 53, 99, '27/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 9, 232, '13/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 46, 97, '18/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 63, 69, '30/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 61, 11, '01/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 11, 146, '26/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 39, 72, '29/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 17, 149, '21/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 21, 235, '04/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 35, 128, '08/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 53, 249, '19/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 47, 84, '24/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 61, 107, '08/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 51, 137, '25/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 6, 133, '09/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 22, 215, '03/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 3, 157, '02/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 40, 23, '08/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 12, 100, '19/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 23, 147, '30/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 42, 152, '12/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 88, '20/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 2, 14, '31/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 13, 62, '26/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 40, 140, '26/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 43, 84, '08/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 23, 162, '12/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 51, 144, '09/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 43, 202, '27/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 15, 219, '17/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 41, 168, '14/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 62, 98, '21/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 32, 210, '26/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 58, 179, '19/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 175, '21/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 32, 116, '12/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 43, 93, '17/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 20, 128, '26/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 44, 81, '11/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 50, 43, '04/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 29, 135, '20/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 27, 68, '17/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 61, 186, '24/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 19, 139, '18/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 15, 240, '16/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 43, 166, '09/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 26, 243, '03/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 8, 186, '01/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 3, 102, '02/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 46, 156, '24/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 29, 118, '29/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 29, 114, '22/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 52, 1, '21/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 52, 114, '25/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 52, 71, '17/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 33, 228, '13/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 41, 67, '29/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 39, 72, '18/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 56, 72, '31/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 61, 88, '14/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 4, 248, '25/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 53, 174, '11/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 14, 88, '06/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 55, 15, '26/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 14, 246, '19/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 5, 125, '28/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 14, 39, '02/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 31, 221, '01/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 42, 233, '21/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 7, 134, '25/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 37, 184, '30/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 28, 41, '22/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 45, 199, '12/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 6, 38, '26/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 46, 125, '08/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 49, 221, '31/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 39, 21, '27/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 22, 229, '21/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 61, 4, '02/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 1, 54, '30/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 51, 89, '07/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 38, 161, '18/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 18, 25, '27/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 26, 229, '28/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 31, 8, '09/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 64, 37, '27/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 32, 164, '17/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 53, 243, '23/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 55, 232, '05/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 32, 22, '19/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 38, 76, '13/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 14, 215, '20/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 11, 203, '30/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 16, 190, '19/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 35, 49, '16/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 43, 219, '14/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 10, 242, '06/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 44, 158, '11/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 12, 159, '02/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 12, 17, '16/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 15, 235, '25/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 21, 197, '28/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 9, 48, '19/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 20, 155, '07/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 59, 106, '11/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 5, 140, '17/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 12, 50, '07/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 20, 144, '10/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 30, 2, '29/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 16, 178, '19/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 11, 206, '18/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 40, 239, '10/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 37, 10, '06/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 29, 231, '10/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 17, 91, '27/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 56, 228, '11/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 15, 127, '29/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 6, 16, '20/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 53, 90, '24/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 63, 201, '05/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 4, 127, '29/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 5, 34, '20/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 3, 240, '24/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 42, 105, '21/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 19, 203, '03/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 48, 67, '09/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 40, 84, '11/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 12, 221, '22/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 31, 50, '23/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 73, '19/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 25, 129, '26/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 33, 98, '29/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 23, 13, '03/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 114, '18/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 61, 116, '08/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 52, 197, '02/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 45, 235, '24/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 34, 12, '15/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 25, 53, '21/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 24, 22, '31/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 9, 213, '30/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 27, 47, '07/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 16, 193, '30/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 219, '22/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 15, 133, '29/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 236, '20/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 11, 162, '26/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 37, 100, '15/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 64, 65, '19/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 30, 240, '24/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 10, 236, '10/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 60, 147, '31/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 9, 7, '05/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 26, 199, '25/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 61, 102, '10/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 38, 165, '17/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 41, 61, '03/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 14, 66, '21/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 18, 242, '07/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 61, 24, '06/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 47, 148, '10/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 24, 37, '31/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 22, 40, '28/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 64, 78, '06/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 37, 243, '20/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 25, 181, '16/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 8, 237, '03/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 43, 94, '05/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 8, 219, '20/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 18, 100, '19/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 59, 192, '05/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 53, 159, '05/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 18, 17, '10/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 22, 43, '25/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 51, 69, '05/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 3, 77, '14/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 22, 83, '09/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 55, 235, '05/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 54, 131, '19/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 36, 245, '08/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 35, 163, '15/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 10, 136, '30/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 46, 236, '02/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 21, 70, '29/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 6, 144, '18/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 22, 64, '30/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 55, 28, '06/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 49, 86, '02/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 23, 210, '26/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 54, 200, '15/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 17, 227, '09/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 2, '13/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 52, 234, '14/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 51, 106, '15/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 32, 204, '23/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 28, 138, '09/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 23, 151, '11/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 23, 104, '24/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 15, 136, '27/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 38, 181, '14/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 29, 233, '23/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 7, 113, '30/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 2, 73, '13/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 5, 239, '22/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 36, 152, '29/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 42, 92, '25/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 59, 139, '05/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 9, 75, '14/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 8, 189, '11/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 18, 165, '12/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 18, 77, '12/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 8, 229, '10/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 11, 7, '08/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 42, 83, '15/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 62, 103, '08/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 24, 200, '14/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 37, 200, '22/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 47, 10, '22/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 13, 235, '07/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 56, 7, '12/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 52, 80, '03/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 31, 52, '16/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 12, 57, '27/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 3, 162, '19/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 38, 108, '17/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 63, 40, '03/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 35, 184, '10/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 7, 164, '04/08/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 59, 135, '01/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 47, 12, '23/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 34, 52, '15/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 42, 143, '14/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 57, 67, '20/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 22, 71, '01/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 31, 63, '19/10/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 27, 65, '19/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 57, 36, '05/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 18, 76, '23/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 10, 226, '01/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 24, 109, '24/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 4, 125, '12/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 27, 117, '09/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 9, 82, '22/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 47, 92, '08/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 26, 200, '05/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 46, 12, '19/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 41, 141, '12/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 3, 187, '16/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 53, 149, '18/07/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 25, 164, '19/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 11, 177, '13/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 60, 103, '19/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 10, 87, '27/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 22, 16, '26/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 51, 186, '06/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 38, 118, '01/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 48, 152, '19/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 62, 193, '16/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 24, 143, '04/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 8, 221, '20/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 21, 16, '25/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 1, 4, '09/02/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 45, 48, '05/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 32, 174, '05/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 42, 22, '27/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 15, 166, '29/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 51, '23/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 3, 21, '31/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (4, 34, 6, '04/09/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 9, 164, '12/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 23, 162, '22/02/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 58, 237, '26/06/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 12, 52, '26/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 40, 248, '11/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 57, 211, '15/01/2020');
insert into book2user (id_type, id_book, id_user, time) values (2, 17, 66, '13/05/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 6, 17, '26/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 43, 138, '08/06/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 19, 177, '18/01/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 48, 193, '14/04/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 27, 250, '18/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 44, 8, '18/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 42, 85, '22/09/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 51, 224, '14/08/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 62, 38, '07/10/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 10, 80, '22/11/2021');
insert into book2user (id_type, id_book, id_user, time) values (1, 23, 20, '25/03/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 13, 163, '08/05/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 41, 90, '19/03/2020');
insert into book2user (id_type, id_book, id_user, time) values (4, 32, 136, '28/11/2020');
insert into book2user (id_type, id_book, id_user, time) values (1, 60, 30, '25/07/2021');
insert into book2user (id_type, id_book, id_user, time) values (3, 63, 245, '30/12/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 33, 190, '20/04/2020');
insert into book2user (id_type, id_book, id_user, time) values (3, 54, 172, '04/12/2021');
insert into book2user (id_type, id_book, id_user, time) values (2, 15, 153, '21/04/2020');

insert into book_user_rating (id_book, id_user, time, rate) values (92, 214, '05.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 226, '09.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 33, '17.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 123, '04.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 72, '18.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 128, '25.04.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 148, '18.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 188, '09.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (20, 158, '23.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 193, '06.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 184, '18.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 67, '08.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 216, '06.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 170, '29.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 192, '29.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 185, '11.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 61, '30.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 153, '10.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 201, '05.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 42, '23.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 242, '06.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 56, '18.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 250, '24.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 27, '27.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 211, '21.04.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 166, '06.06.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (82, 9, '01.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 81, '15.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 87, '01.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 218, '03.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 108, '12.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 38, '13.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 231, '25.08.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 18, '01.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 103, '17.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 90, '01.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 241, '01.02.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 99, '15.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 79, '04.02.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 7, '20.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 216, '08.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 92, '16.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 21, '07.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 46, '15.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 243, '24.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 58, '10.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 140, '12.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 47, '22.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 30, '01.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 209, '01.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 165, '25.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 243, '02.07.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 141, '17.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 10, '01.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 5, '23.02.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 80, '22.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (10, 198, '14.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 170, '28.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 117, '05.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 122, '22.02.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 187, '21.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 61, '04.11.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 109, '03.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 186, '17.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 243, '13.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 232, '30.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 96, '05.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 27, '08.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 46, '30.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 198, '25.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 153, '11.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 148, '04.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 6, '04.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 40, '29.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 89, '28.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 148, '19.11.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 89, '13.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 163, '30.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 240, '17.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 208, '13.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 102, '24.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 204, '13.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 69, '14.06.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 30, '15.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 175, '25.09.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 94, '04.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 98, '01.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 199, '10.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 112, '05.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 43, '02.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 6, '10.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 233, '14.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 127, '18.04.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 72, '31.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 156, '01.06.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 117, '04.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (39, 234, '06.06.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 69, '14.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 242, '12.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 241, '01.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 35, '20.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 172, '15.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 198, '16.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 120, '29.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 21, '18.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 82, '20.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 35, '11.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 158, '21.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 29, '22.09.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 13, '26.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 244, '17.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 216, '16.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 103, '14.06.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 173, '09.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 237, '12.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 104, '07.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 61, '17.04.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 79, '22.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 93, '21.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 126, '26.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 117, '04.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 82, '31.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 239, '12.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 12, '25.08.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 164, '09.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 234, '01.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 226, '16.11.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 69, '12.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 13, '27.07.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 233, '02.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 200, '09.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 153, '15.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 152, '24.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 188, '17.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 222, '01.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 207, '20.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 222, '05.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 32, '09.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 208, '19.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 32, '16.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 187, '23.11.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 206, '31.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (39, 148, '28.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (10, 15, '12.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 131, '06.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 5, '11.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 121, '07.05.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 164, '16.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 67, '27.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 242, '26.03.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 213, '26.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 151, '16.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 45, '19.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 216, '13.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 105, '25.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (20, 117, '15.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 62, '16.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 141, '01.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 142, '19.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (82, 245, '14.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 51, '29.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 20, '23.04.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 9, '27.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 237, '07.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 72, '26.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 236, '25.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 46, '21.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 98, '02.06.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (76, 180, '26.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 214, '12.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 5, '29.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 59, '30.09.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (8, 244, '25.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 39, '11.04.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 101, '23.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 194, '27.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 28, '26.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 137, '20.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (69, 90, '29.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 75, '07.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 101, '01.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 151, '11.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 246, '08.11.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 184, '30.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 29, '26.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 56, '29.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 35, '22.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 129, '07.02.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 206, '27.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 69, '28.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 29, '08.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 142, '20.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 131, '10.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 175, '31.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 78, '19.11.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 154, '20.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 45, '26.09.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 176, '27.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (82, 59, '26.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 42, '06.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 233, '19.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 233, '15.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 39, '27.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 193, '13.03.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 203, '26.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 35, '23.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 164, '14.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 90, '29.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 158, '28.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 98, '25.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 179, '02.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 54, '19.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 176, '19.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 166, '11.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 94, '14.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 21, '28.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 41, '03.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 119, '26.09.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 250, '31.12.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 161, '18.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 174, '27.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 126, '16.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 5, '30.05.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 73, '20.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 199, '28.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 214, '17.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 44, '02.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 195, '31.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 120, '02.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 56, '14.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 100, '19.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 212, '30.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 105, '27.10.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 226, '01.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (10, 125, '14.06.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 168, '28.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 239, '06.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (63, 180, '17.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 124, '22.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 12, '16.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 242, '07.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 227, '30.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 91, '26.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 162, '11.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 212, '06.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 244, '18.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 154, '23.06.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (63, 138, '26.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 249, '17.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 230, '05.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 245, '24.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 246, '04.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 193, '01.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 209, '19.02.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 180, '21.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 133, '09.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 246, '28.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 130, '18.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 12, '22.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 228, '26.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 73, '09.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 114, '10.06.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 192, '14.03.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 103, '20.11.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 230, '07.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 76, '06.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 175, '10.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 250, '20.03.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 185, '02.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 40, '07.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 50, '30.08.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 17, '08.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 149, '11.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 187, '04.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 52, '05.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 210, '30.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 77, '21.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 96, '24.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 241, '18.12.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 179, '14.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 138, '14.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 51, '05.05.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 156, '13.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 33, '26.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 18, '04.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 97, '24.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 27, '31.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 106, '19.12.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 196, '29.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (24, 107, '24.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 206, '03.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (79, 188, '12.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 53, '28.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 167, '16.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 122, '03.02.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 106, '22.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 237, '26.03.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (76, 231, '28.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 179, '28.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 159, '01.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 173, '16.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 216, '15.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 35, '11.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 102, '22.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (69, 249, '11.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 224, '14.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 173, '30.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 25, '05.03.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 235, '26.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 177, '03.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 192, '19.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 207, '09.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 97, '08.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 77, '17.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 236, '20.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 142, '05.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 31, '08.02.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 48, '20.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 203, '16.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 75, '11.04.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 158, '17.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 123, '14.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 90, '27.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 138, '25.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 197, '10.09.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 97, '27.11.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 213, '31.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 61, '13.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 64, '01.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 101, '21.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 27, '03.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 92, '18.02.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 149, '08.08.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 57, '13.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 20, '17.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 213, '07.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 168, '04.03.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 131, '27.02.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 53, '08.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 50, '15.04.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 225, '24.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 202, '11.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 173, '09.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 222, '14.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 223, '22.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 152, '24.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 24, '05.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 174, '24.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 141, '03.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 208, '09.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 121, '30.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 103, '15.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 28, '01.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 219, '10.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 136, '01.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 203, '08.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 97, '28.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 204, '28.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 136, '07.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 198, '08.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 174, '10.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 1, '14.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 87, '07.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 199, '06.09.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 27, '24.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 149, '01.04.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 236, '13.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 37, '04.05.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 164, '10.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 61, '05.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 158, '06.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 97, '13.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 214, '14.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 218, '28.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 30, '10.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 178, '21.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 9, '26.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 226, '27.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 19, '14.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 16, '09.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 47, '18.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 198, '01.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 55, '03.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (58, 250, '08.04.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 217, '20.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 65, '07.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 193, '06.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 90, '21.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 31, '06.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 31, '04.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 82, '13.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 240, '01.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 143, '25.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 114, '10.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 3, '01.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 9, '08.11.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 198, '27.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (39, 239, '09.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 21, '24.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 95, '29.08.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 28, '02.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 163, '22.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 212, '25.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 125, '10.09.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 132, '31.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (13, 214, '03.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 228, '24.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 3, '27.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 52, '09.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (69, 206, '09.11.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 211, '05.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (79, 47, '16.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 46, '25.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 177, '21.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 228, '12.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 221, '04.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 176, '16.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 219, '14.05.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 49, '15.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 187, '08.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 163, '03.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 171, '27.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 61, '04.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 116, '28.04.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 38, '28.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 37, '02.12.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 155, '18.11.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 84, '07.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 41, '04.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 234, '22.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 99, '24.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 224, '08.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 196, '08.07.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (8, 204, '16.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 114, '04.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 131, '25.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 123, '14.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 144, '04.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 117, '01.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 218, '26.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 232, '23.11.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 88, '20.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 57, '07.09.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 249, '04.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (76, 142, '09.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 149, '30.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 158, '27.06.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 182, '15.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 70, '10.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 16, '01.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 24, '08.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 89, '22.09.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 162, '22.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 178, '08.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 147, '13.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (58, 68, '16.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (10, 130, '04.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 9, '25.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 197, '29.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 112, '18.08.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 25, '27.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 226, '12.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 130, '30.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 161, '19.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 161, '05.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 198, '30.08.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 97, '26.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 170, '29.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 194, '02.08.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 146, '26.02.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 184, '28.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 124, '05.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 234, '07.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 58, '03.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (8, 70, '30.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 239, '20.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 22, '29.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 247, '09.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 14, '01.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 7, '14.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 37, '12.02.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 222, '27.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 223, '16.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (58, 174, '24.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 209, '29.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 17, '28.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (24, 247, '13.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 201, '18.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 70, '07.04.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 46, '13.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 38, '26.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 184, '03.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 153, '08.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 225, '11.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 151, '21.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 227, '11.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 93, '20.03.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 190, '26.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 70, '07.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 19, '03.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 25, '08.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 170, '27.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 75, '14.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 16, '04.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 222, '13.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (24, 104, '29.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 190, '18.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 108, '06.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 182, '10.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 204, '22.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 182, '02.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 244, '01.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 24, '09.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 233, '06.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 58, '15.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 196, '08.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 46, '13.03.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 176, '13.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 41, '10.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 159, '29.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (24, 96, '13.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (13, 78, '22.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 121, '11.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (82, 241, '20.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 12, '23.04.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 138, '24.03.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 164, '08.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 145, '01.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 144, '03.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (82, 220, '29.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 151, '29.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 111, '01.04.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 120, '10.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (13, 130, '24.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 239, '02.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 101, '30.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 192, '29.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 40, '22.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 201, '05.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 190, '24.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 15, '24.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 47, '20.09.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 143, '09.05.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 160, '03.04.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 215, '13.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 227, '22.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (58, 26, '09.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 227, '07.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 123, '23.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 47, '06.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 12, '20.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 15, '17.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 30, '29.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 9, '24.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 148, '19.02.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 159, '11.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 169, '23.07.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 9, '22.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 18, '08.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 137, '31.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 247, '01.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 173, '11.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 152, '07.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 240, '01.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 114, '08.02.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 206, '17.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 123, '12.11.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 151, '04.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (39, 61, '05.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 120, '11.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 238, '10.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 113, '24.10.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 19, '08.12.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 231, '26.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 74, '17.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 128, '28.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 126, '24.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 17, '18.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (83, 149, '10.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 52, '26.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 80, '30.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 216, '22.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (24, 2, '15.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 183, '09.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 53, '05.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 78, '15.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 16, '24.03.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 167, '22.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (13, 50, '07.02.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 47, '18.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 36, '02.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 93, '22.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 79, '25.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 218, '16.09.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 59, '08.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 89, '01.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 138, '19.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (76, 41, '14.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 231, '10.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 76, '01.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 245, '25.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 111, '20.03.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 59, '10.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 3, '04.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 183, '26.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 142, '08.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 104, '16.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 221, '24.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 68, '13.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (79, 44, '23.07.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 48, '30.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 134, '20.08.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 198, '03.06.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 155, '11.09.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 21, '16.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 250, '19.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 161, '11.02.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 83, '11.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 213, '21.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 57, '07.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 39, '26.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 48, '02.02.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 52, '19.02.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 92, '24.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 197, '11.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 214, '29.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 248, '03.06.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 202, '02.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 126, '03.09.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 79, '15.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 135, '25.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 66, '10.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 68, '03.07.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 16, '09.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 184, '06.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 150, '09.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 82, '20.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 54, '05.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 234, '19.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 132, '20.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 44, '12.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 63, '07.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 191, '17.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 40, '05.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 248, '18.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 71, '12.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 121, '02.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 168, '28.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 177, '13.06.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 94, '23.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 185, '04.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 249, '18.12.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 237, '11.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 8, '13.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 132, '15.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 226, '03.12.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 234, '17.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 160, '27.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 170, '22.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 59, '20.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 72, '06.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (76, 142, '03.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 132, '16.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 11, '19.11.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 45, '03.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 24, '22.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 95, '31.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 84, '11.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 161, '03.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 238, '12.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (69, 64, '29.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 35, '26.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 2, '16.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 83, '08.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 111, '26.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 178, '05.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 123, '30.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 140, '25.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 213, '16.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 217, '02.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 121, '15.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 221, '03.08.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 133, '25.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 247, '15.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 229, '24.08.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 137, '15.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 161, '03.11.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 183, '26.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 130, '28.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 29, '28.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 46, '09.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 130, '28.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 145, '21.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 179, '13.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 10, '12.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 249, '17.11.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 199, '11.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 222, '20.04.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 68, '09.08.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (72, 26, '28.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 29, '07.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 38, '24.11.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 76, '30.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 158, '29.04.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 131, '29.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 218, '21.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 163, '11.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 78, '31.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 136, '30.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 109, '09.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 139, '26.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 211, '28.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 61, '12.11.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 142, '06.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 63, '15.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 141, '15.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 48, '27.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 245, '17.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (79, 23, '14.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 221, '21.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 44, '26.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (10, 32, '28.12.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (36, 118, '14.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 11, '13.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 209, '26.11.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 59, '18.02.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 216, '04.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 22, '23.02.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 149, '15.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (65, 195, '15.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 93, '09.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 22, '15.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 195, '25.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 148, '13.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 104, '04.05.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 143, '27.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 87, '01.08.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 125, '25.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 133, '28.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 166, '23.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 163, '11.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 187, '18.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 215, '07.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 198, '13.11.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 16, '22.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 130, '24.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 196, '21.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 120, '25.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 155, '30.09.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 169, '02.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 9, '30.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 14, '25.01.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 129, '03.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 229, '24.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 181, '10.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 123, '24.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 145, '15.11.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 242, '26.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 175, '23.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 66, '23.09.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 38, '08.02.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 65, '02.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 200, '29.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 75, '02.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (94, 111, '13.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (20, 227, '29.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 177, '16.04.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 160, '21.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 7, '22.08.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 136, '16.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 46, '15.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (64, 142, '17.11.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 171, '09.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 122, '10.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 127, '05.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 238, '18.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 15, '07.06.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 177, '14.08.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 160, '02.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 112, '24.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 105, '03.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (58, 46, '07.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 152, '28.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 134, '15.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 16, '22.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 129, '13.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 243, '04.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 113, '07.02.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (8, 62, '12.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 241, '21.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 115, '11.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 63, '21.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 115, '15.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 122, '05.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 128, '18.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 7, '16.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 225, '24.08.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 69, '12.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 26, '13.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (95, 40, '03.05.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 162, '02.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 231, '04.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 224, '24.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 114, '17.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 87, '02.08.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 129, '05.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 63, '30.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 201, '28.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (62, 10, '17.04.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 187, '02.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 59, '29.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (63, 91, '09.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (98, 2, '07.09.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 46, '04.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 31, '02.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (59, 33, '18.05.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 250, '16.11.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 138, '04.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 52, '07.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 55, '03.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 26, '02.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 198, '03.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 143, '02.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 175, '19.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 225, '03.11.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (69, 38, '24.09.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 161, '31.03.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 208, '04.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (43, 159, '05.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 150, '30.10.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 105, '06.12.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (3, 191, '31.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (4, 123, '07.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 141, '03.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 240, '24.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (86, 127, '18.12.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (20, 77, '27.11.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 66, '29.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 17, '21.08.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 182, '02.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (93, 91, '16.07.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 171, '09.07.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (73, 201, '22.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (27, 81, '04.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 144, '03.12.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 203, '29.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 176, '30.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 19, '28.11.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 148, '27.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 61, '25.08.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 237, '09.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 13, '22.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (51, 212, '14.06.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 74, '14.02.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 7, '08.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 165, '09.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 171, '22.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 74, '24.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 30, '06.08.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (48, 66, '06.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 19, '17.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 231, '23.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 58, '14.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 139, '07.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 82, '29.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 137, '04.12.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 58, '29.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 12, '28.08.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 106, '17.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (97, 100, '26.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (5, 106, '29.12.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (49, 220, '26.01.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (50, 213, '19.11.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 132, '28.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 108, '29.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 29, '30.12.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (63, 70, '16.11.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (41, 71, '15.03.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (66, 188, '12.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 250, '12.12.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 110, '26.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 222, '23.08.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 102, '08.10.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 23, '28.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (96, 200, '26.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 123, '14.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 60, '13.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 160, '25.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (68, 80, '08.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 156, '17.04.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 157, '02.10.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 158, '20.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 218, '09.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 171, '09.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 183, '03.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (82, 102, '04.07.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (80, 33, '04.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 83, '23.07.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 60, '22.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 153, '18.02.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 53, '24.09.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (92, 88, '21.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (53, 118, '16.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (63, 11, '17.03.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 248, '24.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 242, '04.01.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (74, 208, '30.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (20, 87, '22.04.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 4, '21.01.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (25, 11, '14.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 86, '14.09.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (24, 207, '03.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 132, '30.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (16, 246, '27.06.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (89, 77, '19.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (70, 206, '04.04.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (15, 154, '22.03.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (1, 73, '15.10.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 51, '09.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (45, 173, '08.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (30, 44, '16.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 5, '28.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (14, 4, '04.02.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (99, 178, '04.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (87, 67, '11.03.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (22, 32, '08.01.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (38, 246, '11.06.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (10, 108, '07.07.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (58, 199, '10.12.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 179, '03.11.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 165, '03.12.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 208, '11.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 190, '30.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (56, 96, '12.01.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (42, 182, '11.03.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 200, '01.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 129, '21.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 250, '21.10.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 96, '13.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (19, 47, '12.08.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 50, '21.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (81, 94, '15.11.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (57, 226, '06.10.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (31, 25, '24.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 72, '30.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (39, 65, '11.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (85, 138, '07.05.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 105, '22.02.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 210, '17.08.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (11, 124, '19.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 16, '05.02.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (29, 37, '25.09.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (79, 94, '12.07.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 161, '21.06.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (44, 13, '28.01.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (32, 6, '21.04.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (34, 72, '07.11.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (63, 12, '29.06.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (20, 107, '11.08.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (47, 145, '07.07.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (18, 13, '22.10.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (46, 33, '07.10.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (91, 202, '01.03.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (83, 93, '31.01.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (35, 243, '21.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 150, '30.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (76, 196, '07.06.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (60, 210, '14.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 186, '11.07.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (54, 15, '11.05.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (77, 31, '22.11.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (78, 120, '15.04.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (84, 176, '05.03.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (6, 234, '17.10.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 202, '08.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 60, '15.04.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (21, 244, '29.12.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (33, 163, '10.06.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (17, 211, '25.09.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (69, 135, '04.05.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (90, 63, '15.04.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (71, 87, '14.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (7, 200, '24.06.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (23, 208, '23.05.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (28, 9, '18.12.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (83, 58, '13.09.2021', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (55, 158, '03.01.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (52, 169, '30.08.2020', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (40, 150, '30.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (75, 249, '15.10.2020', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (61, 229, '05.10.2020', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (9, 227, '28.07.2021', 1);
insert into book_user_rating (id_book, id_user, time, rate) values (67, 13, '26.05.2021', 5);
insert into book_user_rating (id_book, id_user, time, rate) values (39, 197, '19.01.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (37, 127, '14.07.2020', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (26, 17, '26.05.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (12, 40, '25.09.2020', 4);
insert into book_user_rating (id_book, id_user, time, rate) values (2, 145, '16.04.2021', 2);
insert into book_user_rating (id_book, id_user, time, rate) values (88, 106, '08.04.2021', 3);
insert into book_user_rating (id_book, id_user, time, rate) values (100, 64, '26.08.2021', 5);

insert into book_review (id_user, id_book, time, text) values (196, 51, '12.05.2021', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (57, 47, '07.11.2020', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (234, 43, '17.01.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (29, 65, '29.02.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (124, 48, '03.12.2020', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (7, 11, '22.11.2021', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (60, 20, '13.06.2021', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (83, 47, '16.03.2021', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (143, 21, '21.02.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (12, 56, '26.05.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (209, 25, '02.09.2021', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (9, 17, '28.10.2020', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (76, 25, '29.03.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (7, 66, '23.05.2021', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (80, 32, '22.03.2021', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into book_review (id_user, id_book, time, text) values (171, 23, '06.12.2021', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (101, 45, '03.12.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (214, 18, '26.05.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (90, 18, '22.08.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (191, 37, '07.01.2020', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (246, 16, '18.05.2021', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (203, 39, '25.10.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (21, 12, '25.11.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (51, 18, '23.08.2021', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (8, 36, '10.07.2020', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (166, 18, '10.02.2021', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (79, 23, '12.07.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (26, 8, '11.02.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (169, 31, '07.02.2021', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (39, 51, '20.10.2021', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (66, 37, '19.08.2020', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (208, 24, '03.05.2021', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (78, 44, '25.06.2021', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (152, 26, '20.12.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (173, 51, '12.02.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (59, 23, '19.02.2020', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (43, 22, '24.03.2021', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (216, 19, '02.01.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (159, 20, '30.04.2021', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (42, 67, '26.06.2021', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (174, 18, '21.03.2021', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (91, 52, '04.01.2021', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (135, 53, '16.09.2021', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (11, 62, '22.05.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (88, 28, '26.02.2020', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (47, 11, '29.08.2020', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (40, 35, '14.05.2021', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.

Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into book_review (id_user, id_book, time, text) values (244, 9, '29.09.2021', 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (48, 5, '01.02.2021', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (58, 7, '29.03.2021', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (92, 59, '07.08.2021', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (25, 16, '17.01.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (199, 1, '18.12.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (209, 48, '02.01.2020', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (90, 27, '30.07.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (223, 8, '06.09.2020', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (93, 20, '01.09.2021', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (167, 36, '03.01.2020', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (160, 14, '12.11.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (221, 4, '06.05.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (126, 33, '05.10.2021', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (154, 7, '18.06.2021', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (71, 47, '26.12.2020', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (91, 3, '25.06.2020', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (159, 17, '01.08.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (201, 20, '23.10.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (198, 67, '29.11.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (49, 63, '18.08.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (162, 42, '24.03.2020', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (138, 58, '29.01.2020', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (95, 9, '01.05.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (210, 15, '07.05.2020', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (33, 8, '14.06.2020', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (226, 40, '15.06.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (166, 28, '07.04.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (152, 45, '12.12.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (4, 39, '10.02.2021', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (184, 44, '27.08.2021', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (34, 16, '31.05.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (246, 19, '28.11.2021', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (96, 19, '14.02.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (201, 31, '26.08.2021', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (84, 50, '26.08.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (93, 59, '02.11.2020', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (101, 56, '13.11.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (247, 37, '18.10.2020', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (184, 40, '04.09.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (57, 10, '24.07.2020', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (100, 11, '03.10.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (36, 18, '22.01.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (9, 4, '29.04.2021', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (43, 51, '10.08.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (207, 53, '11.09.2020', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (162, 35, '08.11.2021', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (192, 37, '21.05.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (142, 43, '15.11.2020', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (189, 21, '24.12.2021', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (74, 19, '04.01.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (234, 19, '10.10.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (6, 44, '13.09.2021', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (98, 33, '10.03.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (131, 53, '31.05.2020', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (164, 48, '13.08.2021', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (135, 14, '11.05.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (77, 10, '25.12.2021', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (240, 11, '22.04.2020', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (245, 18, '18.07.2020', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (193, 4, '07.04.2021', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (85, 65, '20.01.2020', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (178, 56, '15.04.2021', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (34, 31, '20.12.2021', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (219, 7, '23.04.2021', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (239, 24, '28.10.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (10, 38, '25.07.2020', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (190, 66, '09.08.2021', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (205, 55, '10.05.2021', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (54, 12, '19.06.2020', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into book_review (id_user, id_book, time, text) values (33, 3, '07.12.2021', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (141, 17, '07.11.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (238, 4, '05.09.2021', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (31, 30, '21.12.2020', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (153, 36, '07.01.2020', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (192, 44, '20.03.2021', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (144, 5, '09.04.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (231, 2, '27.10.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (171, 3, '03.05.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (50, 3, '15.11.2020', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (206, 66, '03.04.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (123, 44, '28.11.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into book_review (id_user, id_book, time, text) values (122, 60, '14.02.2021', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (61, 22, '07.07.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (111, 30, '20.12.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (44, 37, '15.01.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (72, 4, '15.12.2020', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (106, 10, '11.04.2021', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (86, 37, '04.10.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (50, 48, '17.07.2020', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (76, 42, '11.02.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (193, 15, '15.01.2020', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (208, 26, '04.12.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (247, 48, '27.11.2021', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (105, 30, '03.12.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (28, 63, '05.06.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (227, 26, '25.06.2020', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (120, 30, '26.01.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (223, 6, '21.12.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (40, 24, '02.10.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (82, 20, '16.11.2021', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (31, 54, '16.04.2020', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (235, 52, '26.08.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (68, 64, '01.02.2021', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (235, 35, '01.04.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (138, 51, '17.01.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (196, 56, '18.02.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (237, 1, '02.06.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (181, 10, '07.01.2021', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (227, 17, '23.08.2021', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (32, 55, '08.07.2020', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (209, 55, '19.10.2020', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (43, 29, '01.08.2021', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (32, 21, '27.11.2021', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (66, 31, '17.07.2021', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (169, 49, '10.12.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (116, 53, '18.09.2021', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (29, 23, '22.06.2020', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (206, 54, '27.06.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (69, 51, '28.08.2020', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (170, 43, '02.09.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (198, 51, '19.06.2021', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (115, 52, '06.05.2021', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (250, 6, '29.09.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (76, 66, '12.08.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (17, 13, '11.05.2020', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (91, 16, '26.10.2020', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (65, 52, '08.04.2021', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (28, 60, '10.10.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (127, 46, '16.12.2021', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (219, 53, '10.03.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (80, 31, '17.02.2021', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (185, 10, '27.11.2020', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (160, 45, '07.12.2021', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into book_review (id_user, id_book, time, text) values (216, 49, '07.03.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (184, 28, '01.10.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (124, 54, '18.10.2021', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (44, 47, '23.11.2020', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (43, 41, '29.03.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (115, 6, '28.10.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (19, 31, '14.05.2020', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (84, 11, '05.08.2021', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (91, 5, '08.03.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (150, 16, '04.06.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (136, 44, '04.05.2020', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (12, 16, '21.04.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (223, 46, '27.07.2020', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (32, 24, '18.05.2020', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (19, 23, '11.01.2020', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (67, 24, '06.12.2020', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (230, 8, '21.06.2020', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (50, 18, '12.12.2021', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (75, 38, '20.12.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (249, 36, '07.10.2020', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (247, 48, '10.05.2020', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (82, 35, '25.03.2021', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (43, 65, '10.05.2021', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (227, 15, '07.05.2020', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (26, 22, '28.03.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (35, 27, '20.11.2021', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (39, 14, '24.11.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (164, 29, '13.10.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (89, 19, '18.07.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (69, 61, '09.05.2021', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (110, 32, '21.11.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (37, 35, '17.07.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (36, 46, '11.09.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (157, 11, '14.07.2021', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into book_review (id_user, id_book, time, text) values (179, 16, '10.10.2021', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (39, 47, '20.09.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into book_review (id_user, id_book, time, text) values (114, 14, '13.08.2021', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into book_review (id_user, id_book, time, text) values (188, 60, '16.02.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into book_review (id_user, id_book, time, text) values (27, 5, '30.07.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (63, 47, '15.02.2020', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (13, 67, '05.04.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (109, 3, '07.08.2020', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (104, 55, '04.03.2020', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (50, 25, '19.04.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (71, 38, '19.05.2020', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (194, 32, '21.04.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (185, 65, '15.05.2020', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (128, 15, '22.10.2021', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (137, 36, '02.04.2021', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (19, 26, '23.06.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (148, 63, '17.03.2021', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (77, 37, '30.11.2020', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (70, 35, '24.02.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (70, 57, '24.12.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (229, 20, '13.02.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (225, 33, '21.11.2021', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (74, 4, '11.03.2021', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (85, 47, '01.08.2021', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (229, 22, '18.05.2021', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (17, 44, '31.03.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (197, 63, '04.11.2021', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (27, 43, '09.03.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (242, 28, '14.10.2021', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (158, 13, '27.09.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (11, 67, '19.04.2020', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (111, 9, '16.09.2021', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (154, 40, '20.11.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (243, 4, '27.06.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (177, 36, '08.12.2021', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (46, 38, '01.05.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (175, 41, '22.03.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (186, 66, '22.07.2021', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (82, 32, '26.07.2020', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (186, 39, '09.09.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (243, 49, '11.08.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (107, 19, '25.10.2020', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (160, 41, '17.04.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (208, 56, '12.08.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (10, 13, '25.07.2021', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (69, 16, '27.03.2020', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (35, 67, '05.12.2021', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (117, 15, '19.09.2020', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (91, 59, '28.09.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (12, 47, '27.11.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (80, 1, '21.10.2020', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (203, 6, '16.02.2021', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (101, 57, '15.09.2021', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (41, 4, '04.02.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (214, 7, '29.03.2021', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (18, 34, '10.05.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (188, 41, '28.04.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (212, 39, '04.02.2020', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (197, 41, '09.12.2021', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (212, 35, '22.08.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.

Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (80, 40, '10.01.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (2, 44, '23.02.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (207, 1, '20.10.2020', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (184, 61, '19.10.2021', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (72, 34, '16.01.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (162, 54, '14.05.2021', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (62, 4, '15.03.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (49, 35, '13.02.2020', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (210, 5, '27.07.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (53, 16, '16.10.2021', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (232, 30, '25.03.2020', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (219, 14, '08.10.2020', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.

Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (52, 5, '26.04.2020', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (48, 29, '12.10.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (242, 25, '13.09.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (97, 48, '22.09.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (163, 63, '29.11.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (145, 54, '18.07.2020', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (69, 37, '01.01.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (156, 18, '22.08.2021', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (110, 47, '27.10.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (240, 46, '19.05.2020', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (203, 53, '20.07.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (6, 44, '07.06.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (195, 8, '30.03.2021', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (50, 48, '08.06.2020', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (205, 67, '07.02.2021', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (55, 47, '25.02.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (100, 29, '09.06.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (152, 14, '16.08.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.

Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (37, 53, '12.08.2020', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (224, 29, '15.03.2021', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into book_review (id_user, id_book, time, text) values (222, 25, '05.02.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (77, 2, '02.04.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (230, 37, '29.11.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (33, 2, '04.05.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (34, 18, '12.01.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (87, 42, '25.02.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.

Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (160, 43, '13.04.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (68, 3, '19.10.2021', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (211, 2, '13.07.2020', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (181, 11, '05.02.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (69, 62, '22.09.2020', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (104, 63, '21.07.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (67, 40, '15.09.2021', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (119, 57, '23.07.2021', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (247, 61, '02.01.2020', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (223, 62, '01.05.2020', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (168, 49, '17.06.2021', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (54, 28, '18.11.2021', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (124, 2, '31.05.2020', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (94, 45, '05.10.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (30, 16, '20.08.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (60, 25, '01.09.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (107, 38, '06.03.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (155, 15, '21.10.2020', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (219, 43, '13.06.2021', 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (10, 62, '23.11.2020', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (150, 15, '30.08.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (246, 11, '25.12.2020', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (102, 54, '09.04.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (139, 65, '22.02.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (123, 3, '07.05.2020', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (157, 52, '22.11.2021', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (223, 28, '12.12.2021', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (206, 27, '12.03.2021', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (26, 53, '14.05.2021', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (140, 43, '10.02.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (80, 9, '23.09.2020', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (128, 42, '20.11.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (102, 18, '27.03.2020', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (249, 29, '24.01.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (167, 5, '22.11.2021', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (6, 6, '12.02.2021', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (199, 46, '21.08.2020', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (25, 51, '19.05.2021', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (124, 32, '05.03.2020', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (5, 48, '28.08.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into book_review (id_user, id_book, time, text) values (68, 62, '21.12.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into book_review (id_user, id_book, time, text) values (111, 2, '30.10.2021', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.

Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (4, 6, '23.08.2020', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.

Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into book_review (id_user, id_book, time, text) values (245, 6, '21.04.2020', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (153, 12, '30.10.2021', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (163, 11, '29.01.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (139, 58, '17.07.2020', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (61, 35, '23.12.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (137, 61, '08.10.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (238, 41, '27.05.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (137, 66, '03.08.2020', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (72, 40, '14.07.2020', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (151, 14, '27.03.2021', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (69, 9, '07.09.2021', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into book_review (id_user, id_book, time, text) values (241, 37, '29.05.2020', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (24, 36, '02.03.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (50, 3, '23.11.2021', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (66, 2, '06.11.2020', 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (235, 32, '14.05.2021', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (169, 47, '31.08.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (145, 22, '12.09.2020', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.

Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (193, 21, '17.05.2020', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into book_review (id_user, id_book, time, text) values (180, 58, '15.03.2020', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (129, 21, '22.06.2021', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (149, 1, '05.08.2021', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (33, 25, '07.12.2020', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (154, 25, '05.04.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (7, 4, '01.11.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (96, 24, '21.11.2020', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (41, 13, '03.09.2021', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (70, 23, '18.01.2021', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.

Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into book_review (id_user, id_book, time, text) values (104, 21, '11.01.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (209, 62, '28.05.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (18, 23, '05.07.2020', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (50, 12, '10.01.2021', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (29, 23, '05.03.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (147, 57, '19.08.2021', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (91, 38, '08.09.2020', 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (161, 44, '25.02.2021', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (138, 60, '02.10.2021', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (179, 40, '25.03.2020', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (101, 44, '06.04.2020', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.

Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (61, 58, '13.03.2020', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (129, 34, '03.06.2021', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (223, 31, '27.03.2020', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into book_review (id_user, id_book, time, text) values (69, 42, '07.10.2021', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (160, 20, '28.08.2021', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.

Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into book_review (id_user, id_book, time, text) values (150, 15, '09.07.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (241, 63, '15.11.2021', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (110, 62, '24.11.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (153, 1, '15.03.2021', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into book_review (id_user, id_book, time, text) values (4, 65, '23.07.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (124, 14, '18.04.2021', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (37, 39, '24.11.2021', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (65, 50, '15.02.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into book_review (id_user, id_book, time, text) values (29, 20, '07.10.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (160, 21, '07.08.2021', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (80, 5, '15.09.2020', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (197, 22, '18.11.2021', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (46, 7, '18.02.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (98, 64, '14.02.2020', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.

Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into book_review (id_user, id_book, time, text) values (21, 57, '25.05.2021', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into book_review (id_user, id_book, time, text) values (67, 10, '22.10.2021', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (152, 53, '20.04.2021', 'Fusce consequat. Nulla nisl. Nunc nisl.

Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into book_review (id_user, id_book, time, text) values (16, 1, '13.10.2021', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (64, 5, '03.03.2021', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (105, 13, '17.04.2020', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (132, 31, '30.04.2021', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into book_review (id_user, id_book, time, text) values (54, 53, '01.10.2020', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (52, 58, '13.06.2020', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (72, 53, '18.12.2021', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (110, 2, '25.06.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (243, 57, '12.12.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (71, 2, '23.07.2020', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.

Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (139, 42, '12.08.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.

Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (55, 34, '31.05.2021', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (186, 6, '31.03.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into book_review (id_user, id_book, time, text) values (140, 42, '13.08.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (229, 46, '05.11.2020', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (30, 48, '15.01.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (95, 59, '08.05.2021', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.

Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into book_review (id_user, id_book, time, text) values (198, 41, '20.12.2020', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (29, 66, '17.07.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (90, 16, '07.12.2021', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.

Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (130, 58, '09.05.2020', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.

Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.

Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into book_review (id_user, id_book, time, text) values (102, 14, '22.12.2021', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (50, 67, '13.03.2020', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (93, 7, '10.06.2020', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.

Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into book_review (id_user, id_book, time, text) values (108, 51, '02.04.2021', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (147, 44, '01.12.2020', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into book_review (id_user, id_book, time, text) values (3, 59, '27.08.2020', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.

Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into book_review (id_user, id_book, time, text) values (15, 27, '10.08.2021', 'In congue. Etiam justo. Etiam pretium iaculis justo.

In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (104, 49, '09.11.2020', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (234, 34, '01.05.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (232, 67, '03.11.2021', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.

Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (84, 47, '11.03.2021', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (28, 33, '12.08.2020', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (198, 21, '15.10.2020', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.

In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into book_review (id_user, id_book, time, text) values (76, 26, '10.10.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (171, 62, '22.01.2020', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.

In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (43, 57, '10.03.2020', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.

Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.

In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (179, 52, '02.05.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (144, 9, '06.10.2021', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.

Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into book_review (id_user, id_book, time, text) values (110, 31, '19.10.2021', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (216, 14, '03.03.2021', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into book_review (id_user, id_book, time, text) values (104, 61, '06.10.2020', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into book_review (id_user, id_book, time, text) values (99, 49, '15.09.2020', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.

Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into book_review (id_user, id_book, time, text) values (188, 41, '23.03.2020', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (171, 53, '26.07.2021', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (244, 39, '09.07.2020', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into book_review (id_user, id_book, time, text) values (217, 25, '09.06.2020', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into book_review (id_user, id_book, time, text) values (164, 26, '22.02.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (49, 35, '07.10.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.

Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into book_review (id_user, id_book, time, text) values (40, 26, '23.09.2021', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (72, 66, '22.10.2021', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (2, 8, '21.05.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.

Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into book_review (id_user, id_book, time, text) values (111, 5, '13.08.2021', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (142, 67, '10.07.2021', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into book_review (id_user, id_book, time, text) values (108, 31, '20.09.2020', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into book_review (id_user, id_book, time, text) values (121, 9, '02.02.2020', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.

In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.

Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into book_review (id_user, id_book, time, text) values (204, 33, '06.06.2020', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (203, 35, '23.01.2020', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.

Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (121, 19, '11.01.2020', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.

Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.

Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into book_review (id_user, id_book, time, text) values (62, 67, '27.04.2021', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into book_review (id_user, id_book, time, text) values (211, 9, '19.12.2020', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into book_review (id_user, id_book, time, text) values (59, 15, '31.03.2021', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (108, 46, '30.09.2021', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (105, 31, '23.02.2020', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.

Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into book_review (id_user, id_book, time, text) values (15, 57, '29.01.2021', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.

Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
insert into book_review (id_user, id_book, time, text) values (248, 52, '08.04.2020', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (189, 43, '05.05.2020', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.

Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into book_review (id_user, id_book, time, text) values (18, 43, '15.10.2020', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.

Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (35, 53, '24.07.2021', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into book_review (id_user, id_book, time, text) values (201, 1, '16.07.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (137, 29, '30.03.2021', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.

Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into book_review (id_user, id_book, time, text) values (49, 46, '13.08.2020', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.

Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into book_review (id_user, id_book, time, text) values (6, 9, '10.12.2020', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.

Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.

Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into book_review (id_user, id_book, time, text) values (54, 10, '11.02.2020', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into book_review (id_user, id_book, time, text) values (149, 56, '27.03.2020', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into book_review (id_user, id_book, time, text) values (82, 5, '16.03.2020', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.

Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into book_review (id_user, id_book, time, text) values (203, 55, '22.06.2020', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.

Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into book_review (id_user, id_book, time, text) values (110, 54, '13.04.2020', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into book_review (id_user, id_book, time, text) values (247, 39, '08.06.2021', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.

Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.

Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into book_review (id_user, id_book, time, text) values (197, 51, '26.03.2021', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.

Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into book_review (id_user, id_book, time, text) values (38, 61, '27.10.2021', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.

Fusce consequat. Nulla nisl. Nunc nisl.');
insert into book_review (id_user, id_book, time, text) values (237, 31, '23.09.2020', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into book_review (id_user, id_book, time, text) values (161, 53, '25.12.2021', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.

Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');


-- Сайт для генерации случайных данных https://www.mockaroo.com/

--,'09.01.2021', true, 657.0, 22,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', true, 203.08, 1,'','/assets/img/content/main/card.jpg','');
--,'02.05.2021', true, 549.75, 23,'','/assets/img/content/main/card.jpg','');
--,'07.02.2021', true, 468.37, 22,'','/assets/img/content/main/card.jpg','');
--,'28.09.2021', false, 793.93, 46,'','/assets/img/content/main/card.jpg','');
--,'30.05.2021', false, 242.73, 30,'','/assets/img/content/main/card.jpg','');
--,'25.06.2021', false, 516.63, 18,'','/assets/img/content/main/card.jpg','');
--,'21.07.2021', true, 920.75, 11,'','/assets/img/content/main/card.jpg','');
--,'02.05.2021', false, 971.26, 50,'','/assets/img/content/main/card.jpg','');
--,'29.03.2021', true, 583.34, 20,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', true, 461.19, 31,'','/assets/img/content/main/card.jpg','');
--,'28.12.2021', true, 862.76, 19,'','/assets/img/content/main/card.jpg','');
--,'29.12.2021', true, 920.47, 2,'','/assets/img/content/main/card.jpg','');
--,'13.08.2021', true, 232.58, 23,'','/assets/img/content/main/card.jpg','');
--,'01.02.2021', false, 706.67, 34,'','/assets/img/content/main/card.jpg','');
--,'07.10.2021', true, 403.67, 50,'','/assets/img/content/main/card.jpg','');
--,'17.02.2021', true, 756.72, 4,'','/assets/img/content/main/card.jpg','');
--,'13.09.2021', true, 644.8, 6,'','/assets/img/content/main/card.jpg','');
--,'01.01.2021', false, 674.2, 45,'','/assets/img/content/main/card.jpg','');
--,'11.04.2021', true, 573.88, 24,'','/assets/img/content/main/card.jpg','');
--,'26.12.2021', false, 257.21, 16,'','/assets/img/content/main/card.jpg','');
--,'16.02.2021', false, 732.01, 47,'','/assets/img/content/main/card.jpg','');
--,'01.07.2021', true, 715.56, 13,'','/assets/img/content/main/card.jpg','');
--,'02.04.2021', true, 371.46, 24,'','/assets/img/content/main/card.jpg','');
--,'21.07.2021', true, 768.55, 33,'','/assets/img/content/main/card.jpg','');
--,'31.01.2021', false, 297.68, 46,'','/assets/img/content/main/card.jpg','');
--,'10.04.2021', true, 463.42, 17,'','/assets/img/content/main/card.jpg','');
--,'06.08.2021', true, 726.45, 14,'','/assets/img/content/main/card.jpg','');
--,'02.08.2021', false, 479.87, 22,'','/assets/img/content/main/card.jpg','');
--,'18.08.2021', false, 982.52, 32,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', true, 612.86, 10,'','/assets/img/content/main/card.jpg','');
--,'13.12.2021', false, 644.95, 4,'','/assets/img/content/main/card.jpg','');
--,'17.10.2021', true, 904.87, 17,'','/assets/img/content/main/card.jpg','');
--,'01.10.2021', false, 622.12, 21,'','/assets/img/content/main/card.jpg','');
--,'17.11.2021', false, 773.23, 18,'','/assets/img/content/main/card.jpg','');
--,'01.11.2021', true, 751.69, 16,'','/assets/img/content/main/card.jpg','');
--,'11.03.2021', false, 231.19, 5,'','/assets/img/content/main/card.jpg','');
--,'22.07.2021', false, 579.61, 28,'','/assets/img/content/main/card.jpg','');
--,'31.01.2021', false, 277.6, 13,'','/assets/img/content/main/card.jpg','');
--,'22.04.2021', false, 202.74, 29,'','/assets/img/content/main/card.jpg','');
--,'25.10.2021', true, 345.11, 44,'','/assets/img/content/main/card.jpg','');
--,'03.06.2021', true, 968.17, 6,'','/assets/img/content/main/card.jpg','');
--,'04.04.2021', false, 448.92, 47,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 303.07, 4,'','/assets/img/content/main/card.jpg','');
--,'29.07.2021', false, 839.41, 26,'','/assets/img/content/main/card.jpg','');
--,'08.12.2021', true, 672.34, 9,'','/assets/img/content/main/card.jpg','');
--,'19.02.2021', false, 269.65, 1,'','/assets/img/content/main/card.jpg','');
--,'29.03.2021', true, 527.8, 23,'','/assets/img/content/main/card.jpg','');
--,'01.12.2021', false, 456.12, 23,'','/assets/img/content/main/card.jpg','');
--,'23.04.2021', true, 293.08, 12,'','/assets/img/content/main/card.jpg','');
--,'04.09.2021', true, 742.86, 18,'','/assets/img/content/main/card.jpg','');
--,'17.01.2021', true, 831.83, 47,'','/assets/img/content/main/card.jpg','');
--,'23.02.2021', false, 906.54, 17,'','/assets/img/content/main/card.jpg','');
--,'04.12.2021', true, 832.36, 18,'','/assets/img/content/main/card.jpg','');
--,'17.04.2021', true, 813.95, 15,'','/assets/img/content/main/card.jpg','');
--,'09.05.2021', true, 249.92, 17,'','/assets/img/content/main/card.jpg','');
--,'18.04.2021', true, 931.15, 22,'','/assets/img/content/main/card.jpg','');
--,'21.05.2021', false, 664.28, 9,'','/assets/img/content/main/card.jpg','');
--,'18.11.2021', true, 586.35, 5,'','/assets/img/content/main/card.jpg','');
--,'11.01.2021', false, 461.52, 43,'','/assets/img/content/main/card.jpg','');
--,'23.02.2021', false, 834.03, 19,'','/assets/img/content/main/card.jpg','');
--,'18.03.2021', false, 588.1, 1,'','/assets/img/content/main/card.jpg','');
--,'09.09.2021', false, 989.26, 6,'','/assets/img/content/main/card.jpg','');
--,'18.05.2021', false, 848.45, 31,'','/assets/img/content/main/card.jpg','');
--,'29.06.2021', true, 330.57, 11,'','/assets/img/content/main/card.jpg','');
--,'20.06.2021', false, 809.85, 28,'','/assets/img/content/main/card.jpg','');
--,'04.05.2021', false, 624.81, 19,'','/assets/img/content/main/card.jpg','');
--,'23.04.2021', false, 521.81, 50,'','/assets/img/content/main/card.jpg','');
--,'01.06.2021', false, 860.15, 16,'','/assets/img/content/main/card.jpg','');
--,'12.06.2021', true, 618.52, 5,'','/assets/img/content/main/card.jpg','');
--,'02.02.2021', true, 983.04, 22,'','/assets/img/content/main/card.jpg','');
--,'27.02.2021', true, 471.84, 40,'','/assets/img/content/main/card.jpg','');
--,'31.03.2021', false, 416.64, 11,'','/assets/img/content/main/card.jpg','');
--,'25.05.2021', false, 703.39, 21,'','/assets/img/content/main/card.jpg','');
--,'28.10.2021', false, 759.12, 16,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', false, 574.23, 49,'','/assets/img/content/main/card.jpg','');
--,'11.06.2021', true, 388.8, 9,'','/assets/img/content/main/card.jpg','');
--,'17.08.2021', true, 392.75, 35,'','/assets/img/content/main/card.jpg','');
--,'03.10.2021', false, 828.42, 9,'','/assets/img/content/main/card.jpg','');
--,'15.12.2021', false, 971.33, 45,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 496.27, 8,'','/assets/img/content/main/card.jpg','');
--,'04.12.2021', true, 806.56, 19,'','/assets/img/content/main/card.jpg','');
--,'20.12.2021', false, 833.93, 25,'','/assets/img/content/main/card.jpg','');
--,'05.07.2021', false, 571.65, 37,'','/assets/img/content/main/card.jpg','');
--,'24.05.2021', true, 687.77, 22,'','/assets/img/content/main/card.jpg','');
--,'18.05.2021', true, 767.92, 43,'','/assets/img/content/main/card.jpg','');
--,'17.03.2021', false, 425.01, 47,'','/assets/img/content/main/card.jpg','');
--,'16.12.2021', true, 664.12, 35,'','/assets/img/content/main/card.jpg','');
--,'09.04.2021', false, 631.4, 45,'','/assets/img/content/main/card.jpg','');
--,'19.12.2021', true, 518.02, 21,'','/assets/img/content/main/card.jpg','');
--,'01.11.2021', true, 274.18, 3,'','/assets/img/content/main/card.jpg','');
--,'21.08.2021', true, 331.21, 49,'','/assets/img/content/main/card.jpg','');
--,'16.03.2021', true, 251.22, 26,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', false, 451.46, 46,'','/assets/img/content/main/card.jpg','');
--,'12.08.2021', true, 860.05, 17,'','/assets/img/content/main/card.jpg','');
--,'20.10.2021', true, 320.14, 42,'','/assets/img/content/main/card.jpg','');
--,'01.10.2021', true, 633.24, 43,'','/assets/img/content/main/card.jpg','');
--,'21.11.2021', true, 301.45, 3,'','/assets/img/content/main/card.jpg','');
--,'05.07.2021', true, 659.31, 33,'','/assets/img/content/main/card.jpg','');
--,'23.03.2021', false, 845.4, 2,'','/assets/img/content/main/card.jpg','');
--,'10.01.2021', false, 516.33, 14,'','/assets/img/content/main/card.jpg','');
--,'15.10.2021', true, 950.37, 42,'','/assets/img/content/main/card.jpg','');
--,'09.01.2021', true, 719.69, 35,'','/assets/img/content/main/card.jpg','');
--,'07.10.2021', true, 453.04, 1,'','/assets/img/content/main/card.jpg','');
--,'25.12.2021', true, 320.92, 7,'','/assets/img/content/main/card.jpg','');
--,'05.02.2021', false, 314.74, 15,'','/assets/img/content/main/card.jpg','');
--,'01.04.2021', false, 549.71, 11,'','/assets/img/content/main/card.jpg','');
--,'10.07.2021', false, 618.18, 8,'','/assets/img/content/main/card.jpg','');
--,'12.05.2021', false, 643.34, 32,'','/assets/img/content/main/card.jpg','');
--,'13.07.2021', true, 573.2, 5,'','/assets/img/content/main/card.jpg','');
--,'04.01.2021', false, 891.54, 45,'','/assets/img/content/main/card.jpg','');
--,'21.05.2021', true, 680.54, 39,'','/assets/img/content/main/card.jpg','');
--,'05.03.2021', true, 363.47, 50,'','/assets/img/content/main/card.jpg','');
--,'25.08.2021', true, 661.22, 20,'','/assets/img/content/main/card.jpg','');
--,'23.12.2021', true, 857.77, 35,'','/assets/img/content/main/card.jpg','');
--,'24.01.2021', true, 910.64, 49,'','/assets/img/content/main/card.jpg','');
--,'30.08.2021', false, 865.22, 9,'','/assets/img/content/main/card.jpg','');
--,'15.01.2021', false, 382.77, 9,'','/assets/img/content/main/card.jpg','');
--,'07.06.2021', false, 446.95, 48,'','/assets/img/content/main/card.jpg','');
--,'01.04.2021', true, 899.71, 9,'','/assets/img/content/main/card.jpg','');
--,'15.05.2021', true, 387.32, 12,'','/assets/img/content/main/card.jpg','');
--,'08.05.2021', false, 468.52, 50,'','/assets/img/content/main/card.jpg','');
--,'11.06.2021', true, 910.31, 2,'','/assets/img/content/main/card.jpg','');
--,'03.06.2021', true, 248.94, 13,'','/assets/img/content/main/card.jpg','');
--,'10.05.2021', true, 755.75, 31,'','/assets/img/content/main/card.jpg','');
--,'19.03.2021', false, 964.58, 32,'','/assets/img/content/main/card.jpg','');
--,'07.06.2021', false, 235.41, 30,'','/assets/img/content/main/card.jpg','');
--,'29.03.2021', false, 830.33, 35,'','/assets/img/content/main/card.jpg','');
--,'19.03.2021', false, 408.15, 11,'','/assets/img/content/main/card.jpg','');
--,'18.01.2021', true, 532.56, 34,'','/assets/img/content/main/card.jpg','');
--,'12.01.2021', true, 995.71, 33,'','/assets/img/content/main/card.jpg','');
--,'18.10.2021', false, 976.29, 15,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', false, 890.15, 24,'','/assets/img/content/main/card.jpg','');
--,'21.06.2021', true, 409.47, 44,'','/assets/img/content/main/card.jpg','');
--,'26.04.2021', true, 381.28, 14,'','/assets/img/content/main/card.jpg','');
--,'03.02.2021', false, 786.51, 5,'','/assets/img/content/main/card.jpg','');
--,'06.11.2021', false, 374.88, 17,'','/assets/img/content/main/card.jpg','');
--,'28.04.2021', true, 724.4, 45,'','/assets/img/content/main/card.jpg','');
--,'15.12.2021', false, 542.58, 48,'','/assets/img/content/main/card.jpg','');
--,'16.03.2021', false, 444.89, 36,'','/assets/img/content/main/card.jpg','');
--,'29.01.2021', true, 875.31, 33,'','/assets/img/content/main/card.jpg','');
--,'11.02.2021', false, 298.0, 34,'','/assets/img/content/main/card.jpg','');
--,'05.04.2021', true, 512.4, 31,'','/assets/img/content/main/card.jpg','');
--,'27.08.2021', true, 709.62, 16,'','/assets/img/content/main/card.jpg','');
--,'12.03.2021', false, 894.47, 34,'','/assets/img/content/main/card.jpg','');
--,'05.05.2021', true, 858.78, 36,'','/assets/img/content/main/card.jpg','');
--,'15.09.2021', true, 532.58, 1,'','/assets/img/content/main/card.jpg','');
--,'02.01.2021', true, 887.92, 36,'','/assets/img/content/main/card.jpg','');
--,'31.10.2021', true, 994.89, 48,'','/assets/img/content/main/card.jpg','');
--,'05.05.2021', false, 385.48, 3,'','/assets/img/content/main/card.jpg','');
--,'21.05.2021', false, 549.78, 10,'','/assets/img/content/main/card.jpg','');
--,'04.05.2021', true, 478.47, 10,'','/assets/img/content/main/card.jpg','');
--,'17.07.2021', true, 366.45, 18,'','/assets/img/content/main/card.jpg','');
--,'25.05.2021', true, 553.63, 17,'','/assets/img/content/main/card.jpg','');
--,'20.07.2021', false, 749.42, 18,'','/assets/img/content/main/card.jpg','');
--,'08.06.2021', false, 538.22, 49,'','/assets/img/content/main/card.jpg','');
--,'21.06.2021', false, 279.15, 26,'','/assets/img/content/main/card.jpg','');
--,'28.12.2021', false, 358.46, 41,'','/assets/img/content/main/card.jpg','');
--,'02.03.2021', true, 569.78, 23,'','/assets/img/content/main/card.jpg','');
--,'02.07.2021', true, 876.7, 23,'','/assets/img/content/main/card.jpg','');
--,'07.11.2021', true, 814.04, 25,'','/assets/img/content/main/card.jpg','');
--,'19.07.2021', false, 528.96, 41,'','/assets/img/content/main/card.jpg','');
--,'18.12.2021', false, 685.5, 24,'','/assets/img/content/main/card.jpg','');
--,'21.08.2021', false, 714.54, 43,'','/assets/img/content/main/card.jpg','');
--,'11.07.2021', false, 350.44, 14,'','/assets/img/content/main/card.jpg','');
--,'30.07.2021', true, 756.37, 38,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', false, 209.96, 15,'','/assets/img/content/main/card.jpg','');
--,'08.09.2021', false, 234.24, 45,'','/assets/img/content/main/card.jpg','');
--,'20.05.2021', true, 264.11, 8,'','/assets/img/content/main/card.jpg','');
--,'25.05.2021', false, 629.97, 9,'','/assets/img/content/main/card.jpg','');
--,'03.07.2021', false, 216.6, 49,'','/assets/img/content/main/card.jpg','');
--,'25.06.2021', true, 482.34, 7,'','/assets/img/content/main/card.jpg','');
--,'24.08.2021', true, 996.21, 21,'','/assets/img/content/main/card.jpg','');
--,'26.10.2021', true, 532.82, 38,'','/assets/img/content/main/card.jpg','');
--,'05.10.2021', false, 463.59, 24,'','/assets/img/content/main/card.jpg','');
--,'05.03.2021', false, 291.62, 35,'','/assets/img/content/main/card.jpg','');
--,'02.02.2021', true, 367.02, 30,'','/assets/img/content/main/card.jpg','');
--,'04.06.2021', true, 520.98, 12,'','/assets/img/content/main/card.jpg','');
--,'12.01.2021', true, 437.26, 21,'','/assets/img/content/main/card.jpg','');
--,'27.02.2021', true, 511.83, 14,'','/assets/img/content/main/card.jpg','');
--,'04.06.2021', false, 425.24, 17,'','/assets/img/content/main/card.jpg','');
--,'22.04.2021', true, 782.87, 20,'','/assets/img/content/main/card.jpg','');
--,'10.09.2021', false, 384.38, 43,'','/assets/img/content/main/card.jpg','');
--,'18.10.2021', true, 314.5, 43,'','/assets/img/content/main/card.jpg','');
--,'01.03.2021', true, 227.11, 37,'','/assets/img/content/main/card.jpg','');
--,'03.11.2021', true, 808.86, 17,'','/assets/img/content/main/card.jpg','');
--,'28.06.2021', false, 301.38, 20,'','/assets/img/content/main/card.jpg','');
--,'18.10.2021', true, 392.69, 17,'','/assets/img/content/main/card.jpg','');
--,'18.06.2021', true, 531.31, 13,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 200.47, 10,'','/assets/img/content/main/card.jpg','');
--,'15.03.2021', false, 348.02, 12,'','/assets/img/content/main/card.jpg','');
--,'05.08.2021', false, 547.99, 37,'','/assets/img/content/main/card.jpg','');
--,'09.02.2021', true, 884.79, 49,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', true, 277.23, 10,'','/assets/img/content/main/card.jpg','');
--,'20.08.2021', false, 521.15, 20,'','/assets/img/content/main/card.jpg','');
--,'05.01.2021', true, 473.81, 19,'','/assets/img/content/main/card.jpg','');
--,'07.04.2021', false, 219.29, 35,'','/assets/img/content/main/card.jpg','');
--,'20.05.2021', false, 431.3, 3,'','/assets/img/content/main/card.jpg','');
--,'02.05.2021', false, 730.3, 15,'','/assets/img/content/main/card.jpg','');
--,'26.10.2021', true, 947.6, 45,'','/assets/img/content/main/card.jpg','');
--,'23.09.2021', true, 293.23, 28,'','/assets/img/content/main/card.jpg','');
--,'07.02.2021', true, 857.92, 18,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 247.51, 13,'','/assets/img/content/main/card.jpg','');
--,'16.12.2021', false, 579.11, 43,'','/assets/img/content/main/card.jpg','');
--,'30.04.2021', true, 237.37, 23,'','/assets/img/content/main/card.jpg','');
--,'19.03.2021', true, 353.89, 35,'','/assets/img/content/main/card.jpg','');
--,'20.10.2021', false, 672.34, 25,'','/assets/img/content/main/card.jpg','');
--,'16.10.2021', true, 449.52, 1,'','/assets/img/content/main/card.jpg','');
--,'05.04.2021', true, 444.87, 26,'','/assets/img/content/main/card.jpg','');
--,'28.12.2021', true, 496.43, 22,'','/assets/img/content/main/card.jpg','');
--,'30.06.2021', true, 565.81, 4,'','/assets/img/content/main/card.jpg','');
--,'04.11.2021', true, 330.7, 34,'','/assets/img/content/main/card.jpg','');
--,'26.01.2021', false, 590.85, 37,'','/assets/img/content/main/card.jpg','');
--,'19.09.2021', false, 573.09, 3,'','/assets/img/content/main/card.jpg','');
--,'03.07.2021', true, 938.51, 24,'','/assets/img/content/main/card.jpg','');
--,'02.04.2021', false, 292.46, 8,'','/assets/img/content/main/card.jpg','');
--,'09.06.2021', true, 501.49, 18,'','/assets/img/content/main/card.jpg','');
--,'17.08.2021', true, 271.71, 29,'','/assets/img/content/main/card.jpg','');
--,'09.08.2021', true, 660.2, 2,'','/assets/img/content/main/card.jpg','');
--,'10.08.2021', false, 661.82, 2,'','/assets/img/content/main/card.jpg','');
--,'23.07.2021', false, 925.75, 46,'','/assets/img/content/main/card.jpg','');
--,'07.06.2021', true, 632.89, 6,'','/assets/img/content/main/card.jpg','');
--,'13.09.2021', true, 424.01, 29,'','/assets/img/content/main/card.jpg','');
--,'01.04.2021', false, 635.83, 49,'','/assets/img/content/main/card.jpg','');
--,'21.03.2021', true, 464.68, 20,'','/assets/img/content/main/card.jpg','');
--,'12.06.2021', false, 808.02, 13,'','/assets/img/content/main/card.jpg','');
--,'22.06.2021', true, 996.34, 48,'','/assets/img/content/main/card.jpg','');
--,'28.02.2021', true, 849.34, 34,'','/assets/img/content/main/card.jpg','');
--,'07.05.2021', true, 210.3, 14,'','/assets/img/content/main/card.jpg','');
--,'26.08.2021', false, 363.67, 29,'','/assets/img/content/main/card.jpg','');
--,'22.11.2021', true, 452.92, 42,'','/assets/img/content/main/card.jpg','');
--,'27.07.2021', false, 297.47, 26,'','/assets/img/content/main/card.jpg','');
--,'27.06.2021', false, 999.03, 41,'','/assets/img/content/main/card.jpg','');
--,'15.11.2021', false, 286.18, 40,'','/assets/img/content/main/card.jpg','');
--,'03.05.2021', true, 759.68, 46,'','/assets/img/content/main/card.jpg','');
--,'27.10.2021', false, 586.46, 7,'','/assets/img/content/main/card.jpg','');
--,'09.10.2021', true, 408.6, 2,'','/assets/img/content/main/card.jpg','');
--,'02.07.2021', true, 978.28, 15,'','/assets/img/content/main/card.jpg','');
--,'15.12.2021', true, 898.95, 40,'','/assets/img/content/main/card.jpg','');
--,'18.11.2021', true, 375.53, 18,'','/assets/img/content/main/card.jpg','');
--,'22.09.2021', false, 339.82, 2,'','/assets/img/content/main/card.jpg','');
--,'14.10.2021', true, 771.42, 13,'','/assets/img/content/main/card.jpg','');
--,'03.03.2021', true, 579.43, 5,'','/assets/img/content/main/card.jpg','');
--,'20.04.2021', false, 274.99, 12,'','/assets/img/content/main/card.jpg','');
--,'30.12.2021', false, 910.47, 36,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', true, 272.1, 12,'','/assets/img/content/main/card.jpg','');
--,'06.01.2021', true, 222.24, 43,'','/assets/img/content/main/card.jpg','');
--,'15.07.2021', true, 283.19, 18,'','/assets/img/content/main/card.jpg','');
--,'12.01.2021', true, 804.07, 21,'','/assets/img/content/main/card.jpg','');
--,'09.11.2021', true, 917.21, 19,'','/assets/img/content/main/card.jpg','');
--,'18.11.2021', false, 444.41, 47,'','/assets/img/content/main/card.jpg','');
--,'15.10.2021', false, 637.17, 23,'','/assets/img/content/main/card.jpg','');
--,'14.09.2021', true, 900.81, 1,'','/assets/img/content/main/card.jpg','');
--,'26.02.2021', true, 613.8, 13,'','/assets/img/content/main/card.jpg','');
--,'13.12.2021', true, 439.58, 37,'','/assets/img/content/main/card.jpg','');
--,'20.11.2021', true, 419.39, 9,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', true, 709.83, 31,'','/assets/img/content/main/card.jpg','');
--,'04.05.2021', false, 701.47, 39,'','/assets/img/content/main/card.jpg','');
--,'25.11.2021', false, 903.79, 12,'','/assets/img/content/main/card.jpg','');
--,'30.09.2021', true, 437.8, 7,'','/assets/img/content/main/card.jpg','');
--,'02.07.2021', true, 713.66, 4,'','/assets/img/content/main/card.jpg','');
--,'31.03.2021', true, 871.01, 20,'','/assets/img/content/main/card.jpg','');
--,'23.12.2021', false, 245.87, 30,'','/assets/img/content/main/card.jpg','');
--,'06.04.2021', false, 745.6, 28,'','/assets/img/content/main/card.jpg','');
--,'14.05.2021', false, 405.6, 20,'','/assets/img/content/main/card.jpg','');
--,'05.10.2021', true, 482.45, 22,'','/assets/img/content/main/card.jpg','');
--,'28.03.2021', true, 669.67, 29,'','/assets/img/content/main/card.jpg','');
--,'02.03.2021', true, 279.48, 31,'','/assets/img/content/main/card.jpg','');
--,'02.04.2021', true, 607.07, 50,'','/assets/img/content/main/card.jpg','');
--,'31.05.2021', true, 669.11, 43,'','/assets/img/content/main/card.jpg','');
--,'31.07.2021', true, 285.87, 2,'','/assets/img/content/main/card.jpg','');
--,'06.02.2021', true, 872.48, 9,'','/assets/img/content/main/card.jpg','');
--,'28.01.2021', true, 547.77, 25,'','/assets/img/content/main/card.jpg','');
--,'06.07.2021', false, 961.92, 28,'','/assets/img/content/main/card.jpg','');
--,'26.03.2021', false, 210.49, 34,'','/assets/img/content/main/card.jpg','');
--,'29.01.2021', true, 623.34, 30,'','/assets/img/content/main/card.jpg','');
--,'23.05.2021', false, 521.76, 32,'','/assets/img/content/main/card.jpg','');
--,'05.10.2021', false, 683.81, 29,'','/assets/img/content/main/card.jpg','');
--,'14.02.2021', true, 292.23, 46,'','/assets/img/content/main/card.jpg','');
--,'16.09.2021', false, 764.14, 23,'','/assets/img/content/main/card.jpg','');
--,'03.02.2021', true, 887.27, 44,'','/assets/img/content/main/card.jpg','');
--,'17.06.2021', true, 568.16, 16,'','/assets/img/content/main/card.jpg','');
--,'01.11.2021', true, 409.94, 48,'','/assets/img/content/main/card.jpg','');
--,'29.03.2021', false, 268.02, 12,'','/assets/img/content/main/card.jpg','');
--,'14.05.2021', true, 416.49, 7,'','/assets/img/content/main/card.jpg','');
--,'26.06.2021', false, 225.34, 27,'','/assets/img/content/main/card.jpg','');
--,'13.01.2021', false, 867.16, 24,'','/assets/img/content/main/card.jpg','');
--,'17.05.2021', false, 712.87, 44,'','/assets/img/content/main/card.jpg','');
--,'16.04.2021', true, 394.16, 25,'','/assets/img/content/main/card.jpg','');
--,'18.07.2021', true, 878.61, 40,'','/assets/img/content/main/card.jpg','');
--,'09.09.2021', true, 319.35, 45,'','/assets/img/content/main/card.jpg','');
--,'06.05.2021', false, 934.34, 26,'','/assets/img/content/main/card.jpg','');
--,'15.02.2021', true, 724.08, 25,'','/assets/img/content/main/card.jpg','');
--,'23.03.2021', true, 364.55, 29,'','/assets/img/content/main/card.jpg','');
--,'08.04.2021', false, 655.37, 5,'','/assets/img/content/main/card.jpg','');
--,'21.12.2021', true, 627.8, 21,'','/assets/img/content/main/card.jpg','');
--,'09.05.2021', false, 750.41, 31,'','/assets/img/content/main/card.jpg','');
--,'04.04.2021', false, 416.05, 45,'','/assets/img/content/main/card.jpg','');
--,'11.08.2021', true, 726.73, 43,'','/assets/img/content/main/card.jpg','');
--,'04.03.2021', false, 996.36, 10,'','/assets/img/content/main/card.jpg','');
--,'02.08.2021', true, 953.55, 3,'','/assets/img/content/main/card.jpg','');
--,'13.10.2021', false, 540.72, 12,'','/assets/img/content/main/card.jpg','');
--,'28.09.2021', false, 470.02, 47,'','/assets/img/content/main/card.jpg','');
--,'11.01.2021', true, 603.4, 42,'','/assets/img/content/main/card.jpg','');
--,'06.07.2021', false, 963.9, 1,'','/assets/img/content/main/card.jpg','');
--,'09.05.2021', false, 281.34, 31,'','/assets/img/content/main/card.jpg','');
--,'28.05.2021', false, 947.9, 40,'','/assets/img/content/main/card.jpg','');
--,'05.01.2021', true, 632.87, 35,'','/assets/img/content/main/card.jpg','');
--,'02.03.2021', true, 623.7, 16,'','/assets/img/content/main/card.jpg','');
--,'25.03.2021', true, 698.98, 9,'','/assets/img/content/main/card.jpg','');
--,'12.02.2021', true, 997.39, 3,'','/assets/img/content/main/card.jpg','');
--,'26.11.2021', false, 819.24, 45,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 986.03, 18,'','/assets/img/content/main/card.jpg','');
--,'11.10.2021', true, 310.63, 12,'','/assets/img/content/main/card.jpg','');
--,'23.05.2021', true, 240.99, 30,'','/assets/img/content/main/card.jpg','');
--,'19.03.2021', true, 235.42, 5,'','/assets/img/content/main/card.jpg','');
--,'11.03.2021', true, 590.92, 15,'','/assets/img/content/main/card.jpg','');
--,'05.05.2021', true, 607.01, 47,'','/assets/img/content/main/card.jpg','');
--,'28.12.2021', false, 686.33, 26,'','/assets/img/content/main/card.jpg','');
--,'11.09.2021', true, 642.57, 31,'','/assets/img/content/main/card.jpg','');
--,'07.04.2021', true, 704.81, 41,'','/assets/img/content/main/card.jpg','');
--,'18.10.2021', true, 354.55, 31,'','/assets/img/content/main/card.jpg','');
--,'21.03.2021', false, 853.11, 35,'','/assets/img/content/main/card.jpg','');
--,'29.07.2021', false, 653.13, 5,'','/assets/img/content/main/card.jpg','');
--,'23.05.2021', false, 944.97, 2,'','/assets/img/content/main/card.jpg','');
--,'26.01.2021', false, 780.47, 30,'','/assets/img/content/main/card.jpg','');
--,'10.03.2021', false, 208.89, 3,'','/assets/img/content/main/card.jpg','');
--,'02.06.2021', false, 714.26, 34,'','/assets/img/content/main/card.jpg','');
--,'14.10.2021', true, 709.74, 50,'','/assets/img/content/main/card.jpg','');
--,'03.02.2021', true, 908.95, 12,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', true, 536.61, 39,'','/assets/img/content/main/card.jpg','');
--,'17.03.2021', false, 559.54, 13,'','/assets/img/content/main/card.jpg','');
--,'01.06.2021', true, 690.65, 21,'','/assets/img/content/main/card.jpg','');
--,'24.03.2021', false, 843.72, 23,'','/assets/img/content/main/card.jpg','');
--,'23.03.2021', true, 280.76, 47,'','/assets/img/content/main/card.jpg','');
--,'04.01.2021', false, 604.71, 1,'','/assets/img/content/main/card.jpg','');
--,'20.09.2021', false, 985.0, 37,'','/assets/img/content/main/card.jpg','');
--,'18.06.2021', false, 856.17, 5,'','/assets/img/content/main/card.jpg','');
--,'06.07.2021', false, 727.35, 26,'','/assets/img/content/main/card.jpg','');
--,'14.03.2021', true, 994.3, 29,'','/assets/img/content/main/card.jpg','');
--,'20.06.2021', true, 983.73, 34,'','/assets/img/content/main/card.jpg','');
--,'16.03.2021', true, 218.05, 35,'','/assets/img/content/main/card.jpg','');
--,'13.06.2021', false, 842.82, 21,'','/assets/img/content/main/card.jpg','');
--,'03.12.2021', false, 789.5, 1,'','/assets/img/content/main/card.jpg','');
--,'30.03.2021', false, 325.42, 34,'','/assets/img/content/main/card.jpg','');
--,'26.10.2021', false, 936.18, 1,'','/assets/img/content/main/card.jpg','');
--,'06.03.2021', true, 770.78, 39,'','/assets/img/content/main/card.jpg','');
--,'11.09.2021', true, 680.74, 5,'','/assets/img/content/main/card.jpg','');
--,'04.06.2021', true, 271.13, 24,'','/assets/img/content/main/card.jpg','');
--,'18.09.2021', false, 286.37, 12,'','/assets/img/content/main/card.jpg','');
--,'13.07.2021', false, 977.33, 35,'','/assets/img/content/main/card.jpg','');
--,'29.09.2021', true, 882.25, 26,'','/assets/img/content/main/card.jpg','');
--,'15.08.2021', true, 232.39, 47,'','/assets/img/content/main/card.jpg','');
--,'12.09.2021', false, 425.19, 40,'','/assets/img/content/main/card.jpg','');
--,'27.01.2021', false, 205.89, 13,'','/assets/img/content/main/card.jpg','');
--,'13.06.2021', false, 235.19, 19,'','/assets/img/content/main/card.jpg','');
--,'26.09.2021', true, 546.32, 14,'','/assets/img/content/main/card.jpg','');
--,'05.08.2021', false, 581.96, 17,'','/assets/img/content/main/card.jpg','');
--,'13.04.2021', false, 669.68, 23,'','/assets/img/content/main/card.jpg','');
--,'28.03.2021', false, 506.92, 8,'','/assets/img/content/main/card.jpg','');
--,'14.10.2021', false, 587.83, 38,'','/assets/img/content/main/card.jpg','');
--,'30.11.2021', false, 808.05, 9,'','/assets/img/content/main/card.jpg','');
--,'14.01.2021', false, 576.46, 28,'','/assets/img/content/main/card.jpg','');
--,'22.12.2021', true, 371.19, 37,'','/assets/img/content/main/card.jpg','');
--,'15.03.2021', false, 754.21, 10,'','/assets/img/content/main/card.jpg','');
--,'06.02.2021', false, 458.46, 17,'','/assets/img/content/main/card.jpg','');
--,'04.01.2021', false, 417.72, 5,'','/assets/img/content/main/card.jpg','');
--,'28.04.2021', true, 978.71, 46,'','/assets/img/content/main/card.jpg','');
--,'23.06.2021', false, 360.41, 19,'','/assets/img/content/main/card.jpg','');
--,'07.12.2021', false, 911.19, 39,'','/assets/img/content/main/card.jpg','');
--,'07.09.2021', false, 407.78, 50,'','/assets/img/content/main/card.jpg','');
--,'30.03.2021', false, 282.78, 23,'','/assets/img/content/main/card.jpg','');
--,'24.01.2021', false, 655.2, 43,'','/assets/img/content/main/card.jpg','');
--,'21.11.2021', true, 792.16, 47,'','/assets/img/content/main/card.jpg','');
--,'14.02.2021', true, 286.95, 7,'','/assets/img/content/main/card.jpg','');
--,'30.09.2021', true, 778.4, 6,'','/assets/img/content/main/card.jpg','');
--,'29.05.2021', true, 992.81, 12,'','/assets/img/content/main/card.jpg','');
--,'31.05.2021', true, 670.43, 17,'','/assets/img/content/main/card.jpg','');
--,'15.10.2021', false, 907.97, 11,'','/assets/img/content/main/card.jpg','');
--,'15.08.2021', true, 839.21, 35,'','/assets/img/content/main/card.jpg','');
--,'24.11.2021', true, 585.48, 14,'','/assets/img/content/main/card.jpg','');
--,'13.05.2021', true, 893.38, 11,'','/assets/img/content/main/card.jpg','');
--,'02.03.2021', true, 902.17, 13,'','/assets/img/content/main/card.jpg','');
--,'21.05.2021', true, 349.28, 2,'','/assets/img/content/main/card.jpg','');
--,'31.08.2021', false, 637.42, 50,'','/assets/img/content/main/card.jpg','');
--,'25.01.2021', false, 225.19, 4,'','/assets/img/content/main/card.jpg','');
--,'07.07.2021', true, 207.5, 7,'','/assets/img/content/main/card.jpg','');
--,'12.10.2021', true, 767.47, 19,'','/assets/img/content/main/card.jpg','');
--,'23.12.2021', true, 920.84, 2,'','/assets/img/content/main/card.jpg','');
--,'02.02.2021', false, 412.95, 32,'','/assets/img/content/main/card.jpg','');
--,'29.06.2021', false, 721.32, 15,'','/assets/img/content/main/card.jpg','');
--,'08.02.2021', false, 706.65, 26,'','/assets/img/content/main/card.jpg','');
--,'02.12.2021', true, 966.3, 14,'','/assets/img/content/main/card.jpg','');
--,'17.05.2021', true, 260.25, 44,'','/assets/img/content/main/card.jpg','');
--,'14.04.2021', true, 418.75, 49,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', false, 287.02, 13,'','/assets/img/content/main/card.jpg','');
--,'11.03.2021', false, 307.86, 27,'','/assets/img/content/main/card.jpg','');
--,'20.02.2021', true, 817.73, 35,'','/assets/img/content/main/card.jpg','');
--,'09.02.2021', true, 538.89, 19,'','/assets/img/content/main/card.jpg','');
--,'04.01.2021', false, 603.38, 24,'','/assets/img/content/main/card.jpg','');
--,'16.08.2021', true, 912.21, 21,'','/assets/img/content/main/card.jpg','');
--,'01.02.2021', false, 987.13, 41,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', true, 702.84, 9,'','/assets/img/content/main/card.jpg','');
--,'27.11.2021', false, 828.15, 28,'','/assets/img/content/main/card.jpg','');
--,'29.01.2021', false, 482.91, 46,'','/assets/img/content/main/card.jpg','');
--,'20.08.2021', false, 799.68, 13,'','/assets/img/content/main/card.jpg','');
--,'06.05.2021', true, 881.25, 44,'','/assets/img/content/main/card.jpg','');
--,'08.01.2021', false, 795.95, 37,'','/assets/img/content/main/card.jpg','');
--,'21.11.2021', false, 348.84, 8,'','/assets/img/content/main/card.jpg','');
--,'15.12.2021', false, 279.22, 49,'','/assets/img/content/main/card.jpg','');
--,'17.03.2021', false, 465.38, 37,'','/assets/img/content/main/card.jpg','');
--,'20.04.2021', true, 980.39, 12,'','/assets/img/content/main/card.jpg','');
--,'04.06.2021', false, 781.59, 21,'','/assets/img/content/main/card.jpg','');
--,'10.01.2021', true, 580.06, 38,'','/assets/img/content/main/card.jpg','');
--,'01.01.2021', false, 699.34, 6,'','/assets/img/content/main/card.jpg','');
--,'24.03.2021', true, 484.52, 35,'','/assets/img/content/main/card.jpg','');
--,'27.02.2021', false, 506.07, 22,'','/assets/img/content/main/card.jpg','');
--,'22.06.2021', true, 321.54, 6,'','/assets/img/content/main/card.jpg','');
--,'03.08.2021', false, 540.13, 30,'','/assets/img/content/main/card.jpg','');
--,'29.01.2021', true, 910.99, 34,'','/assets/img/content/main/card.jpg','');
--,'12.07.2021', false, 784.89, 13,'','/assets/img/content/main/card.jpg','');
--,'26.06.2021', true, 484.27, 38,'','/assets/img/content/main/card.jpg','');
--,'15.08.2021', true, 605.84, 31,'','/assets/img/content/main/card.jpg','');
--,'27.12.2021', false, 478.16, 22,'','/assets/img/content/main/card.jpg','');
--,'04.02.2021', true, 722.31, 1,'','/assets/img/content/main/card.jpg','');
--,'15.06.2021', true, 825.54, 28,'','/assets/img/content/main/card.jpg','');
--,'02.09.2021', false, 980.23, 2,'','/assets/img/content/main/card.jpg','');
--,'08.12.2021', true, 482.35, 13,'','/assets/img/content/main/card.jpg','');
--,'04.03.2021', false, 250.43, 25,'','/assets/img/content/main/card.jpg','');
--,'10.10.2021', true, 779.77, 10,'','/assets/img/content/main/card.jpg','');
--,'15.05.2021', false, 920.92, 47,'','/assets/img/content/main/card.jpg','');
--,'03.03.2021', true, 407.84, 47,'','/assets/img/content/main/card.jpg','');
--,'18.10.2021', false, 253.12, 45,'','/assets/img/content/main/card.jpg','');
--,'02.10.2021', true, 664.27, 2,'','/assets/img/content/main/card.jpg','');
--,'26.08.2021', true, 857.37, 18,'','/assets/img/content/main/card.jpg','');
--,'05.04.2021', true, 209.59, 30,'','/assets/img/content/main/card.jpg','');
--,'28.08.2021', false, 764.11, 46,'','/assets/img/content/main/card.jpg','');
--,'30.08.2021', false, 512.61, 10,'','/assets/img/content/main/card.jpg','');
--,'07.02.2021', true, 353.47, 39,'','/assets/img/content/main/card.jpg','');
--,'20.11.2021', false, 366.3, 20,'','/assets/img/content/main/card.jpg','');
--,'26.09.2021', false, 506.53, 19,'','/assets/img/content/main/card.jpg','');
--,'08.02.2021', false, 344.16, 18,'','/assets/img/content/main/card.jpg','');
--,'17.09.2021', false, 608.98, 24,'','/assets/img/content/main/card.jpg','');
--,'23.04.2021', true, 931.19, 38,'','/assets/img/content/main/card.jpg','');
--,'04.11.2021', true, 250.92, 50,'','/assets/img/content/main/card.jpg','');
--,'27.08.2021', false, 513.43, 41,'','/assets/img/content/main/card.jpg','');
--,'13.07.2021', true, 820.92, 28,'','/assets/img/content/main/card.jpg','');
--,'19.10.2021', true, 349.5, 35,'','/assets/img/content/main/card.jpg','');
--,'17.11.2021', true, 597.03, 33,'','/assets/img/content/main/card.jpg','');
--,'02.09.2021', false, 910.37, 14,'','/assets/img/content/main/card.jpg','');
--,'25.01.2021', false, 673.64, 48,'','/assets/img/content/main/card.jpg','');
--,'03.07.2021', true, 364.31, 50,'','/assets/img/content/main/card.jpg','');
--,'27.10.2021', false, 690.3, 10,'','/assets/img/content/main/card.jpg','');
--,'27.01.2021', true, 313.35, 30,'','/assets/img/content/main/card.jpg','');
--,'04.04.2021', true, 754.7, 23,'','/assets/img/content/main/card.jpg','');
--,'22.02.2021', false, 764.51, 6,'','/assets/img/content/main/card.jpg','');
--,'21.03.2021', true, 773.37, 8,'','/assets/img/content/main/card.jpg','');
--,'03.05.2021', true, 204.85, 27,'','/assets/img/content/main/card.jpg','');
--,'17.07.2021', true, 771.06, 14,'','/assets/img/content/main/card.jpg','');
--,'27.03.2021', true, 985.9, 49,'','/assets/img/content/main/card.jpg','');
--,'29.04.2021', false, 636.98, 34,'','/assets/img/content/main/card.jpg','');
--,'30.11.2021', true, 526.93, 38,'','/assets/img/content/main/card.jpg','');
--,'28.04.2021', true, 314.37, 42,'','/assets/img/content/main/card.jpg','');
--,'05.11.2021', false, 271.8, 38,'','/assets/img/content/main/card.jpg','');
--,'27.11.2021', true, 544.19, 31,'','/assets/img/content/main/card.jpg','');
--,'16.05.2021', true, 227.0, 50,'','/assets/img/content/main/card.jpg','');
--,'07.08.2021', false, 865.4, 39,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', true, 653.46, 50,'','/assets/img/content/main/card.jpg','');
--,'22.11.2021', true, 540.24, 13,'','/assets/img/content/main/card.jpg','');
--,'01.12.2021', true, 708.57, 45,'','/assets/img/content/main/card.jpg','');
--,'02.06.2021', false, 832.79, 3,'','/assets/img/content/main/card.jpg','');
--,'09.02.2021', false, 427.08, 12,'','/assets/img/content/main/card.jpg','');
--,'04.04.2021', false, 995.64, 22,'','/assets/img/content/main/card.jpg','');
--,'27.07.2021', false, 762.16, 3,'','/assets/img/content/main/card.jpg','');
--,'23.06.2021', false, 952.98, 43,'','/assets/img/content/main/card.jpg','');
--,'27.01.2021', true, 831.84, 1,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', false, 703.5, 23,'','/assets/img/content/main/card.jpg','');
--,'02.08.2021', true, 460.13, 7,'','/assets/img/content/main/card.jpg','');
--,'08.11.2021', false, 542.06, 49,'','/assets/img/content/main/card.jpg','');
--,'03.04.2021', false, 437.61, 29,'','/assets/img/content/main/card.jpg','');
--,'30.01.2021', true, 491.68, 34,'','/assets/img/content/main/card.jpg','');
--,'29.11.2021', false, 867.76, 33,'','/assets/img/content/main/card.jpg','');
--,'07.05.2021', false, 417.23, 49,'','/assets/img/content/main/card.jpg','');
--,'07.10.2021', false, 445.73, 45,'','/assets/img/content/main/card.jpg','');
--,'17.11.2021', true, 586.87, 24,'','/assets/img/content/main/card.jpg','');
--,'10.03.2021', false, 743.73, 19,'','/assets/img/content/main/card.jpg','');
--,'05.05.2021', true, 203.13, 21,'','/assets/img/content/main/card.jpg','');
--,'27.12.2021', false, 693.01, 1,'','/assets/img/content/main/card.jpg','');
--,'10.08.2021', false, 691.74, 10,'','/assets/img/content/main/card.jpg','');
--,'07.04.2021', false, 962.8, 13,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', true, 633.66, 25,'','/assets/img/content/main/card.jpg','');
--,'02.12.2021', true, 317.95, 23,'','/assets/img/content/main/card.jpg','');
--,'03.05.2021', true, 206.5, 30,'','/assets/img/content/main/card.jpg','');
--,'26.06.2021', false, 367.45, 32,'','/assets/img/content/main/card.jpg','');
--,'18.09.2021', false, 687.79, 2,'','/assets/img/content/main/card.jpg','');
--,'28.05.2021', false, 308.58, 22,'','/assets/img/content/main/card.jpg','');
--,'27.12.2021', false, 793.89, 18,'','/assets/img/content/main/card.jpg','');
--,'16.02.2021', false, 537.41, 44,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', true, 693.04, 29,'','/assets/img/content/main/card.jpg','');
--,'24.12.2021', true, 692.71, 44,'','/assets/img/content/main/card.jpg','');
--,'04.09.2021', true, 727.94, 24,'','/assets/img/content/main/card.jpg','');
--,'21.07.2021', false, 285.34, 30,'','/assets/img/content/main/card.jpg','');
--,'29.12.2021', true, 406.1, 20,'','/assets/img/content/main/card.jpg','');
--,'03.08.2021', true, 923.8, 10,'','/assets/img/content/main/card.jpg','');
--,'10.10.2021', false, 913.03, 17,'','/assets/img/content/main/card.jpg','');
--,'10.05.2021', true, 310.87, 50,'','/assets/img/content/main/card.jpg','');
--,'01.06.2021', true, 832.62, 25,'','/assets/img/content/main/card.jpg','');
--,'05.04.2021', false, 981.73, 18,'','/assets/img/content/main/card.jpg','');
--,'15.03.2021', true, 743.21, 46,'','/assets/img/content/main/card.jpg','');
--,'14.11.2021', false, 714.87, 32,'','/assets/img/content/main/card.jpg','');
--,'14.10.2021', true, 223.1, 40,'','/assets/img/content/main/card.jpg','');
--,'31.01.2021', true, 735.65, 50,'','/assets/img/content/main/card.jpg','');
--,'13.12.2021', false, 963.97, 4,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', true, 804.9, 6,'','/assets/img/content/main/card.jpg','');
--,'12.10.2021', false, 565.09, 48,'','/assets/img/content/main/card.jpg','');
--,'21.10.2021', false, 374.52, 15,'','/assets/img/content/main/card.jpg','');
--,'11.02.2021', false, 372.77, 27,'','/assets/img/content/main/card.jpg','');
--,'02.11.2021', false, 395.34, 33,'','/assets/img/content/main/card.jpg','');
--,'29.11.2021', false, 523.69, 27,'','/assets/img/content/main/card.jpg','');
--,'29.12.2021', true, 268.36, 47,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', true, 406.05, 41,'','/assets/img/content/main/card.jpg','');
--,'13.12.2021', false, 956.46, 28,'','/assets/img/content/main/card.jpg','');
--,'08.11.2021', true, 588.51, 6,'','/assets/img/content/main/card.jpg','');
--,'01.04.2021', false, 303.73, 23,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', true, 483.96, 18,'','/assets/img/content/main/card.jpg','');
--,'08.05.2021', true, 312.53, 26,'','/assets/img/content/main/card.jpg','');
--,'26.12.2021', false, 678.32, 19,'','/assets/img/content/main/card.jpg','');
--,'13.10.2021', false, 973.91, 50,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', true, 858.79, 9,'','/assets/img/content/main/card.jpg','');
--,'27.01.2021', false, 714.47, 6,'','/assets/img/content/main/card.jpg','');
--,'06.07.2021', true, 218.32, 26,'','/assets/img/content/main/card.jpg','');
--,'29.10.2021', false, 917.26, 48,'','/assets/img/content/main/card.jpg','');
--,'30.11.2021', true, 714.72, 15,'','/assets/img/content/main/card.jpg','');
--,'07.02.2021', true, 834.58, 35,'','/assets/img/content/main/card.jpg','');
--,'16.01.2021', false, 854.06, 16,'','/assets/img/content/main/card.jpg','');
--,'12.01.2021', false, 350.67, 40,'','/assets/img/content/main/card.jpg','');
--,'29.10.2021', false, 614.61, 31,'','/assets/img/content/main/card.jpg','');
--,'16.05.2021', false, 587.4, 43,'','/assets/img/content/main/card.jpg','');
--,'17.02.2021', false, 292.8, 32,'','/assets/img/content/main/card.jpg','');
--,'12.02.2021', false, 740.78, 13,'','/assets/img/content/main/card.jpg','');
--,'10.12.2021', true, 913.14, 22,'','/assets/img/content/main/card.jpg','');
--,'15.04.2021', true, 492.19, 25,'','/assets/img/content/main/card.jpg','');
--,'25.09.2021', false, 405.43, 20,'','/assets/img/content/main/card.jpg','');
--,'06.01.2021', false, 493.49, 34,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', true, 500.09, 8,'','/assets/img/content/main/card.jpg','');
--,'22.09.2021', true, 451.1, 8,'','/assets/img/content/main/card.jpg','');
--,'15.02.2021', true, 843.6, 41,'','/assets/img/content/main/card.jpg','');
--,'09.05.2021', false, 705.82, 26,'','/assets/img/content/main/card.jpg','');
--,'26.06.2021', true, 333.46, 9,'','/assets/img/content/main/card.jpg','');
--,'02.11.2021', true, 877.05, 31,'','/assets/img/content/main/card.jpg','');
--,'11.02.2021', true, 930.22, 34,'','/assets/img/content/main/card.jpg','');
--,'30.07.2021', false, 298.78, 18,'','/assets/img/content/main/card.jpg','');
--,'10.02.2021', false, 961.85, 39,'','/assets/img/content/main/card.jpg','');
--,'25.03.2021', true, 537.95, 39,'','/assets/img/content/main/card.jpg','');
--,'31.08.2021', true, 690.07, 48,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 389.38, 6,'','/assets/img/content/main/card.jpg','');
--,'22.04.2021', true, 461.44, 40,'','/assets/img/content/main/card.jpg','');
--,'20.04.2021', false, 591.76, 41,'','/assets/img/content/main/card.jpg','');
--,'14.10.2021', false, 812.73, 4,'','/assets/img/content/main/card.jpg','');
--,'18.03.2021', false, 503.44, 2,'','/assets/img/content/main/card.jpg','');
--,'09.04.2021', false, 539.9, 46,'','/assets/img/content/main/card.jpg','');
--,'05.07.2021', false, 279.05, 17,'','/assets/img/content/main/card.jpg','');
--,'22.04.2021', true, 609.87, 19,'','/assets/img/content/main/card.jpg','');
--,'09.09.2021', false, 487.87, 29,'','/assets/img/content/main/card.jpg','');
--,'21.06.2021', false, 278.85, 21,'','/assets/img/content/main/card.jpg','');
--,'30.09.2021', false, 655.63, 1,'','/assets/img/content/main/card.jpg','');
--,'06.02.2021', false, 925.1, 28,'','/assets/img/content/main/card.jpg','');
--,'25.07.2021', true, 799.24, 40,'','/assets/img/content/main/card.jpg','');
--,'22.03.2021', false, 472.41, 42,'','/assets/img/content/main/card.jpg','');
--,'14.03.2021', true, 545.89, 29,'','/assets/img/content/main/card.jpg','');
--,'04.06.2021', false, 835.55, 5,'','/assets/img/content/main/card.jpg','');
--,'13.12.2021', false, 998.29, 2,'','/assets/img/content/main/card.jpg','');
--,'02.05.2021', false, 390.18, 19,'','/assets/img/content/main/card.jpg','');
--,'26.07.2021', false, 302.51, 15,'','/assets/img/content/main/card.jpg','');
--,'28.08.2021', false, 319.73, 45,'','/assets/img/content/main/card.jpg','');
--,'07.04.2021', false, 911.12, 22,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', true, 563.36, 22,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', true, 377.12, 19,'','/assets/img/content/main/card.jpg','');
--,'15.10.2021', true, 243.04, 13,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', false, 900.15, 31,'','/assets/img/content/main/card.jpg','');
--,'08.07.2021', false, 918.93, 6,'','/assets/img/content/main/card.jpg','');
--,'01.04.2021', false, 470.09, 11,'','/assets/img/content/main/card.jpg','');
--,'11.04.2021', true, 802.23, 7,'','/assets/img/content/main/card.jpg','');
--,'23.11.2021', true, 424.86, 16,'','/assets/img/content/main/card.jpg','');
--,'10.03.2021', false, 471.8, 42,'','/assets/img/content/main/card.jpg','');
--,'08.05.2021', true, 973.71, 4,'','/assets/img/content/main/card.jpg','');
--,'14.11.2021', true, 767.83, 35,'','/assets/img/content/main/card.jpg','');
--,'28.12.2021', false, 882.01, 26,'','/assets/img/content/main/card.jpg','');
--,'29.07.2021', false, 394.1, 37,'','/assets/img/content/main/card.jpg','');
--,'02.03.2021', false, 791.26, 40,'','/assets/img/content/main/card.jpg','');
--,'16.12.2021', true, 897.58, 35,'','/assets/img/content/main/card.jpg','');
--,'12.08.2021', false, 979.01, 32,'','/assets/img/content/main/card.jpg','');
--,'04.11.2021', false, 802.49, 42,'','/assets/img/content/main/card.jpg','');
--,'17.06.2021', false, 952.61, 29,'','/assets/img/content/main/card.jpg','');
--,'12.10.2021', false, 439.46, 47,'','/assets/img/content/main/card.jpg','');
--,'29.10.2021', true, 583.93, 19,'','/assets/img/content/main/card.jpg','');
--,'09.07.2021', true, 599.73, 25,'','/assets/img/content/main/card.jpg','');
--,'02.12.2021', true, 512.27, 50,'','/assets/img/content/main/card.jpg','');
--,'26.11.2021', true, 234.44, 19,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', false, 786.18, 21,'','/assets/img/content/main/card.jpg','');
--,'29.12.2021', true, 435.83, 46,'','/assets/img/content/main/card.jpg','');
--,'07.07.2021', true, 476.7, 30,'','/assets/img/content/main/card.jpg','');
--,'03.10.2021', false, 202.47, 22,'','/assets/img/content/main/card.jpg','');
--,'22.05.2021', false, 627.34, 1,'','/assets/img/content/main/card.jpg','');
--,'16.02.2021', false, 334.08, 41,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', false, 631.09, 7,'','/assets/img/content/main/card.jpg','');
--,'25.04.2021', true, 676.88, 14,'','/assets/img/content/main/card.jpg','');
--,'27.01.2021', false, 640.89, 33,'','/assets/img/content/main/card.jpg','');
--,'10.10.2021', false, 829.87, 24,'','/assets/img/content/main/card.jpg','');
--,'22.03.2021', true, 738.44, 29,'','/assets/img/content/main/card.jpg','');
--,'10.05.2021', false, 669.95, 11,'','/assets/img/content/main/card.jpg','');
--,'09.11.2021', false, 896.98, 48,'','/assets/img/content/main/card.jpg','');
--,'03.12.2021', true, 258.44, 3,'','/assets/img/content/main/card.jpg','');
--,'20.08.2021', false, 390.1, 44,'','/assets/img/content/main/card.jpg','');
--,'05.05.2021', true, 820.57, 26,'','/assets/img/content/main/card.jpg','');
--,'21.01.2021', true, 877.93, 50,'','/assets/img/content/main/card.jpg','');
--,'15.09.2021', true, 888.23, 27,'','/assets/img/content/main/card.jpg','');
--,'21.04.2021', true, 754.88, 39,'','/assets/img/content/main/card.jpg','');
--,'24.04.2021', true, 349.36, 16,'','/assets/img/content/main/card.jpg','');
--,'31.03.2021', true, 953.46, 20,'','/assets/img/content/main/card.jpg','');
--,'11.04.2021', true, 877.83, 12,'','/assets/img/content/main/card.jpg','');
--,'14.04.2021', true, 992.3, 40,'','/assets/img/content/main/card.jpg','');
--,'16.09.2021', false, 568.7, 12,'','/assets/img/content/main/card.jpg','');
--,'18.12.2021', false, 815.73, 42,'','/assets/img/content/main/card.jpg','');
--,'27.11.2021', true, 909.16, 48,'','/assets/img/content/main/card.jpg','');
--,'09.06.2021', true, 428.06, 11,'','/assets/img/content/main/card.jpg','');
--,'24.03.2021', true, 243.8, 48,'','/assets/img/content/main/card.jpg','');
--,'21.04.2021', true, 556.64, 8,'','/assets/img/content/main/card.jpg','');
--,'16.11.2021', true, 217.09, 16,'','/assets/img/content/main/card.jpg','');
--,'21.02.2021', true, 687.98, 49,'','/assets/img/content/main/card.jpg','');
--,'14.02.2021', false, 480.94, 9,'','/assets/img/content/main/card.jpg','');
--,'29.08.2021', false, 792.32, 30,'','/assets/img/content/main/card.jpg','');
--,'11.12.2021', false, 655.74, 1,'','/assets/img/content/main/card.jpg','');
--,'02.10.2021', false, 678.62, 27,'','/assets/img/content/main/card.jpg','');
--,'30.07.2021', true, 302.65, 50,'','/assets/img/content/main/card.jpg','');
--,'18.03.2021', true, 211.94, 12,'','/assets/img/content/main/card.jpg','');
--,'23.07.2021', true, 265.84, 42,'','/assets/img/content/main/card.jpg','');
--,'12.07.2021', true, 347.2, 37,'','/assets/img/content/main/card.jpg','');
--,'03.12.2021', true, 403.24, 5,'','/assets/img/content/main/card.jpg','');
--,'21.03.2021', false, 502.93, 30,'','/assets/img/content/main/card.jpg','');
--,'07.10.2021', true, 766.2, 32,'','/assets/img/content/main/card.jpg','');
--,'19.07.2021', false, 714.21, 8,'','/assets/img/content/main/card.jpg','');
--,'30.11.2021', false, 517.27, 48,'','/assets/img/content/main/card.jpg','');
--,'30.12.2021', true, 674.3, 28,'','/assets/img/content/main/card.jpg','');
--,'07.12.2021', false, 732.8, 32,'','/assets/img/content/main/card.jpg','');
--,'06.08.2021', true, 203.23, 9,'','/assets/img/content/main/card.jpg','');
--,'17.12.2021', true, 776.06, 6,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', true, 594.4, 42,'','/assets/img/content/main/card.jpg','');
--,'03.11.2021', true, 557.69, 11,'','/assets/img/content/main/card.jpg','');
--,'24.01.2021', false, 886.53, 40,'','/assets/img/content/main/card.jpg','');
--,'15.01.2021', true, 574.67, 38,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', false, 876.6, 25,'','/assets/img/content/main/card.jpg','');
--,'23.03.2021', false, 505.71, 8,'','/assets/img/content/main/card.jpg','');
--,'24.08.2021', true, 962.83, 26,'','/assets/img/content/main/card.jpg','');
--,'05.12.2021', false, 704.94, 16,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 336.65, 27,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', true, 735.77, 27,'','/assets/img/content/main/card.jpg','');
--,'02.08.2021', false, 588.32, 28,'','/assets/img/content/main/card.jpg','');
--,'04.01.2021', false, 405.06, 11,'','/assets/img/content/main/card.jpg','');
--,'19.06.2021', true, 412.73, 37,'','/assets/img/content/main/card.jpg','');
--,'29.07.2021', false, 274.97, 13,'','/assets/img/content/main/card.jpg','');
--,'25.10.2021', true, 861.45, 4,'','/assets/img/content/main/card.jpg','');
--,'20.10.2021', false, 717.4, 12,'','/assets/img/content/main/card.jpg','');
--,'10.10.2021', false, 642.47, 43,'','/assets/img/content/main/card.jpg','');
--,'23.07.2021', true, 587.34, 10,'','/assets/img/content/main/card.jpg','');
--,'17.09.2021', false, 256.4, 21,'','/assets/img/content/main/card.jpg','');
--,'12.12.2021', true, 843.06, 41,'','/assets/img/content/main/card.jpg','');
--,'26.04.2021', false, 685.58, 20,'','/assets/img/content/main/card.jpg','');
--,'27.06.2021', true, 413.84, 21,'','/assets/img/content/main/card.jpg','');
--,'18.04.2021', true, 463.29, 3,'','/assets/img/content/main/card.jpg','');
--,'09.08.2021', true, 843.92, 15,'','/assets/img/content/main/card.jpg','');
--,'07.10.2021', false, 453.65, 3,'','/assets/img/content/main/card.jpg','');
--,'04.12.2021', true, 649.13, 21,'','/assets/img/content/main/card.jpg','');
--,'15.04.2021', false, 424.6, 41,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', true, 406.3, 35,'','/assets/img/content/main/card.jpg','');
--,'02.06.2021', true, 575.15, 28,'','/assets/img/content/main/card.jpg','');
--,'11.07.2021', false, 447.3, 9,'','/assets/img/content/main/card.jpg','');
--,'07.12.2021', false, 572.67, 29,'','/assets/img/content/main/card.jpg','');
--,'18.05.2021', false, 813.75, 43,'','/assets/img/content/main/card.jpg','');
--,'05.04.2021', false, 427.11, 22,'','/assets/img/content/main/card.jpg','');
--,'08.04.2021', true, 641.93, 8,'','/assets/img/content/main/card.jpg','');
--,'21.12.2021', true, 958.62, 37,'','/assets/img/content/main/card.jpg','');
--,'31.01.2021', false, 431.54, 34,'','/assets/img/content/main/card.jpg','');
--,'08.08.2021', false, 453.33, 18,'','/assets/img/content/main/card.jpg','');
--,'14.05.2021', true, 795.78, 41,'','/assets/img/content/main/card.jpg','');
--,'26.11.2021', true, 610.41, 12,'','/assets/img/content/main/card.jpg','');
--,'02.12.2021', false, 699.36, 21,'','/assets/img/content/main/card.jpg','');
--,'11.02.2021', true, 828.05, 38,'','/assets/img/content/main/card.jpg','');
--,'23.05.2021', false, 222.6, 8,'','/assets/img/content/main/card.jpg','');
--,'20.04.2021', false, 227.58, 27,'','/assets/img/content/main/card.jpg','');
--,'30.03.2021', true, 936.04, 36,'','/assets/img/content/main/card.jpg','');
--,'26.07.2021', false, 230.21, 3,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', true, 983.67, 43,'','/assets/img/content/main/card.jpg','');
--,'21.02.2021', false, 571.2, 15,'','/assets/img/content/main/card.jpg','');
--,'15.03.2021', false, 924.19, 9,'','/assets/img/content/main/card.jpg','');
--,'21.07.2021', false, 942.46, 13,'','/assets/img/content/main/card.jpg','');
--,'23.07.2021', true, 527.22, 27,'','/assets/img/content/main/card.jpg','');
--,'16.11.2021', false, 360.25, 42,'','/assets/img/content/main/card.jpg','');
--,'13.02.2021', false, 664.09, 34,'','/assets/img/content/main/card.jpg','');
--,'05.02.2021', false, 407.1, 19,'','/assets/img/content/main/card.jpg','');
--,'06.04.2021', false, 440.84, 5,'','/assets/img/content/main/card.jpg','');
--,'17.07.2021', false, 873.24, 41,'','/assets/img/content/main/card.jpg','');
--,'14.04.2021', true, 857.55, 20,'','/assets/img/content/main/card.jpg','');
--,'06.12.2021', true, 675.76, 12,'','/assets/img/content/main/card.jpg','');
--,'11.04.2021', false, 352.94, 36,'','/assets/img/content/main/card.jpg','');
--,'17.10.2021', false, 661.11, 21,'','/assets/img/content/main/card.jpg','');
--,'23.02.2021', true, 860.26, 25,'','/assets/img/content/main/card.jpg','');
--,'18.08.2021', false, 654.93, 37,'','/assets/img/content/main/card.jpg','');
--,'19.05.2021', false, 249.97, 36,'','/assets/img/content/main/card.jpg','');
--,'20.03.2021', true, 362.59, 15,'','/assets/img/content/main/card.jpg','');
--,'07.02.2021', false, 523.22, 44,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', false, 874.21, 24,'','/assets/img/content/main/card.jpg','');
--,'06.12.2021', true, 218.37, 32,'','/assets/img/content/main/card.jpg','');
--,'22.10.2021', true, 773.39, 7,'','/assets/img/content/main/card.jpg','');
--,'10.08.2021', true, 330.88, 10,'','/assets/img/content/main/card.jpg','');
--,'05.02.2021', false, 238.22, 25,'','/assets/img/content/main/card.jpg','');
--,'27.11.2021', true, 917.62, 34,'','/assets/img/content/main/card.jpg','');
--,'12.05.2021', false, 528.67, 47,'','/assets/img/content/main/card.jpg','');
--,'17.04.2021', false, 767.29, 17,'','/assets/img/content/main/card.jpg','');
--,'25.02.2021', false, 413.15, 34,'','/assets/img/content/main/card.jpg','');
--,'08.04.2021', false, 795.92, 35,'','/assets/img/content/main/card.jpg','');
--,'12.07.2021', true, 961.07, 32,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', true, 761.35, 14,'','/assets/img/content/main/card.jpg','');
--,'01.02.2021', false, 970.87, 20,'','/assets/img/content/main/card.jpg','');
--,'15.07.2021', true, 280.33, 7,'','/assets/img/content/main/card.jpg','');
--,'20.04.2021', true, 912.53, 43,'','/assets/img/content/main/card.jpg','');
--,'26.01.2021', true, 311.46, 9,'','/assets/img/content/main/card.jpg','');
--,'01.03.2021', true, 791.08, 8,'','/assets/img/content/main/card.jpg','');
--,'11.02.2021', false, 399.5, 5,'','/assets/img/content/main/card.jpg','');
--,'05.05.2021', true, 739.62, 16,'','/assets/img/content/main/card.jpg','');
--,'15.01.2021', false, 561.69, 7,'','/assets/img/content/main/card.jpg','');
--,'23.11.2021', false, 786.81, 16,'','/assets/img/content/main/card.jpg','');
--,'04.08.2021', true, 230.74, 18,'','/assets/img/content/main/card.jpg','');
--,'23.10.2021', true, 755.75, 50,'','/assets/img/content/main/card.jpg','');
--,'16.06.2021', false, 870.39, 9,'','/assets/img/content/main/card.jpg','');
--,'05.06.2021', true, 476.38, 12,'','/assets/img/content/main/card.jpg','');
--,'20.05.2021', false, 257.5, 7,'','/assets/img/content/main/card.jpg','');
--,'15.05.2021', true, 719.31, 28,'','/assets/img/content/main/card.jpg','');
--,'31.07.2021', true, 415.46, 11,'','/assets/img/content/main/card.jpg','');
--,'04.11.2021', false, 739.14, 36,'','/assets/img/content/main/card.jpg','');
--,'10.01.2021', true, 875.5, 35,'','/assets/img/content/main/card.jpg','');
--,'11.10.2021', false, 884.48, 41,'','/assets/img/content/main/card.jpg','');
--,'27.11.2021', false, 673.8, 13,'','/assets/img/content/main/card.jpg','');
--,'10.01.2021', false, 673.86, 14,'','/assets/img/content/main/card.jpg','');
--,'24.01.2021', false, 712.97, 23,'','/assets/img/content/main/card.jpg','');
--,'23.12.2021', true, 909.57, 25,'','/assets/img/content/main/card.jpg','');
--,'25.08.2021', false, 511.36, 49,'','/assets/img/content/main/card.jpg','');
--,'04.10.2021', false, 236.6, 21,'','/assets/img/content/main/card.jpg','');
--,'12.03.2021', true, 261.8, 19,'','/assets/img/content/main/card.jpg','');
--,'29.04.2021', true, 915.58, 32,'','/assets/img/content/main/card.jpg','');
--,'27.06.2021', true, 859.85, 24,'','/assets/img/content/main/card.jpg','');
--,'22.08.2021', true, 355.35, 19,'','/assets/img/content/main/card.jpg','');
--,'20.11.2021', false, 462.28, 8,'','/assets/img/content/main/card.jpg','');
--,'15.02.2021', true, 866.22, 27,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', true, 957.76, 12,'','/assets/img/content/main/card.jpg','');
--,'29.06.2021', false, 417.46, 9,'','/assets/img/content/main/card.jpg','');
--,'27.06.2021', true, 903.9, 16,'','/assets/img/content/main/card.jpg','');
--,'15.07.2021', false, 434.74, 44,'','/assets/img/content/main/card.jpg','');
--,'03.01.2021', true, 303.85, 50,'','/assets/img/content/main/card.jpg','');
--,'15.07.2021', false, 208.74, 20,'','/assets/img/content/main/card.jpg','');
--,'19.06.2021', true, 786.99, 5,'','/assets/img/content/main/card.jpg','');
--,'30.05.2021', true, 865.65, 5,'','/assets/img/content/main/card.jpg','');
--,'16.09.2021', true, 588.54, 39,'','/assets/img/content/main/card.jpg','');
--,'23.09.2021', true, 999.23, 7,'','/assets/img/content/main/card.jpg','');
--,'22.02.2021', true, 736.72, 7,'','/assets/img/content/main/card.jpg','');
--,'02.09.2021', true, 740.32, 39,'','/assets/img/content/main/card.jpg','');
--,'10.07.2021', false, 211.86, 27,'','/assets/img/content/main/card.jpg','');
--,'04.05.2021', true, 680.69, 13,'','/assets/img/content/main/card.jpg','');
--,'16.01.2021', true, 956.55, 41,'','/assets/img/content/main/card.jpg','');
--,'28.11.2021', false, 216.31, 2,'','/assets/img/content/main/card.jpg','');
--,'24.05.2021', false, 609.53, 26,'','/assets/img/content/main/card.jpg','');
--,'02.10.2021', false, 689.96, 10,'','/assets/img/content/main/card.jpg','');
--,'06.05.2021', false, 274.47, 31,'','/assets/img/content/main/card.jpg','');
--,'04.04.2021', false, 445.88, 14,'','/assets/img/content/main/card.jpg','');
--,'03.12.2021', true, 792.54, 11,'','/assets/img/content/main/card.jpg','');
--,'20.08.2021', true, 336.42, 33,'','/assets/img/content/main/card.jpg','');
--,'30.05.2021', true, 313.3, 42,'','/assets/img/content/main/card.jpg','');
--,'27.10.2021', false, 576.57, 32,'','/assets/img/content/main/card.jpg','');
--,'15.07.2021', false, 391.06, 32,'','/assets/img/content/main/card.jpg','');
--,'15.10.2021', false, 995.73, 9,'','/assets/img/content/main/card.jpg','');
--,'04.04.2021', true, 267.9, 28,'','/assets/img/content/main/card.jpg','');
--,'09.01.2021', true, 819.88, 9,'','/assets/img/content/main/card.jpg','');
--,'12.03.2021', true, 305.5, 48,'','/assets/img/content/main/card.jpg','');
--,'30.08.2021', false, 497.0, 10,'','/assets/img/content/main/card.jpg','');
--,'31.03.2021', false, 405.71, 37,'','/assets/img/content/main/card.jpg','');
--,'07.05.2021', true, 807.12, 30,'','/assets/img/content/main/card.jpg','');
--,'28.04.2021', true, 732.47, 10,'','/assets/img/content/main/card.jpg','');
--,'28.06.2021', true, 580.3, 44,'','/assets/img/content/main/card.jpg','');
--,'14.12.2021', true, 747.6, 10,'','/assets/img/content/main/card.jpg','');
--,'20.01.2021', false, 307.79, 15,'','/assets/img/content/main/card.jpg','');
--,'30.01.2021', true, 787.24, 1,'','/assets/img/content/main/card.jpg','');
--,'07.10.2021', true, 418.55, 37,'','/assets/img/content/main/card.jpg','');
--,'26.10.2021', false, 544.88, 15,'','/assets/img/content/main/card.jpg','');
--,'25.04.2021', true, 401.83, 7,'','/assets/img/content/main/card.jpg','');
--,'18.04.2021', true, 212.64, 9,'','/assets/img/content/main/card.jpg','');
--,'16.07.2021', true, 629.22, 26,'','/assets/img/content/main/card.jpg','');
--,'22.10.2021', false, 857.66, 48,'','/assets/img/content/main/card.jpg','');
--,'10.07.2021', false, 553.8, 2,'','/assets/img/content/main/card.jpg','');
--,'01.05.2021', false, 292.32, 22,'','/assets/img/content/main/card.jpg','');
--,'13.09.2021', true, 570.88, 12,'','/assets/img/content/main/card.jpg','');
--,'29.11.2021', true, 288.16, 50,'','/assets/img/content/main/card.jpg','');
--,'11.09.2021', false, 727.47, 45,'','/assets/img/content/main/card.jpg','');
--,'05.11.2021', false, 594.49, 8,'','/assets/img/content/main/card.jpg','');
--,'14.08.2021', true, 305.58, 1,'','/assets/img/content/main/card.jpg','');
--,'24.07.2021', false, 980.61, 36,'','/assets/img/content/main/card.jpg','');
--,'07.05.2021', false, 575.41, 50,'','/assets/img/content/main/card.jpg','');
--,'12.08.2021', true, 319.9, 42,'','/assets/img/content/main/card.jpg','');
--,'21.07.2021', false, 216.67, 6,'','/assets/img/content/main/card.jpg','');
--,'23.11.2021', false, 760.5, 13,'','/assets/img/content/main/card.jpg','');
--,'26.07.2021', true, 571.02, 21,'','/assets/img/content/main/card.jpg','');
--,'12.03.2021', true, 881.46, 7,'','/assets/img/content/main/card.jpg','');
--,'31.07.2021', false, 793.01, 45,'','/assets/img/content/main/card.jpg','');
--,'25.02.2021', true, 821.53, 41,'','/assets/img/content/main/card.jpg','');
--,'25.10.2021', true, 795.01, 11,'','/assets/img/content/main/card.jpg','');
--,'03.02.2021', false, 232.08, 20,'','/assets/img/content/main/card.jpg','');
--,'14.10.2021', true, 494.17, 12,'','/assets/img/content/main/card.jpg','');
--,'12.05.2021', false, 966.32, 7,'','/assets/img/content/main/card.jpg','');
--,'07.07.2021', true, 863.98, 8,'','/assets/img/content/main/card.jpg','');
--,'10.04.2021', false, 576.04, 37,'','/assets/img/content/main/card.jpg','');
--,'07.12.2021', false, 441.98, 9,'','/assets/img/content/main/card.jpg','');
--,'19.07.2021', true, 223.69, 4,'','/assets/img/content/main/card.jpg','');
--,'08.09.2021', true, 569.05, 1,'','/assets/img/content/main/card.jpg','');
--,'03.04.2021', false, 978.25, 5,'','/assets/img/content/main/card.jpg','');
--,'20.12.2021', true, 256.06, 41,'','/assets/img/content/main/card.jpg','');
--,'12.10.2021', false, 204.72, 23,'','/assets/img/content/main/card.jpg','');
--,'01.07.2021', false, 780.75, 8,'','/assets/img/content/main/card.jpg','');
--,'28.11.2021', false, 818.89, 47,'','/assets/img/content/main/card.jpg','');
--,'13.12.2021', true, 635.97, 4,'','/assets/img/content/main/card.jpg','');
--,'05.06.2021', true, 878.17, 11,'','/assets/img/content/main/card.jpg','');
--,'08.06.2021', false, 201.17, 30,'','/assets/img/content/main/card.jpg','');
--,'06.06.2021', false, 519.48, 30,'','/assets/img/content/main/card.jpg','');
--,'01.06.2021', false, 391.78, 47,'','/assets/img/content/main/card.jpg','');
--,'23.05.2021', false, 568.9, 41,'','/assets/img/content/main/card.jpg','');
--,'12.05.2021', true, 264.44, 44,'','/assets/img/content/main/card.jpg','');
--,'18.03.2021', true, 790.82, 20,'','/assets/img/content/main/card.jpg','');
--,'28.01.2021', false, 470.22, 1,'','/assets/img/content/main/card.jpg','');
--,'04.11.2021', false, 664.42, 11,'','/assets/img/content/main/card.jpg','');
--,'17.08.2021', false, 278.21, 17,'','/assets/img/content/main/card.jpg','');
--,'08.05.2021', false, 690.79, 16,'','/assets/img/content/main/card.jpg','');
--,'25.08.2021', true, 492.22, 36,'','/assets/img/content/main/card.jpg','');
--,'14.02.2021', true, 470.37, 22,'','/assets/img/content/main/card.jpg','');
--,'15.06.2021', false, 968.98, 45,'','/assets/img/content/main/card.jpg','');
--,'27.04.2021', true, 533.48, 25,'','/assets/img/content/main/card.jpg','');
--,'25.10.2021', true, 242.15, 46,'','/assets/img/content/main/card.jpg','');
--,'27.07.2021', false, 847.89, 49,'','/assets/img/content/main/card.jpg','');
--,'06.09.2021', true, 481.03, 36,'','/assets/img/content/main/card.jpg','');
--,'25.07.2021', true, 546.2, 35,'','/assets/img/content/main/card.jpg','');
--,'01.08.2021', true, 697.1, 13,'','/assets/img/content/main/card.jpg','');
--,'25.05.2021', false, 845.82, 38,'','/assets/img/content/main/card.jpg','');
--,'01.10.2021', false, 870.03, 35,'','/assets/img/content/main/card.jpg','');
--,'24.11.2021', true, 393.6, 16,'','/assets/img/content/main/card.jpg','');
--,'07.03.2021', true, 850.16, 16,'','/assets/img/content/main/card.jpg','');
--,'19.11.2021', true, 308.73, 8,'','/assets/img/content/main/card.jpg','');
--,'05.08.2021', true, 278.66, 9,'','/assets/img/content/main/card.jpg','');
--,'30.05.2021', false, 904.26, 33,'','/assets/img/content/main/card.jpg','');
--,'20.07.2021', true, 629.63, 11,'','/assets/img/content/main/card.jpg','');
--,'18.05.2021', false, 530.58, 14,'','/assets/img/content/main/card.jpg','');
--,'29.11.2021', false, 681.7, 11,'','/assets/img/content/main/card.jpg','');
--,'05.04.2021', true, 770.14, 48,'','/assets/img/content/main/card.jpg','');
--,'27.12.2021', false, 377.33, 36,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', true, 453.64, 11,'','/assets/img/content/main/card.jpg','');
--,'27.05.2021', false, 330.36, 2,'','/assets/img/content/main/card.jpg','');
--,'24.12.2021', true, 419.28, 26,'','/assets/img/content/main/card.jpg','');
--,'23.12.2021', false, 373.66, 8,'','/assets/img/content/main/card.jpg','');
--,'25.08.2021', false, 326.96, 7,'','/assets/img/content/main/card.jpg','');
--,'19.01.2021', true, 592.34, 42,'','/assets/img/content/main/card.jpg','');
--,'25.09.2021', true, 288.65, 17,'','/assets/img/content/main/card.jpg','');
--,'22.11.2021', true, 240.09, 14,'','/assets/img/content/main/card.jpg','');
--,'12.05.2021', true, 258.18, 2,'','/assets/img/content/main/card.jpg','');
--,'28.10.2021', false, 771.07, 20,'','/assets/img/content/main/card.jpg','');
--,'04.12.2021', true, 413.13, 13,'','/assets/img/content/main/card.jpg','');
--,'17.10.2021', false, 880.26, 22,'','/assets/img/content/main/card.jpg','');
--,'03.05.2021', true, 329.71, 38,'','/assets/img/content/main/card.jpg','');
--,'03.10.2021', true, 953.9, 13,'','/assets/img/content/main/card.jpg','');
--,'13.01.2021', true, 227.13, 17,'','/assets/img/content/main/card.jpg','');
--,'17.10.2021', false, 864.68, 19,'','/assets/img/content/main/card.jpg','');
--,'03.06.2021', true, 413.93, 34,'','/assets/img/content/main/card.jpg','');
--,'21.04.2021', false, 556.89, 4,'','/assets/img/content/main/card.jpg','');
--,'12.11.2021', true, 228.19, 50,'','/assets/img/content/main/card.jpg','');
--,'20.08.2021', false, 811.08, 10,'','/assets/img/content/main/card.jpg','');
--,'10.05.2021', true, 528.9, 14,'','/assets/img/content/main/card.jpg','');
--,'24.07.2021', false, 700.53, 32,'','/assets/img/content/main/card.jpg','');
--,'24.11.2021', false, 464.46, 21,'','/assets/img/content/main/card.jpg','');
--,'06.07.2021', true, 483.4, 35,'','/assets/img/content/main/card.jpg','');
--,'27.06.2021', true, 612.41, 41,'','/assets/img/content/main/card.jpg','');
--,'16.01.2021', true, 651.06, 16,'','/assets/img/content/main/card.jpg','');
--,'05.09.2021', true, 896.85, 37,'','/assets/img/content/main/card.jpg','');
--,'12.04.2021', false, 327.32, 48,'','/assets/img/content/main/card.jpg','');
--,'25.05.2021', false, 213.67, 7,'','/assets/img/content/main/card.jpg','');
--,'27.09.2021', true, 489.11, 10,'','/assets/img/content/main/card.jpg','');
--,'28.11.2021', false, 983.18, 37,'','/assets/img/content/main/card.jpg','');
--,'10.07.2021', true, 684.57, 28,'','/assets/img/content/main/card.jpg','');
--,'23.12.2021', false, 572.48, 9,'','/assets/img/content/main/card.jpg','');
--,'06.12.2021', true, 638.78, 4,'','/assets/img/content/main/card.jpg','');
--,'19.03.2021', true, 499.34, 8,'','/assets/img/content/main/card.jpg','');
--,'21.01.2021', true, 767.64, 39,'','/assets/img/content/main/card.jpg','');
--,'18.08.2021', false, 233.88, 24,'','/assets/img/content/main/card.jpg','');
--,'12.10.2021', true, 240.48, 8,'','/assets/img/content/main/card.jpg','');
--,'24.09.2021', false, 319.46, 3,'','/assets/img/content/main/card.jpg','');
--,'06.11.2021', true, 214.85, 23,'','/assets/img/content/main/card.jpg','');
--,'13.01.2021', false, 944.92, 6,'','/assets/img/content/main/card.jpg','');
--,'19.12.2021', false, 889.43, 21,'','/assets/img/content/main/card.jpg','');
--,'22.07.2021', false, 290.43, 3,'','/assets/img/content/main/card.jpg','');
--,'17.01.2021', true, 208.12, 12,'','/assets/img/content/main/card.jpg','');
--,'12.12.2021', true, 629.63, 2,'','/assets/img/content/main/card.jpg','');
--,'17.07.2021', false, 206.27, 25,'','/assets/img/content/main/card.jpg','');
--,'08.10.2021', true, 888.97, 11,'','/assets/img/content/main/card.jpg','');
--,'18.05.2021', true, 861.98, 11,'','/assets/img/content/main/card.jpg','');
--,'06.10.2021', true, 352.34, 28,'','/assets/img/content/main/card.jpg','');
--,'30.06.2021', false, 214.92, 25,'','/assets/img/content/main/card.jpg','');
--,'09.01.2021', false, 910.03, 47,'','/assets/img/content/main/card.jpg','');
--,'24.04.2021', false, 365.33, 16,'','/assets/img/content/main/card.jpg','');
--,'31.05.2021', false, 904.48, 38,'','/assets/img/content/main/card.jpg','');
--,'21.05.2021', false, 428.39, 47,'','/assets/img/content/main/card.jpg','');
--,'27.03.2021', true, 679.32, 17,'','/assets/img/content/main/card.jpg','');
--,'26.08.2021', false, 966.97, 19,'','/assets/img/content/main/card.jpg','');
--,'15.06.2021', false, 852.88, 44,'','/assets/img/content/main/card.jpg','');
--,'29.06.2021', false, 867.09, 26,'','/assets/img/content/main/card.jpg','');
--,'09.08.2021', true, 697.97, 2,'','/assets/img/content/main/card.jpg','');
--,'21.10.2021', false, 336.42, 9,'','/assets/img/content/main/card.jpg','');
--,'07.06.2021', false, 404.97, 19,'','/assets/img/content/main/card.jpg','');
--,'15.05.2021', true, 428.15, 27,'','/assets/img/content/main/card.jpg','');
--,'28.10.2021', true, 913.67, 8,'','/assets/img/content/main/card.jpg','');
--,'25.02.2021', true, 605.63, 25,'','/assets/img/content/main/card.jpg','');
--,'19.07.2021', false, 800.18, 42,'','/assets/img/content/main/card.jpg','');
--,'27.06.2021', true, 213.71, 43,'','/assets/img/content/main/card.jpg','');
--,'05.12.2021', false, 259.12, 27,'','/assets/img/content/main/card.jpg','');
--,'09.03.2021', true, 729.22, 37,'','/assets/img/content/main/card.jpg','');
--,'07.12.2021', true, 542.35, 7,'','/assets/img/content/main/card.jpg','');
--,'22.11.2021', false, 525.23, 49,'','/assets/img/content/main/card.jpg','');
--,'26.07.2021', false, 288.85, 37,'','/assets/img/content/main/card.jpg','');
--,'20.03.2021', true, 411.54, 9,'','/assets/img/content/main/card.jpg','');
--,'22.07.2021', false, 371.14, 14,'','/assets/img/content/main/card.jpg','');
--,'21.05.2021', false, 421.84, 43,'','/assets/img/content/main/card.jpg','');
--,'30.06.2021', true, 442.71, 14,'','/assets/img/content/main/card.jpg','');
--,'19.06.2021', false, 856.26, 7,'','/assets/img/content/main/card.jpg','');
--,'28.01.2021', false, 212.99, 39,'','/assets/img/content/main/card.jpg','');
--,'11.11.2021', true, 596.33, 3,'','/assets/img/content/main/card.jpg','');
--,'12.12.2021', true, 501.32, 40,'','/assets/img/content/main/card.jpg','');
--,'18.08.2021', false, 272.9, 10,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', false, 204.84, 5,'','/assets/img/content/main/card.jpg','');
--,'20.04.2021', true, 755.81, 29,'','/assets/img/content/main/card.jpg','');
--,'14.05.2021', false, 605.74, 48,'','/assets/img/content/main/card.jpg','');
--,'16.08.2021', false, 591.63, 11,'','/assets/img/content/main/card.jpg','');
--,'05.12.2021', true, 456.23, 5,'','/assets/img/content/main/card.jpg','');
--,'17.01.2021', false, 622.71, 48,'','/assets/img/content/main/card.jpg','');
--,'17.10.2021', false, 775.04, 33,'','/assets/img/content/main/card.jpg','');
--,'24.03.2021', false, 865.56, 24,'','/assets/img/content/main/card.jpg','');
--,'17.04.2021', true, 516.24, 47,'','/assets/img/content/main/card.jpg','');
--,'17.10.2021', true, 778.08, 43,'','/assets/img/content/main/card.jpg','');
--,'26.02.2021', false, 508.0, 22,'','/assets/img/content/main/card.jpg','');
--,'18.10.2021', false, 895.29, 29,'','/assets/img/content/main/card.jpg','');
--,'14.09.2021', true, 592.0, 8,'','/assets/img/content/main/card.jpg','');
--,'26.07.2021', true, 980.04, 7,'','/assets/img/content/main/card.jpg','');
--,'20.08.2021', true, 373.92, 38,'','/assets/img/content/main/card.jpg','');
--,'28.04.2021', true, 543.28, 2,'','/assets/img/content/main/card.jpg','');
--,'08.08.2021', true, 833.21, 31,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', true, 602.91, 44,'','/assets/img/content/main/card.jpg','');
--,'10.05.2021', true, 875.5, 18,'','/assets/img/content/main/card.jpg','');
--,'25.11.2021', true, 740.8, 31,'','/assets/img/content/main/card.jpg','');
--,'31.08.2021', false, 979.03, 13,'','/assets/img/content/main/card.jpg','');
--,'06.06.2021', false, 660.75, 18,'','/assets/img/content/main/card.jpg','');
--,'23.05.2021', true, 533.8, 43,'','/assets/img/content/main/card.jpg','');
--,'11.04.2021', false, 877.98, 4,'','/assets/img/content/main/card.jpg','');
--,'04.02.2021', false, 545.5, 5,'','/assets/img/content/main/card.jpg','');
--,'18.05.2021', true, 425.27, 5,'','/assets/img/content/main/card.jpg','');
--,'23.02.2021', true, 473.93, 41,'','/assets/img/content/main/card.jpg','');
--,'24.04.2021', true, 615.02, 30,'','/assets/img/content/main/card.jpg','');
--,'06.02.2021', false, 438.97, 10,'','/assets/img/content/main/card.jpg','');
--,'01.07.2021', false, 444.44, 7,'','/assets/img/content/main/card.jpg','');
--,'29.10.2021', true, 762.2, 32,'','/assets/img/content/main/card.jpg','');
--,'12.05.2021', true, 971.03, 5,'','/assets/img/content/main/card.jpg','');
--,'05.01.2021', false, 577.79, 49,'','/assets/img/content/main/card.jpg','');
--,'20.05.2021', false, 333.91, 16,'','/assets/img/content/main/card.jpg','');
--,'10.11.2021', false, 654.84, 14,'','/assets/img/content/main/card.jpg','');
--,'10.09.2021', false, 913.89, 29,'','/assets/img/content/main/card.jpg','');
--,'06.12.2021', true, 553.96, 27,'','/assets/img/content/main/card.jpg','');
--,'13.04.2021', false, 837.0, 15,'','/assets/img/content/main/card.jpg','');
--,'03.09.2021', true, 642.18, 4,'','/assets/img/content/main/card.jpg','');
--,'02.10.2021', true, 414.04, 13,'','/assets/img/content/main/card.jpg','');
--,'19.09.2021', false, 420.52, 47,'','/assets/img/content/main/card.jpg','');
--,'09.10.2021', true, 367.27, 10,'','/assets/img/content/main/card.jpg','');
--,'20.02.2021', false, 386.94, 9,'','/assets/img/content/main/card.jpg','');
--,'28.12.2021', true, 685.1, 37,'','/assets/img/content/main/card.jpg','');
--,'28.07.2021', true, 592.48, 42,'','/assets/img/content/main/card.jpg','');
--,'04.01.2021', true, 356.28, 46,'','/assets/img/content/main/card.jpg','');
--,'16.11.2021', false, 617.27, 6,'','/assets/img/content/main/card.jpg','');
--,'17.02.2021', false, 412.83, 46,'','/assets/img/content/main/card.jpg','');
--,'11.09.2021', false, 502.56, 17,'','/assets/img/content/main/card.jpg','');
--,'20.07.2021', false, 704.34, 13,'','/assets/img/content/main/card.jpg','');







