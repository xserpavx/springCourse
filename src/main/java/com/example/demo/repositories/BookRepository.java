package com.example.demo.repositories;

import com.example.demo.entity.Book;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import java.util.Date;
import java.util.List;

public interface BookRepository extends JpaRepository<Book, Integer>, PagingAndSortingRepository<Book, Integer> {

    List<Book> findBookByOrderByPubDateDesc();
    Page<Book> findBookByOrderByPubDateDesc(Pageable pageable);

    Page<Book> findBookByPubDateBetweenOrderByPubDateDesc(Date from, Date to, Pageable pageable);


    Page<Book> findBooksByPubDateAfter(Date recentDate, Pageable pageable);
    List<Book> findBooksByPubDateAfter(Date recentDate);

    List<Book> findBooksByAuthorNameContaining(String author);

    @Query("from Book where bestseller = true")
    List<Book> getBestsellers();

    @Query(value="select * from books where discount > 30", nativeQuery=true)
    List<Book> getDiscount();

    @Query(value="select b.* from book2tag left outer join books b on b.id = book2tag.id_book left outer join tags on tags.id = book2tag.id_tag where tag_name = ?1", nativeQuery = true)
    Page<Book> getBooksByTag(String tag_name, Pageable pageable);
}
