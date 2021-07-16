package org.example.web.controllers;

import org.apache.commons.io.IOUtils;
import org.example.app.services.FileService;
import org.example.web.dto.Book;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.apache.commons.io.filefilter.DirectoryFileFilter.DIRECTORY;

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
        model.addAttribute("listFiles", FileService.getFilesList(getUploadRootPath(), false));
        return "files_io";
    }

    private String getUploadRootPath() {
        return String.format("%s%s%s", System.getProperty("catalina.home"), File.separator, "uploads");
    }

    @PostMapping("/upload")
    public String uploadFile(@RequestParam("file") MultipartFile file) throws Exception {
        if (file.getSize() == 0 || file.getOriginalFilename().length() == 0) {
            message = "Error while uploading file. File size is 0 or filename empty!";
            return "redirect:/files";
        } else {
            String fileName = file.getOriginalFilename();
            byte[] bytes = file.getBytes();

            String rootPath = getUploadRootPath();
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

    @GetMapping(value = "/getFile")
    public void getFile(HttpServletResponse response, @RequestParam(name = "fn") String fileName) throws IOException {
        response.setContentType(MediaType.APPLICATION_OCTET_STREAM_VALUE);
        response.addHeader("Content-Disposition", "attachment; filename=" + fileName);
        Path file = Paths.get(String.format("%s%s%s", getUploadRootPath(), File.separator, fileName));
        try
        {
            Files.copy(file, response.getOutputStream());
            response.getOutputStream().flush();
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    @GetMapping(value = "/deleteFile")
    public String deleteFile(@RequestParam(name = "fn") String fileName) {
        int fileCount = FileService.getFilesList(getUploadRootPath(), false).size();
        File delFile = new File(String.format("%s%s%s", getUploadRootPath(), File.separator, fileName));
        FileService.delete(delFile);
        message = fileCount != FileService.getFilesList(getUploadRootPath(), false).size() ?
                String.format("File by name \"%s\" delete successful!", fileName) : String.format("Some error while deleting file by name \"%s\"!", fileName);
        return "redirect:/files";

    }
}
