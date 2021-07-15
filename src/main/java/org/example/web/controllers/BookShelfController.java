package org.example.web.controllers;

import org.apache.log4j.Logger;
import org.example.app.services.BookService;
import org.example.web.dto.Book;
import org.example.web.dto.remove.RemoveByAuthor;
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
import org.springframework.web.multipart.MultipartFile;

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
//        book = new Book();
//        book.setAuthor("Mark Twain");
//        book.setTitle("The Adventures of Tom Sawyer");
//        book.setSize(250);
//        bookService.saveBook(book);
//        book = new Book();
//        book.setAuthor("Mark Twain");
//        book.setTitle("The Adventures of Huckleberry Finn");
//        book.setSize(300);
//        bookService.saveBook(book);

        bookService.setLastMessage("");
        bookService.setFilterMessage("filters off");

    }

    @GetMapping("/shelf")
    public String books(Model model) {
        logger.info("got book shelf");
        addCommonParameters2Model(model);
        model.addAttribute(varBookName, new Book());
        model.addAttribute("book2", new Book());
        model.addAttribute("removeByTitle", new RemoveByTitle());
        model.addAttribute("removeByAuthor", new RemoveByAuthor());
        RemoveByAuthor test = new RemoveByAuthor();
        test.setAuthor("12");
        model.addAttribute("removeByAuthor2", test);
        model.addAttribute("removeBySize", new RemoveBySize());
        return "book_shelf";
    }

    private void addCommonParameters2Model(Model model) {
        model.addAttribute("bookList", bookService.getAllBooks());
        model.addAttribute("lastMessage", bookService.getLastMessage());
        model.addAttribute("filterMessage", bookService.getFilterMessage());
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

    @PostMapping("/save")
    public String saveBook(@Valid Book saveBook, BindingResult bindingResult, Model model) {
        if (bindingResult.hasErrors()) {
            addCommonParameters2Model(model);
            model.addAttribute("removeByTitle", new RemoveByTitle());
            model.addAttribute("removeByAuthor", new RemoveByAuthor());
            model.addAttribute("removeByAuthor2", new RemoveByAuthor());
            model.addAttribute("removeBySize", new RemoveBySize());
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
            addCommonParameters2Model(model);
            model.addAttribute(varBookName, new Book());
            model.addAttribute("removeByTitle", new RemoveByTitle());
            model.addAttribute("removeByAuthor", author);
            model.addAttribute("removeByAuthor2", new RemoveByAuthor());
            model.addAttribute("removeBySize", new RemoveBySize());
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

    @PostMapping("/question")
    public String question(@Valid RemoveByAuthor author, BindingResult bindingResult, Model model) {
        /*
            Post запрос question связан с формой на странице book_shelf через аттрибут модели removeByAuthor2.
            В переменной author хранятся поля объекта связанного с этой формой и это правильно
             */
        if (bindingResult.hasErrors()) {
            /*
            Проверка правильности заполнения полей выдает ошибку и это правильно. По аналогии с примером из лекции кладем
            переменную author в аттрибут модели removeByAuthor2, в остальные аттрибуты кладем пустые объекты
             */
            addCommonParameters2Model(model);

            model.addAttribute(varBookName, new Book());
            model.addAttribute("removeByTitle", new RemoveByTitle());
            /*
            В настоящий момент одним из аттрибутов модели является org.springframework.validation.BindingResult.removeByAuthor.
            Как я понимаю в нем хранятся сведения об ошибках валидации. Если этого объекта не будет в модели - то и на форме не
            будет сведений об ошибках
             */
            model.addAttribute("removeByAuthor", new RemoveByAuthor());
            /*
            А вот теперь аттрибут модели org.springframework.validation.BindingResult.removeByAuthor пропадает.
            И ошибок на форме не будет.
            Почему?
             */
            model.addAttribute("removeByAuthor2", author);
            model.addAttribute("removeBySize", new RemoveBySize());
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
            addCommonParameters2Model(model);
            model.addAttribute("removeByTitle", removeByTitle);
            model.addAttribute("removeByAuthor", new RemoveByAuthor());
            model.addAttribute("removeByAuthor2", new RemoveByAuthor());
            model.addAttribute("removeBySize", new RemoveBySize());
            model.addAttribute("book", new Book());
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
            addCommonParameters2Model(model);
            model.addAttribute("removeByTitle", new RemoveByTitle());
            model.addAttribute("removeByAuthor", new RemoveByAuthor());
            model.addAttribute("removeByAuthor2", new RemoveByAuthor());
            model.addAttribute("book", new Book());
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
