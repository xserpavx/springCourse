package com.example.demo.repositories;

import com.example.demo.entity.Book;
import com.example.demo.entity.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import java.util.Date;
import java.util.List;

public interface BookRepository extends JpaRepository<Book, Integer>, PagingAndSortingRepository<Book, Integer> {



    public static enum BookUserTypes {EMPTY, KEPT, CART, PAID, ARCHIVED}

    List<Book> findBookByOrderByPubDateDesc();

    Page<Book> findBookByOrderByPubDateDesc(Pageable pageable);

    Page<Book> findBookByPubDateBetweenOrderByPubDateDesc(Date from, Date to, Pageable pageable);

    Page<Book> findBookByOrderByPopularDesc(Pageable pageable);

    Page<Book> findBookByOrderByRatingDesc(Pageable pageable);

    List<Book> findBookBySlugEquals(String bookSlug);

    List<Book> findBookBySlugIn(String[] bookSlugs);

    Page<Book> findBooksByPubDateAfter(Date recentDate, Pageable pageable);

    List<Book> findBooksByPubDateAfter(Date recentDate);

    @Query(value = "select b.* from book2author b2a left outer join authors a on b2a.id_author = a.id left outer join books b on b2a.id_book = b.id where a.name ~ ?1", nativeQuery = true)
    List<Book> getBooksByAuthorNamePart(String authorNamePart);

    @Query("from Book where bestseller = true")
    List<Book> getBestsellers();

    @Query(value = "select * from books where discount > 30", nativeQuery = true)
    List<Book> getDiscount();

    @Query(value = "select b.* from book2tag left outer join books b on b.id = book2tag.id_book left outer join tags on tags.id = book2tag.id_tag where tag_name = ?1", nativeQuery = true)
    Page<Book> getBooksByTag(String tag_name, Pageable pageable);

    @Query(value = "select t.* from book2tag b2t left outer join tags t on b2t.id_tag = t.id where id_book = ?1", nativeQuery = true)
    List<Tag> getTagsOfBook(int id_book);

    @Query(value = "select b.* from genres g left outer join book2genre b2g on b2g.id_genre = g.id left outer join books b on b2g.id_book = b.id where g.slug = ?1", nativeQuery = true)
    Page<Book> getBooksByGenre(String slug, Pageable pageable);

    @Query(value = "select b.* from authors a left outer join books b on a.id = b.id_author where a.slug = ?1", nativeQuery = true)
    Page<Book> getBooksBySlugAuthor(String slug, Pageable pageable);

    @Query(value = "select count(id) from book_user_rating where id_book = ?1", nativeQuery = true)
    Integer getBookRateCount(int id);

    @Query(value = "select count(id) cnt from book_user_rating but where id_book = ?1 and rate = ?2", nativeQuery = true)
    Integer getRateCountByRateValue(int id_book, int rate);

    Page<Book> findBooksByTitleIn(String[] titles, Pageable pageable);

    Page<Book> findBooksByTitleContainingIgnoreCase(String title, Pageable pageable);
    List<Book> findBooksByTitleContainingIgnoreCase(String title);
}
