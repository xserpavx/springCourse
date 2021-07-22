package com.example.demo.services;
import com.example.demo.entity.*;
import com.example.demo.repositories.AuthorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Map;

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

    public Map<String, ArrayList<Author>> getAuthors() {
        return authorRepository.getAuthors();
    }
}
