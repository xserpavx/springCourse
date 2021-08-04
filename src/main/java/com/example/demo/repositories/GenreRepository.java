package com.example.demo.repositories;

import com.example.demo.entity.Book;
import com.example.demo.entity.Genre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface GenreRepository extends JpaRepository<Genre, Integer> {

//    List<Genre> findGenreById_parentNull();

//    List<Genre> findAllByIdOrd();

      List<Genre> findBySlugEquals(String slug);


}
