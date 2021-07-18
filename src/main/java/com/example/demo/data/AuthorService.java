package com.example.demo.data;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.sql.ResultSet;

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

}
