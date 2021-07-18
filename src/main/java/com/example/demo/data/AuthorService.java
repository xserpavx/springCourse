package com.example.demo.data;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.sql.ResultSet;
import java.util.List;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Service
public class AuthorService {
    private final JdbcTemplate db;

    @Autowired
    public AuthorService(JdbcTemplate db) {
        this.db = db;
    }

    public ArrayList<String> getAuthorsLetter() {
        List<String> letters = db.query("select distinct substring(fio from 1 for 1) letter from authors", (ResultSet sqlResult, int rowNum) -> {
            return sqlResult.getString("letter");
        });
        return new ArrayList<>(letters);
    }

    public ArrayList<LetterAuthors> getAuthors() {
        Letter letter = new Letter();
        db.query("select fio from authors where id > 0 order by fio", (ResultSet sqlResult, int rowNum) -> {
            Author author = new Author();
            author.setFio(sqlResult.getString("fio"));
            letter.addAuthor(author);
            return letter;
        });
        return letter.getLetterAuthors();

    }

//    public List<Book> getBooks() {
//        List<Book> books = db.query("select books.*, fio from books left outer join authors on authors.id = books.id_author", (ResultSet sqlResult, int row) -> {
//            Book book = new Book();
//            book.setId(sqlResult.getInt("id"));
//            book.setAuthor(sqlResult.getString("fio"));
//            book.setPrice(sqlResult.getString("price"));
//            book.setPriceOld(sqlResult.getString("priceold"));
//            book.setTitle(sqlResult.getString("title"));
//            return book;
//        });
//        return new ArrayList<>(books);
//    }
}
