package com.example.demo.controllers;

import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/books")
public class RecentController {

    private final BookService bookService;

    @Autowired
    public RecentController(BookService bookService) {
        this.bookService = bookService;
    }

    @ModelAttribute("listBooks")
    public List<Book> recentBooks() {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.MONTH, -1);
        return bookService.getPageRecentBooksByDate(cal.getTime(), new Date(), 0, 20).getContent();
    }

    @ModelAttribute("active")
    public String active() {
        return "recent";
    }

    @GetMapping("/recentPage")
    public String recentPage() {
        return "books/recent";
    }

//FIXME закомментированый код удаляем
//    @GetMapping("/recent")
//    @ResponseBody
//    public BookListDto getRecentBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
//        return new BookListDto(bookService.getPageRecentBooks(offset, limit).getContent());
//    }
//
//    @GetMapping("/recentDate")
//    @ResponseBody
//    public BookListDto getRecentBooksByDate(@RequestParam(value = "from") String from, @RequestParam(value = "to") String to, @RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
//        SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyy");
//        try {
//            return new BookListDto(bookService.getPageRecentBooksByDate(sdf.parse(from), sdf.parse(to), offset, limit).getContent());
//        } catch (ParseException e) {
//            e.printStackTrace();
//        }
//        return new BookListDto(bookService.getPageRecentBooks(offset, limit).getContent());
//    }
}
