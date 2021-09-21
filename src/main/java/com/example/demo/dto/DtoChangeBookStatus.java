package com.example.demo.dto;

import lombok.Data;

/**
 * Created on 21.09.2021
 *
 * @author roland
 **/
@Data
public class DtoChangeBookStatus {
    String booksIds;
    String status;
}
