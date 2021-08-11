package com.example.demo.controllers;

import com.example.demo.entity.Genre;
import com.example.demo.services.GenreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

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

    @Autowired
    public GenresController(GenreService genreService) {
        this.genreService = genreService;
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
