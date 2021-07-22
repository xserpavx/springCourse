DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;

CREATE TABLE authors(
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        fio VARCHAR(255) NOT NULL
);

CREATE TABLE  books(
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       id_author INT NOT NULL,
                       pub_date DATE NOT NULL,
                       is_bestseller SMALLINT NOT NULL,
                       slug VARCHAR(255) NOT NULL,
                       title VARCHAR(250) NOT NULL,
                       image VARCHAR(255),
                       description TEXT,
                       price FLOAT NOT NULL,
                       discount SMALLINT NOT NULL DEFAULT 0,
                       FOREIGN KEY (id_author) references authors(id)
);

CREATE TABLE book2author(
                            id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                            book_id INT NOT NULL,
                            author_id INT NOT NULL,
                            sort_index INT NOT NULL DEFAULT 0
)
