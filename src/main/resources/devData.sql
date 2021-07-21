insert into authors(id, fio) values (0, 'Автор неизвестен');
insert into authors(id,fio) values (1, 'Артур Конан Дойль');
insert into authors(id,fio) values (2, 'О. Генри');
insert into authors(id,fio) values (3, 'Жюль Верн');
insert into authors(id,fio) values (4, 'Дж.Р.Р. Толкиен');
insert into authors(id,fio) values (5, 'Борис Заходер');
insert into authors(id,fio) values (6, 'Станислав Лем');
insert into authors(id,fio) values (7, 'Жорж Симеон');
insert into authors(id,fio) values (8, 'Алистер Маклин');
insert into authors(id,fio) values (9, 'Андрэ Нортон');
insert into authors(id,fio) values (10, 'Вальтер Скотт');
insert into authors(id,fio) values (11, 'Фенимор Купер');
insert into authors(id,fio) values (12, 'Туве Яннсен');
insert into authors(id,fio) values (13, 'Майн Рид');

insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount)
values ('Приключения Шерлока Холмса', 1, '2001-01-01', 1, '','','', 300.0, 10);
insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) 
values ('Записки о Шерлоке Холмсе', 1, '2001-02-01', 1, '','','', 300.0, 5);
insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) 
values ('Этюд в багровых тонах', 1, '2001-03-01', 1, '','','', 300.0, 0);
insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) 
values ('Собака Баскервилей', 1, '2001-04-01', 1, '','','', 300.0, 10);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Короли и капуста', 2);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Благородный Жулик', 2);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Горящий светильник', 2);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Дороги судьбы', 2);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Деловые люди', 2);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Дети капитана Гранта', 3);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('20 тысяч лье под водой', 3);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Таинственный остров', 3);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Хоббит или туда и обратно', 4);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Братство кольца', 4);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Две твердыни', 4);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Возвращение короля', 4);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('А.Милн. Винни Пух и Все-Все-Все', 5);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Л.Кэррол. Алиса в стране чудес', 5);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Рассказы о пилоте Пирксе', 6);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Звездные дневники Йона Тихого', 6);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Солярис', 6);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Маньяк из Бержерака', 7);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Тайна перекрестка «Трех вдов»', 7);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Висельник из Сен-Фольена', 7);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Золотое рандеву', 8);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Полярная станция зебра', 8);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Пушки острова Наваррон', 8);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('10 баллов с острова Наваррон', 8);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Саргассы в космосе', 9);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Зачумленный корабль', 9);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Проштемпелевано звездами', 9);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Айвенго', 10);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Последний из могикан', 11);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Зверобой', 11);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Мумми Тролль и комета', 12);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Всадник без головы', 13);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Затерянные в океане', 13);
-- insert into books (title, id_author, pub_date, is_bestseller, slug, image, description, price, discount) values ('Белый вождь', 13);








