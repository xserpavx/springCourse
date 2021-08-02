package com.example.demo.controllers;


import com.example.demo.entity.Genre;
import com.example.demo.services.GenreService;
import liquibase.pro.packaged.A;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
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
        return "genres/index";
    }

    @GetMapping("/slug")
    public String getSlugPage() {
        return "genres/slug";
    }

    @GetMapping("/main")
    public String getMainPageDev(Model model) {
        Map<Integer, Genre> genres = new HashMap<>();
        List<Genre> root = new ArrayList<>();
        for (Genre genre : genreService.getGenres()) {
            if (genre.getId_parent() != null) { continue;}
            genres.put(genre.getId(), genre);
            root.add(genre);

        }
        for (Genre genre : genreService.getGenres()) {
            if (genre.getId_parent() == null) { continue;}
            genres.put(genre.getId(), genre);
            Genre parent = genres.get(genre.getId_parent());
            if (parent != null) {
                parent.addChild(genre);
            }
        }

        model.addAttribute("genres", root);
//        model.addAttribute("child", genreService.getChildNodes());
        return "genres/indexDev";
    }
}
