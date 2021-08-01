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



    public List<Book> getPopularBooks() {
        return bookRepository.findAll();
    }

    public Page<Book> getPagePopularBooks(Integer offset, Integer limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.findAll(nextPage);
    }

    public List<Book> getBooksByAuthor(String author) {
        return bookRepository.findBooksByAuthorFioContaining(author);
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

}
