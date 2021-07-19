package com.example.demo.services;
import com.example.demo.entity.*;
import com.example.demo.repositories.AuthorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

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

    public ArrayList<LetterAuthors> getAuthors() {
        return authorRepository.getAuthors();
    }
}
