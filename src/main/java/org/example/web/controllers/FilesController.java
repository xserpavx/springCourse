package org.example.web.controllers;

import org.example.web.dto.Book;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;

/**
 * Created on 15.07.2021
 * Контроллер, отвечающий за передачу файлов на сервер и обратно
 * @author roland
 **/

@Controller
public class FilesController {
    private final static Logger log = LoggerFactory.getLogger(FilesController.class);

    private String message = "Welcome to page for working with files";

    @GetMapping("/files")
    public String files(Model model) {
        model.addAttribute("message", message);
        return "files_io";
    }


    @PostMapping("/upload")
    public String uploadFile(@RequestParam("file") MultipartFile file) throws Exception {
        if (file.getSize() == 0 || file.getOriginalFilename().length() == 0) {
            message = "Error while uploading file. File size is 0 or filename empty!";
            return "redirect:/files";
        } else {
            String fileName = file.getOriginalFilename();
            byte[] bytes = file.getBytes();

            String rootPath = String.format("%s%s%s", System.getProperty("catalina.home"), File.separator, "uploads");
            File path = new File(rootPath);
            if (!path.exists()) {
                path.mkdirs();
            }

            File uploadFile = new File(String.format("%s%s%s", path.getAbsolutePath(), File.separator, fileName));
            try (BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(uploadFile))) {
                bos.write(bytes);
            }
            message = String.format("File \"%s\" loaded successful! Target path is \"%s\"", file.getOriginalFilename(), uploadFile.getAbsolutePath());
            return "redirect:/files";
        }

    }
}
