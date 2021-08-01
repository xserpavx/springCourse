package com.example.demo.services;
import com.example.demo.entity.*;
import com.example.demo.repositories.AuthorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Service
public class AuthorService {
    private final AuthorRepository authorRepository;

    private Map<String, ArrayList<Author>> authors;

    @Autowired
    public AuthorService(AuthorRepository authorRepository) {
        this.authorRepository = authorRepository;
        authors = new TreeMap<>();
    }

    private void addAuthor(Author author) {
        ArrayList<Author> authorsList = authors.get(author.getLetter());
        if (authorsList == null) {
            authorsList = new ArrayList<>();
            authors.put(author.getLetter(), authorsList);
        }
        authorsList.add(author);
    }

    public Map<String, ArrayList<Author>> getAuthors() {
        authors.clear();
        List<Author> authorsList = authorRepository.findAll();
        for (Author author : authorsList) {
            addAuthor(author);
        }
        return authors;
    }

    public List<Author> getAuthorById(Integer id) {
        return authorRepository.findAuthorByIdEquals(id);
    }
}
