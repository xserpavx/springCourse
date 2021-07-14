package org.example.app.services;

import org.example.web.dto.Book;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class BookService {

    private final ProjectRepository<Book> bookRepo;
    private String lastMessage = "";
    private String authFilter = "";
    private String titleFilter = "";
    private Integer pageFilter = 0;
    private String filterMessage = "";

    public String getFilterMessage() {
        filterMessage = authFilter.length() == 0 && titleFilter.length() == 0 && pageFilter == 0 ? "filters off" :
                String.format("Enabled filter by: %s%s%s", authFilter.length() == 0 ? "" : String.format("author - %s; ",authFilter),
                        titleFilter.length() == 0 ? "" : String.format("title - %s; ", titleFilter),
                        pageFilter == 0 ? "" : String.format("size - %d; ", pageFilter));
        return filterMessage;
    }


    @Autowired
    public BookService(ProjectRepository<Book> bookRepo) {
        this.bookRepo = bookRepo;
    }

    public List<Book> getAllBooks() {
        if (authFilter.length() == 0 && titleFilter.length() == 0 && pageFilter == 0) {
            return bookRepo.retreiveAll();
        } else {
            List<Book> filteredBooks = new ArrayList<>();
            for (Book book : bookRepo.retreiveAll()) {
                boolean onFilter = true;
                if (authFilter.length() != 0) {
                    onFilter = onFilter && book.getAuthor().toLowerCase().contains(authFilter.toLowerCase());
                }
                if (titleFilter.length() != 0) {
                    onFilter = onFilter && book.getTitle().toLowerCase().contains(titleFilter.toLowerCase());
                }
                if (pageFilter != 0) {
                    onFilter = onFilter && book.getSize().compareTo(pageFilter) == 0;
                }
                if (onFilter) {
                    filteredBooks.add(book);
                }
            }
            return filteredBooks;
        }
    }

    public void saveBook(Book book) {

        if (book.checkFields()) {
            bookRepo.store(book);
            lastMessage = "Book saved successfuly";
        } else {
            lastMessage = "Can`t store empty book!";
        }
    }

    public boolean removeBookById(Integer bookIdToRemove) {
        return bookRepo.removeItemById(bookIdToRemove);
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setFilterMessage(String filterMessage) {
        this.filterMessage = filterMessage;
    }

    public void setLastMessage(String message) {
        lastMessage = message;
    }

    public int removeBooksByAuthor(String author) {
        return bookRepo.removeBooksByAuthor(author);
    }

    public int removeBooksByTitle(String titleToRemove) {
        return bookRepo.removeBooksByTitle(titleToRemove);
    }

    public int removeBooksByPageSize(Integer pageSize) {
        return bookRepo.removeBooksByPageSize(pageSize);
    }

    public void setAuthorFilter(String author) {
        authFilter = author;
    }

    public void setTitleFilter(String title) {
        titleFilter = title;
    }

    public void setSizeFilter(Integer size) {
        pageFilter = size;
    }
}
