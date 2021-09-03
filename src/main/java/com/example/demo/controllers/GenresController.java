package com.example.demo.controllers;

import com.example.demo.entity.Genre;
import com.example.demo.entity.User;
import com.example.demo.services.ControllerService;
import com.example.demo.services.GenreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/genres")
public class GenresController {

    private final GenreService genreService;
    private final ControllerService controllerService;

    @Autowired
    public GenresController(GenreService genreService, ControllerService controllerService) {
        this.genreService = genreService;
        this.controllerService = controllerService;
    }

    @ModelAttribute("authUser")
    public User checkAuth() {
        return controllerService.getCurrentUser();
    }

    @ModelAttribute("ppCount")
    public int ppCount(@CookieValue(name="ppCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("cartCount")
    public int cartCount(@CookieValue(name="cartCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("active")
    public String active() {
        return "genres";
    }

    @GetMapping("/orig")
    public String getMainPage() {
        return "indexOld";
    }

    @GetMapping("/{slug}")
    public String getSlugPage(@PathVariable(value = "slug") String slug,
                              Model model) {
        model.addAttribute("genre", genreService.getGenreBySlug(slug));
        model.addAttribute("listBooks", genreService.getPageBooksBySlug(slug, 0, 20).getContent());
        return "genres/slug";
    }

    @GetMapping("/main")
    public String getMainPageDev(Model model) {
        Map<Integer, Genre> genres = new HashMap<>();
        List<Genre> root = new ArrayList<>();
        for (Genre genre : genreService.getGenres()) {
            if (genre.getIdParent() != null) {
                continue;
            }
            genres.put(genre.getId(), genre);
            root.add(genre);

        }
        for (Genre genre : genreService.getGenres()) {
            if (genre.getIdParent() == null) {
                continue;
            }
            genres.put(genre.getId(), genre);
            Genre parent = genres.get(genre.getIdParent());
            if (parent != null) {
                parent.addChild(genre);
            }
        }

        model.addAttribute("genres", root);

        return "genres/index";
    }
}
