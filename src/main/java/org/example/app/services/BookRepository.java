package org.example.app.services;

import org.apache.log4j.Logger;
import org.example.web.dto.Book;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

@Repository
public class BookRepository implements ProjectRepository<Book> {

    private final Logger logger = Logger.getLogger(BookRepository.class);
    private final List<Book> repo = new ArrayList<>();

    @Override
    public List<Book> retreiveAll() {
        return new ArrayList<>(repo);
    }

    @Override
    public void store(Book book) {
        book.setId(book.hashCode());
        logger.info("store new book: " + book);
        repo.add(book);
    }

    @Override
    public int removeBooksByTitle(String titleToRemove) {
        int booksCount = repo.size();
        for (Book book : retreiveAll()) {
            if (book.getTitle().toLowerCase().contains(titleToRemove.toLowerCase())) {
                logger.info(String.format("Remove book by title: %s", book.toString()));
                repo.remove(book);
            }
        }
        if (booksCount == repo.size()) {
            logger.info(String.format("Book with title %s not found on bookshelf!", titleToRemove));
        }
        return Math.abs(booksCount - repo.size());
    }

    @Override
    public boolean removeItemById(Integer bookIdToRemove) {
        for (Book book : retreiveAll()) {
            if (book.getId().equals(bookIdToRemove)) {
                logger.info("remove book completed: " + book);
                return repo.remove(book);
            }
        }
        logger.info(String.format("book by id \"%d\" not found!", bookIdToRemove));
        return false;
    }

    @Override
    public int removeBooksByPageSize(Integer pageSize) {
        int booksCount = repo.size();
        try {
            for (Book book : retreiveAll()) {
                if (book.getSize().equals(pageSize)) {
                    logger.info(String.format("Remove book where size = %d: %s", pageSize, book.toString()));
                    repo.remove(book);
                }
            }
            if (booksCount == repo.size()) {
                logger.info(String.format("Book with size = %s not found on bookshelf!", pageSize));
            }
        } catch (NumberFormatException e) {

        }
        return Math.abs(booksCount - repo.size());
    }

    @Override
    public int removeBooksByAuthor(String author) {
        int booksCount = repo.size();
        for (Book book : retreiveAll()) {
            if (book.getAuthor().equals(author)) {
                logger.info(String.format("remove book by %s: %s", author, book.toString()));
                repo.remove(book);
            }
        }
        if (booksCount == repo.size()) {
            logger.info(String.format("Book written by %s not found on bookshelf!", author));
        }
        return Math.abs(booksCount - repo.size());
    }

    public BookRepository() {
        Book book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Fellowship of the Ring");
        book.setSize(756);
        store(book);
        book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Two Towers");
        book.setSize(658);
        store(book);
        book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Return of the King");
        book.setSize(930);
        store(book);
        book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Hobbit or There and Back Again");
        book.setSize(428);
        store(book);
        book = new Book();
        book.setAuthor("O.Henry");
        book.setTitle("Cabbages and Kings");
        book.setSize(370);
        store(book);
        book = new Book();
        book.setAuthor("A. Conan Doyle");
        book.setTitle("The adventures of Sherlock Holmes");
        book.setSize(428);
        store(book);
    }
}
