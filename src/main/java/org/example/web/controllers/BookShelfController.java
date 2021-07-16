package org.example.web.controllers;

import org.apache.log4j.Logger;
import org.example.app.services.BookService;
import org.example.web.dto.Book;
import org.example.web.dto.filter.FilterByAuthor;
import org.example.web.dto.filter.FilterBySize;
import org.example.web.dto.filter.FilterByTitle;
import org.example.web.dto.remove.RemoveByAuthor;
import org.example.web.dto.remove.RemoveById;
import org.example.web.dto.remove.RemoveBySize;
import org.example.web.dto.remove.RemoveByTitle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.validation.Valid;
import java.io.*;

@Controller
@RequestMapping(value = "/books")
public class BookShelfController {

    private static final String varBookName = "book";

    private Logger logger = Logger.getLogger(BookShelfController.class);
    private BookService bookService;


    @Autowired
    public BookShelfController(BookService bookService) {
        this.bookService = bookService;



        bookService.setLastMessage("");
        bookService.setFilterMessage("filters off");

    }

    @GetMapping("/shelf")
    public String books(Model model) {
        logger.info("got book shelf");
        addCommonParameters2Model2(model, "");
        return "book_shelf";
    }


    private void addCommonParameters2Model2(Model model, String skipAttribute) {
        if (skipAttribute.compareTo("bookList") != 0) {
            model.addAttribute("bookList", bookService.getAllBooks());
        }
        if (skipAttribute.compareTo("lastMessage") != 0) {
            model.addAttribute("lastMessage", bookService.getLastMessage());
        }
        if (skipAttribute.compareTo("bookList") != 0) {
            model.addAttribute("filterMessage", bookService.getFilterMessage());
        }
        if (skipAttribute.compareTo(varBookName) != 0) {
            model.addAttribute(varBookName, new Book());
        }
        if (skipAttribute.compareTo("removeByTitle") != 0) {
            model.addAttribute("removeByTitle", new RemoveByTitle());
        }
        if (skipAttribute.compareTo("removeByAuthor") != 0) {
            model.addAttribute("removeByAuthor", new RemoveByAuthor());
        }
        if (skipAttribute.compareTo("removeByAuthor2") != 0) {
            RemoveByAuthor test = new RemoveByAuthor();
            test.setAuthor("12");
            model.addAttribute("removeByAuthor2", test);
        }
        if (skipAttribute.compareTo("removeBySize") != 0) {
            model.addAttribute("removeBySize", new RemoveBySize());
        }
        if (skipAttribute.compareTo("filterByAuthor") != 0) {
            model.addAttribute("filterByAuthor", new FilterByAuthor());
        }
        if (skipAttribute.compareTo("filterByTitle") != 0) {
            model.addAttribute("filterByTitle", new FilterByTitle());
        }
        if (skipAttribute.compareTo("filterBySize") != 0) {
            model.addAttribute("filterBySize", new FilterBySize());
        }
        if (skipAttribute.compareTo("removeById") != 0) {
            model.addAttribute("removeById", new RemoveById());
        }
    }

    @PostMapping("/remove")
    public String removeBook(@Valid RemoveById id, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "removeById");
            return "book_shelf";
        } else {
            if (bookService.removeBookById(id.getId())) {
                bookService.setLastMessage(String.format("Book with id \"%s\" deleted succesfully", id.getId()));
            } else {
                bookService.setLastMessage(String.format("Book with id \"%s\" not found!", id.getId()));
            }
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/save")
    public String saveBook(@Valid Book saveBook, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, varBookName);
            return "book_shelf";
        } else {
            bookService.saveBook(saveBook);
            logger.info("current repository size: " + bookService.getAllBooks().size());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/remove_by_author")
    public String removeBooksByAuthor(@Valid RemoveByAuthor author, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "removeByAuthor");
            return "book_shelf";
        } else {
            int delCount = bookService.removeBooksByAuthor(author.getAuthor());
            if (delCount != 0) {
                bookService.setLastMessage(String.format("Removed %d books written by %s.", delCount, author.getAuthor()));
            } else {
                bookService.setLastMessage(String.format("Books written by %s not found!", author.getAuthor()));
            }
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/remove_by_title")
    public String removeBooksByTitle(@Valid RemoveByTitle removeByTitle, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "removeByTitle");
            return "book_shelf";
        } else {
            int delCount = bookService.removeBooksByTitle(removeByTitle.getTitle());
            if (delCount != 0) {
                bookService.setLastMessage(String.format("Removed %d books which title contains %s.", delCount, removeByTitle.getTitle()));
            } else {
                bookService.setLastMessage(String.format("Books which title contain %s not found!", removeByTitle.getTitle()));
            }
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/remove_by_size")
    public String removeBooksBySize(@Valid RemoveBySize size, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "removeBySize");
            return "book_shelf";
        } else {
            int delCount = bookService.removeBooksByPageSize(size.getSize());
            if (delCount != 0) {
                bookService.setLastMessage(String.format("Removed %d books with with size = %s.", delCount, size.getSize()));
            } else {
                bookService.setLastMessage(String.format("Book with size = %s not found!", size.getSize()));
            }
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/set_author_filter")
    public String setAuthorFilter(@Valid FilterByAuthor author, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "filterByAuthor");
            return "book_shelf";
        } else {
            bookService.setAuthorFilter(author.getAuthor());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/set_title_filter")
    public String setTitleFilter(@Valid FilterByTitle title, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "filterByTitle");
            return "book_shelf";
        } else {
            bookService.setTitleFilter(title.getTitle());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/set_size_filter")
    public String setSizeFilter(@Valid FilterBySize size, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "filterBySize");
            return "book_shelf";
        } else {
            bookService.setSizeFilter(size.getSize());
            return "redirect:/books/shelf";
        }
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
