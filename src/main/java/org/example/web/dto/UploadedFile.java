package org.example.web.dto;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.constraints.NotNull;

/**
 * Created on 15.07.2021
 *
 * @author roland
 **/

public class UploadedFile {
    private final static Logger log = LoggerFactory.getLogger(UploadedFile.class);

    @NotNull
    MultipartFile file;
}
