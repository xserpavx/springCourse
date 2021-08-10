package com.example.demo.controllers;


import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * Created on 22.07.2021
 *
 * @author roland
 **/
@Controller
public class TagsController {

    private final BookService bookService;

    @Autowired
    public TagsController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping("/tags/main/{tag}")
    public String getMainPage(@PathVariable(value="tag") String tag, Model model) {
        model.addAttribute("tag", tag);
        model.addAttribute("listBooks", bookService.getPageBooksByTag(tag, 0, 20).getContent());
        return "tags/index";
    }

//    @GetMapping("/books/tag/{id}")
//    @ResponseBody
//    public BookListDto getBooksByTag(@PathVariable String id, @RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
//        return new BookListDto(bookService.getPageBooksByTag(id, offset, limit).getContent());
//    }
}
