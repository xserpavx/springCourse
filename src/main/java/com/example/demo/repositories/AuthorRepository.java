package com.example.demo.repositories;

import com.example.demo.entity.Author;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


public interface AuthorRepository extends JpaRepository<Author, Integer> {

    List<Author> findAuthorByNameEquals(String name);

    List<Author> findAuthorByIdEquals(Integer id);

    List<Author> findAuthorBySlugEquals(String slug);

}
