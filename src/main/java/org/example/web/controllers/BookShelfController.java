package org.example.web.controllers;

import org.apache.log4j.Logger;
import org.example.app.services.BookService;
import org.example.web.dto.Book;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.validation.Valid;

@Controller
@RequestMapping(value = "/books")
public class BookShelfController {

    private Logger logger = Logger.getLogger(BookShelfController.class);
    private BookService bookService;


    @Autowired
    public BookShelfController(BookService bookService) {
        this.bookService = bookService;
        Book book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Fellowship of the Ring");
        book.setSize(756);
        bookService.saveBook(book);
        book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Two Towers");
        book.setSize(658);
        bookService.saveBook(book);
        book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Return of the King");
        book.setSize(930);
        bookService.saveBook(book);
        book = new Book();
        book.setAuthor("JRR Tolkien");
        book.setTitle("The Hobbit or There and Back Again");
        book.setSize(428);
        bookService.saveBook(book);
        book = new Book();
        book.setAuthor("O.Henry");
        book.setTitle("Cabbages and Kings");
        book.setSize(370);
        bookService.saveBook(book);
        book = new Book();
        book.setAuthor("A. Conan Doyle");
        book.setTitle("The adventures of Sherlock Holmes");
        book.setSize(428);
        bookService.saveBook(book);

        bookService.setLastMessage("");
        bookService.setFilterMessage("filters off");

    }

    @GetMapping("/shelf")
    public String books(Model model) {
        logger.info("got book shelf");
        model.addAttribute("book", new Book());
        model.addAttribute("bookList", bookService.getAllBooks());
        model.addAttribute("lastMessage", bookService.getLastMessage());
        model.addAttribute("filterMessage", bookService.getFilterMessage());
        model.addAttribute("bookToRemove", new Book());
        return "book_shelf";
    }

    @PostMapping("/save")
    public String saveBook(@Valid Book book, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("book", book);
            model.addAttribute("bookList", bookService.getAllBooks());
            model.addAttribute("lastMessage", bookService.getLastMessage());
            model.addAttribute("filterMessage", bookService.getFilterMessage());
            model.addAttribute("bookToRemove", new Book());
            return "book_shelf";
        } else {
            bookService.saveBook(book);
            logger.info("current repository size: " + bookService.getAllBooks().size());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/remove")
    public String removeBook(Book bookToRemove) {
        try {

            if (bookService.removeBookById(bookToRemove.getId())) {
                bookService.setLastMessage(String.format("Book with id \"%s\" deleted succesfully", bookToRemove.getId()));
            } else {
                bookService.setLastMessage(String.format("Book with id \"%s\" not found!", bookToRemove.getId()));
            }
        } catch (NumberFormatException e) {
            bookService.setLastMessage(String.format("Book id must be integer instead \"%s\"", bookToRemove.getId()));
            logger.warn(String.format("book id must be integer!"));
        }
        return "redirect:/books/shelf";
    }

//    @PostMapping("/removeBy")
//    public String removeBookBy(@Valid Book bookToRemove, BindingResult bindingResult, Model model) {
//        if (bindingResult.hasErrors()) {
//            model.addAttribute("book", new Book());
//            model.addAttribute("bookList", bookService.getAllBooks());
//            model.addAttribute("lastMessage", bookService.getLastMessage());
//            model.addAttribute("filterMessage", bookService.getFilterMessage());
//            bookToRemove.setId(1);
//            bookToRemove.setAuthor("roland");
//            bookToRemove.setTitle("homework");
//            model.addAttribute("bookToRemove", bookToRemove);
//            return "book_shelf";
//        } else {
//            if (bookToRemove.getId() != null) {
//                if (bookService.removeBookById(bookToRemove.getId())) {
//                    bookService.setLastMessage(String.format("Book with id \"%s\" deleted succesfully", bookToRemove.getId()));
//                } else {
//                    bookService.setLastMessage(String.format("Book with id \"%s\" not found!", bookToRemove.getId()));
//                }
//            }
//            return "redirect:/books/shelf";
//        }
////        try {
////            if (bookToRemove.getId() != null) {
////                if (bookService.removeBookById(bookToRemove.getId())) {
////                    bookService.setLastMessage(String.format("Book with id \"%s\" deleted succesfully", bookToRemove.getId()));
////                } else {
////                    bookService.setLastMessage(String.format("Book with id \"%s\" not found!", bookToRemove.getId()));
////                }
////            }
////
////        } catch (NumberFormatException e) {
////            bookService.setLastMessage(String.format("Book id must be integer instead \"%s\"", bookToRemove.getId()));
////            logger.warn(String.format("book id must be integer!"));
////        }
//
//    }

    @PostMapping("/remove_by_author")
    public String removeBooksByAuthor(@RequestParam(value = "authorToRemove") String authorToRemove) {
        int delCount = bookService.removeBooksByAuthor(authorToRemove);
        if (delCount != 0) {
            bookService.setLastMessage(String.format("Removed %d books written by %s.", delCount, authorToRemove));
        } else {
            bookService.setLastMessage(String.format("Books written by %s not found!", authorToRemove));
        }
        return "redirect:/books/shelf";
    }

    @PostMapping("/remove_by_title")
    public String removeBooksByTitle(@RequestParam(value = "titleToRemove") String titleToRemove) {
        int delCount = bookService.removeBooksByTitle(titleToRemove);
        if (delCount != 0) {
            bookService.setLastMessage(String.format("Removed %d books which title contains %s.", delCount, titleToRemove));
        } else {
            bookService.setLastMessage(String.format("Books which title contain %s not found!", titleToRemove));
        }
        return "redirect:/books/shelf";
    }

    @PostMapping("/remove_by_size")
    public String removeBooksBySize(@RequestParam(value = "sizeToRemove") String sizeToRemove) {
        try {
            int delCount = bookService.removeBooksByPageSize(Integer.parseInt(sizeToRemove));
            if (delCount != 0) {
                bookService.setLastMessage(String.format("Removed %d books with with size = %s.", delCount, sizeToRemove));
            } else {
                bookService.setLastMessage(String.format("Book with size = %s not found!", sizeToRemove));
            }
        } catch (NumberFormatException e) {
            bookService.setLastMessage(String.format("Book size must be integer instead \"%s\"", sizeToRemove));
            logger.warn(String.format("Book size must be integer!"));
        }
        return "redirect:/books/shelf";
    }

    @PostMapping("/set_author_filter")
    public String setAuthorFilter(@RequestParam(value = "authorFilter") String authorFilter) {
        bookService.setAuthorFilter(authorFilter);
        return "redirect:/books/shelf";
    }

    @PostMapping("/set_title_filter")
    public String setTitleFilter(@RequestParam(value = "titleFilter") String titleFilter) {
        bookService.setTitleFilter(titleFilter);
        return "redirect:/books/shelf";
    }

    @PostMapping("/set_size_filter")
    public String setSizeFilter(@RequestParam(value = "sizeFilter") String sizeFilter) {
        try {
            int size = Integer.parseInt(sizeFilter);
            bookService.setSizeFilter(size);
        } catch (NumberFormatException e) {
            bookService.setLastMessage(String.format("Size filter value must be integer instead \"%s\"", sizeFilter));
            logger.warn(String.format("Size filter value must be integer!"));
        }
        return "redirect:/books/shelf";
    }

    @GetMapping("/clear_filter")
    public String clearFilters() {
        bookService.setAuthorFilter("");
        bookService.setTitleFilter("");
        bookService.setSizeFilter(0);
        bookService.setLastMessage("All filters are clear!");
        return "redirect:/books/shelf";
    }
}
