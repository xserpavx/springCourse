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

    @Autowired
    public AuthorService(AuthorRepository authorRepository) {
        this.authorRepository = authorRepository;
    }

    public Map<String, List<Author>> getAuthors() {
        Map<String, List<Author>> authors = new TreeMap<>();
        List<Author> authorsList = authorRepository.findAll();
        for (Author author : authorsList) {
            List<Author> letterAuthorList = authors.computeIfAbsent(author.getLetter(), key -> new ArrayList<>());
            letterAuthorList.add(author);
        }
        return authors;
    }
}
