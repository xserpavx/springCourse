package com.example.demo.services;

import com.example.demo.entity.Book;
import com.example.demo.repositories.BookRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class BookServiceTest {

    private final BookRepository bookRepository;
    private final BookService bookService;

    @Autowired
    public BookServiceTest(BookRepository bookRepository, BookService bookService) {
        this.bookRepository = bookRepository;
        this.bookService = bookService;
    }

    /**
     * Проверяем правильность расчета популярности книги
     */
    @Test
    public void bookPopularTest() {
        // Определяем значение популярности книги по формуле: B + 0,7*C + 0,4*K

        // Выбираем книгу для котороый определяем рейтинг
        List<Book> books = bookRepository.findAll();
        assertEquals(false, books.isEmpty(), "List books is empty!");

        // Считаем рейтинг по данным в БД
        float rating = (float) 0.4 * bookRepository.getCountBooksByIdAndUserType(books.get(0).getId(), BookRepository.BookUserTypes.KEPT.ordinal())
                + (float) 0.7 * bookRepository.getCountBooksByIdAndUserType(books.get(0).getId(), BookRepository.BookUserTypes.CART.ordinal())
                + bookRepository.getCountBooksByIdAndUserType(books.get(0).getId(), BookRepository.BookUserTypes.PAID.ordinal());

        assertEquals(rating, books.get(0).getPopular(), String.format("Popular for book with id = %d from database is different with calc value", books.get(0).getId()));
    }

    /**
     * Проверяем правильность расчета пользовательского рейтинга книги
     */
    @Test
    public void bookRatingTest() {
        // Выбираем книгу для котороый определяем рейтинг
        List<Book> books = bookRepository.findAll();
        assertEquals(false, books.isEmpty(), "List books is empty!");
        int count = 0;
        int sum = 0;
        for (int i = 1; i <=5; i++) {
            int valCount = bookRepository.getRateCountByRateValue(books.get(0).getId(), i);
            sum += i * valCount;
            count += valCount;
        }

        assertEquals( Math.round(sum/count), books.get(0).getRating(), String.format("User rating for book with id = %d from database is different with calc value", books.get(0).getId()));
    }

    /**
     * Проверяем правильность списка рекомендованных книг. Смотрим рейтинги первой и последней книги, сравниваем с лучшим и худшим рейтингом в БД
     */
    @Test
    public void bookRecommendedTest() {
        int minR = bookRepository.getMinRating();
        int maxR = bookRepository.getMaxRating();

        List<Book> books = bookRepository.findAll();
        assertEquals(false, books.isEmpty(), "List books is empty!");

        Pageable nextPage = PageRequest.of(0, books.size());
        books = bookRepository.findBookByOrderByRatingDesc(nextPage).getContent();
        assertEquals(maxR, books.get(0).getRating(), "Incorrect rating value of first book from recommended");

        assertEquals(minR, books.get(books.size() - 1).getRating(), "Incorrect rating value of last book from recommended");




    }
}