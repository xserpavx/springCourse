package com.example.demo.repositories;

import com.example.demo.entity.BookReviewLike;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookReviewLikeRepository extends JpaRepository<BookReviewLike, Integer> {
    BookReviewLike findByIdEquals(Integer id);

    BookReviewLike findByIdReviewAndIdUser(Integer idReview, Integer idUser);
}
