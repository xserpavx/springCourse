package com.example.demo.repositories;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.Author;
import com.example.demo.entity.LetterAuthors;


import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created on 19.07.2021
 *
 * @author roland
 **/
@Repository
public class AuthorRepository {
    private final static Logger log = LoggerFactory.getLogger(AuthorRepository.class);

    private final JdbcTemplate db;
    private HashMap<String, ArrayList<Author>> letters;

    @Autowired
    public AuthorRepository(JdbcTemplate db) {
        this.db = db;
        letters = new HashMap<>();
    }

    public ArrayList<LetterAuthors> getAuthors() {
        db.query("select fio from authors where id > 0 order by fio", (ResultSet sqlResult, int rowNum) -> {
            Author author = new Author();
            author.setFio(sqlResult.getString("fio"));
            addAuthor(author);
            return null;
        });
        return getLetterAuthors();
    }

    private void addAuthor(Author author) {
        ArrayList<Author> authors = letters.get(author.getLetter());
        if (authors == null) {
            authors = new ArrayList<>();
            letters.put(author.getLetter(), authors);
        }
        authors.add(author);
    }

    private ArrayList<LetterAuthors> getLetterAuthors() {
        ArrayList<LetterAuthors> arrayLetterAuthors = new ArrayList<LetterAuthors>();
        for (String letter : letters.keySet()) {
            LetterAuthors letterAuthors = new LetterAuthors();
            letterAuthors.setLetter(letter);
            letterAuthors.setAuthors(letters.get(letter));
            arrayLetterAuthors.add(letterAuthors);
        }
        return arrayLetterAuthors;
    }
}
