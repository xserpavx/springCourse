package org.example.web.dto;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;

/**
 * Created on 15.07.2021
 *
 * @author roland
 **/

public class FileToUpload {
    private final static Logger log = LoggerFactory.getLogger(FileToUpload.class);
    @Getter @Setter
    MultipartFile file;

}
