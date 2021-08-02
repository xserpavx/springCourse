package com.example.demo.services;

import com.example.demo.entity.Genre;
import com.example.demo.repositories.GenreRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Created on 02.08.2021
 *
 * @author roland
 **/
@Service
public class GenreService {
    private final GenreRepository genreRepository;
//    private final List<Integer> root;
//    private final Map<Integer, List<Integer>> nodes;

    @Autowired
    public GenreService(GenreRepository genreRepository) {
        this.genreRepository = genreRepository;
    }

//    public List<Genre> getRootNodes() {
//        return genreRepository.findGenreById_parentNull();
//    }

//    public List<Genre> getChildNodes() {
//        return genreRepository.findGenreById_parentNotNull();
//    }

    public List<Genre> getGenres() {
        return genreRepository.findAll();
    }
}
