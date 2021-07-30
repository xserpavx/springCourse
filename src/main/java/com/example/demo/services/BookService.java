package com.example.demo.services;

import com.example.demo.entity.Book;
import com.example.demo.repositories.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
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

    public List<Book> getRecentBooks() {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.YEAR, -2);
        return bookRepository.findBooksByPubDateAfter(cal.getTime());
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


}
