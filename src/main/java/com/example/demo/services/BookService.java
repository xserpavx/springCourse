package com.example.demo.services;

import com.example.demo.entity.Book;
import com.example.demo.entity.Tag;
import com.example.demo.repositories.BookRepository;
import com.example.demo.repositories.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Service
public class BookService {

    private final BookRepository bookRepository;
    private final TagRepository tagRepository;

    @Autowired
    public BookService(BookRepository bookRepository, TagRepository tagRepository) {
        this.bookRepository = bookRepository;
        this.tagRepository = tagRepository;
    }

    public List<Book> getRecomendBooks() {
        return bookRepository.findAll();
    }

    private Date getLowRecentDate() {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.YEAR, -2);
        return cal.getTime();
    }

    public Page<Book> getPagePopularBooks(Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.findBookByOrderByPopularDesc(nextPage);
    }

    public List<Book> getBooksByAuthor(String author) {
        return bookRepository.findBooksByAuthorNameContaining(author);
    }

    public List<Book> getHQuery() {
        return bookRepository.getBestsellers();
    }

    public List<Book> getNativeQuery() {
        return bookRepository.getDiscount();
    }

    public Page<Book> getPageAllBooks(Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.findAll(nextPage);
    }

    public List<Book> getRecentBooks() {
        return bookRepository.findBookByOrderByPubDateDesc();
    }

    public Page<Book> getPageRecentBooks(Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.findBookByOrderByPubDateDesc(nextPage);
    }

    public Page<Book> getPageRecentBooksByDate(Date from, Date to, Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.findBookByPubDateBetweenOrderByPubDateDesc(from, to, nextPage);
    }

    public List<Tag> getAllTags() {
        return tagRepository.findAll();
    }

    public int getMaxTag() {
        return tagRepository.maxTagCount();
    }

    public List<Book> getBooksByTag(Integer id) {
        Tag tag = tagRepository.findTagById(id);
        return new ArrayList<>(tag.getTaggedBooks());
    }

    public Page<Book> getPageBooksByTag(String tag_name, Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.getBooksByTag(tag_name, nextPage);
    }

    public Page<Book> getPageBooksBySlugAuthor(String slug, Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.getBooksBySlugAuthor(slug, nextPage);
    }

    public Page<Book> getPageBooksByGenre(String genreSlug, Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.getBooksByGenre(genreSlug, nextPage);
    }

    public List<Book> getBookByTitleContain(String title) {
        return new ArrayList<>(bookRepository.findBooksByTitleContainingIgnoreCase(title));
    }

    public Page<Book> getPageBookByTitleContain(String title, Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.findBooksByTitleContainingIgnoreCase(title, nextPage);
    }

    public List<Book> getBookBySlug(String bookSlug) {
        return bookRepository.findBookBySlugEquals(bookSlug);
    }

    public List<Book> getBooksBySlug(String[] booksSlug) {
        return bookRepository.findBookBySlugIn(booksSlug);
    }
}
