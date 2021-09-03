package com.example.demo.repositories;

import com.example.demo.entity.BookReview;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookReviewRepository extends JpaRepository<BookReview, Integer> {
    BookReview findByIdEquals(Integer id);
}
