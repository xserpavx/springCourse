package com.example.demo.repositories;

import com.example.demo.entity.Book;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Created on 19.07.2021
 *
 * @author roland
 **/
@Repository
public class BookRepository {
    private final static Logger log = LoggerFactory.getLogger(BookRepository.class);
    private final JdbcTemplate db;

    public BookRepository(JdbcTemplate db) {
        this.db = db;
    }

    public List<Book> getBooks() {
        List<Book> books = db.query("select books.*, fio from books left outer join authors on authors.id = books.id_author", (ResultSet sqlResult, int row) -> {
            Book book = new Book();
            book.setId(sqlResult.getInt("id"));
            book.setAuthor(sqlResult.getString("fio"));
            book.setPrice(sqlResult.getString("price"));
            book.setPriceOld(sqlResult.getString("priceold"));
            book.setTitle(sqlResult.getString("title"));
            return book;
        });
        return new ArrayList<>(books);
    }
}