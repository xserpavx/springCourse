package org.example.web.controllers;

import org.apache.log4j.Logger;
import org.example.app.services.BookService;
import org.example.web.dto.Book;
import org.example.web.dto.validator.ValidateByAuthor;
import org.example.web.dto.validator.ValidateById;
import org.example.web.dto.validator.ValidateBySize;
import org.example.web.dto.validator.ValidateByTitle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.validation.Valid;

@Controller
@RequestMapping(value = "/books")
public class BookShelfController {

    private Logger logger = Logger.getLogger(BookShelfController.class);
    private final BookService bookService;

    @Autowired
    public BookShelfController(BookService bookService) {
        this.bookService = bookService;
        bookService.setLastMessage("");
        bookService.setFilterMessage("filters off");
    }

    @GetMapping("/shelf")
    public String books(Model model) {
        logger.info("got book shelf");
        addCommonParameters2Model2(model);
        return "book_shelf";
    }

    private void addCommonParameters2Model2(Model model) {
        addCommonParameters2Model2(model, "");
    }

    private void addCommonParameters2Model2(Model model, String skip) {
        model.addAttribute("bookList", bookService.getAllBooks());
        model.addAttribute("lastMessage", bookService.getLastMessage());
        model.addAttribute("filterMessage", bookService.getFilterMessage());
        model.addAttribute("book", new Book());
        model.addAttribute("removeByTitle", new ValidateByTitle());
        model.addAttribute("removeByAuthor", new ValidateByAuthor());
        model.addAttribute("removeBySize", new ValidateBySize());
        model.addAttribute("filterByAuthor", new ValidateByAuthor());
        model.addAttribute("filterByTitle", new ValidateByTitle());
        model.addAttribute("filterBySize", new ValidateBySize());
        model.addAttribute("removeById", new ValidateById());

    }

    @PostMapping("/remove")
    public String removeBook(@Valid ValidateById id, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model);
            model.addAttribute("removeById", id);
            model.addAttribute("org.springframework.validation.BindingResult.removeById", bindingResult);
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
            addCommonParameters2Model2(model);
            model.addAttribute("book", saveBook);
            model.addAttribute("org.springframework.validation.BindingResult.book", bindingResult);
            return "book_shelf";
        } else {
            bookService.saveBook(saveBook);
            logger.info("current repository size: " + bookService.getAllBooks().size());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/remove_by_author")
    public String removeBooksByAuthor(@Valid ValidateByAuthor author, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model, "");
            model.addAttribute("removeByAuthor", author);
            model.addAttribute("org.springframework.validation.BindingResult.removeByAuthor", bindingResult);
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
    public String removeBooksByTitle(@Valid ValidateByTitle title, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model);
            model.addAttribute("removeByTitle", title);
            model.addAttribute("org.springframework.validation.BindingResult.removeByTitle", bindingResult);
            return "book_shelf";
        } else {
            int delCount = bookService.removeBooksByTitle(title.getTitle());
            if (delCount != 0) {
                bookService.setLastMessage(String.format("Removed %d books which title contains %s.", delCount, title.getTitle()));
            } else {
                bookService.setLastMessage(String.format("Books which title contain %s not found!", title.getTitle()));
            }
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/remove_by_size")
    public String removeBooksBySize(@Valid ValidateBySize size, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model);
            model.addAttribute("removeBySize", size);
            model.addAttribute("org.springframework.validation.BindingResult.removeBySize", bindingResult);
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
    public String setAuthorFilter(@Valid ValidateByAuthor author, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model);
            model.addAttribute("filterByAuthor", author);
            model.addAttribute("org.springframework.validation.BindingResult.filterByAuthor", bindingResult);
            return "book_shelf";
        } else {
            bookService.setAuthorFilter(author.getAuthor());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/set_title_filter")
    public String setTitleFilter(@Valid ValidateByTitle title, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model);
            model.addAttribute("filterByTitle", title);
            model.addAttribute("org.springframework.validation.BindingResult.filterByTitle", bindingResult);
            return "book_shelf";
        } else {
            bookService.setTitleFilter(title.getTitle());
            return "redirect:/books/shelf";
        }
    }

    @PostMapping("/set_size_filter")
    public String setSizeFilter(@Valid ValidateBySize size, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model2(model);
            model.addAttribute("filterBySize", size);
            model.addAttribute("org.springframework.validation.BindingResult.filterBySize", bindingResult);
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
