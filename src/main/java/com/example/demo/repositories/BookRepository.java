package com.example.demo.repositories;

import com.example.demo.entity.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Date;
import java.util.List;

public interface BookRepository extends JpaRepository<Book, Integer> {

    List<Book> findBooksByPubDateAfter(Date recentDate);

    List<Book> findBooksByAuthorFioContaining(String author);

    @Query("from Book where bestseller = true")
    List<Book> getBestsellers();

    @Query(value="select * from books where discount > 30", nativeQuery=true)
    List<Book> getDiscount();
}
