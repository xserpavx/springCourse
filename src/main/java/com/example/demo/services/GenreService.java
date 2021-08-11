package com.example.demo.services;

import com.example.demo.entity.Book;
import com.example.demo.entity.Genre;
import com.example.demo.repositories.BookRepository;
import com.example.demo.repositories.GenreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created on 02.08.2021
 *
 * @author roland
 **/
@Service
public class GenreService {
    private final GenreRepository genreRepository;
    private final BookRepository bookRepository;

    @Autowired
    public GenreService(GenreRepository genreRepository, BookRepository bookRepository) {
        this.genreRepository = genreRepository;
        this.bookRepository = bookRepository;
    }

    public List<Genre> getGenres() {
        return genreRepository.findAll();
    }

    public Genre getGenreBySlug(String slug) {
        List<Genre> search = genreRepository.findBySlugEquals(slug);
        if (search != null) {
            return search.get(0);
        }
        //FIXME ничего страшного нет, но не самая лучшая практика null кидать
        return null;
    }

    public Page<Book> getPageBooksBySlug(String slug, int offset, int limit) {
        Pageable nextPage = PageRequest.of(offset, limit);
        return bookRepository.getBooksByGenre(slug, nextPage);
    }
}
