package com.example.demo.repositories;

import com.example.demo.entity.Genre;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GenreRepository extends JpaRepository<Genre, Integer> {

    List<Genre> findBySlugEquals(String slug);
}
