package com.example.demo.security;

import lombok.Data;

import javax.persistence.*;

/**
 * Created on 20.08.2021
 *
 * @author roland
 **/

@Entity
@Table(name="bs_users")
@Data
public class BookstoreUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String name;
    private String email;
    private String phone;
    private String password;
}
