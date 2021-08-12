package com.example.demo.entity;

import lombok.Data;

import javax.persistence.*;

/**
 * Created on 27.07.2021
 *
 * @author roland
 **/

@Entity
@Data
@Table(name = "book_files")
public class BookFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(
            name = "id_book_file_type",
            referencedColumnName = "id",
            insertable = false,
            updatable = false)
    private BookFileType idBookFileType;

    private String hash;

    @Column(name = "file_name")
    private String fileName;
}
