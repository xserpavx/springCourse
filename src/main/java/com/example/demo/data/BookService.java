package com.example.demo.data;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.sql.ResultSet;


/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Service
public class BookService {

    private final JdbcTemplate db;

    @Autowired
    public BookService(JdbcTemplate db) {
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
