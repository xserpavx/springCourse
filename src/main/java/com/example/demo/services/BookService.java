package com.example.demo.services;

import com.example.demo.entity.Book;
import com.example.demo.repositories.BookRepository;
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

    @Autowired
    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
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

}
