package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;

/**
 * Created on 27.07.2021
 *
 * @author roland
 **/

@Entity
@Table(name = "book_files")
public class BookFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Getter
    @Setter
    private Integer id;
    @Getter
    @Setter
    @ManyToOne
    @JoinColumn(
            name = "id_book_file_type",
            referencedColumnName = "id",
            insertable = false,
            updatable = false)
    private BookFileType idBookFileType;
    @Getter
    @Setter
    private String hash;
    @Getter
    @Setter
    @Column(name = "file_name")
    private String fileName;
}
