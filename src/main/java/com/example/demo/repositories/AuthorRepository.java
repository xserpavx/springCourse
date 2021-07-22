package com.example.demo.repositories;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.Author;


import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Map;
import java.util.TreeMap;

/**
 * Created on 19.07.2021
 *
 * @author roland
 **/
@Repository
public class AuthorRepository {

    private final JdbcTemplate db;
    private TreeMap<String, ArrayList<Author>> authors;

    @Autowired
    public AuthorRepository(JdbcTemplate db) {
        this.db = db;
        authors = new TreeMap<>();
    }

    public Map<String, ArrayList<Author>> getAuthors() {
        authors.clear();
        db.query("select fio from authors where id > 0 order by fio", (ResultSet sqlResult, int rowNum) -> {
            Author author = new Author();
            author.setFio(sqlResult.getString("fio"));
            addAuthor(author);
            return null;
        });
        return authors;
    }

    private void addAuthor(Author author) {
        ArrayList<Author> authorsList = authors.get(author.getLetter());
        if (authorsList == null) {
            authorsList = new ArrayList<>();
            authors.put(author.getLetter(), authorsList);
        }
        authorsList.add(author);
    }
}
