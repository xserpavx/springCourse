package com.example.demo.entity;

import lombok.Data;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

/**
 * Created on 07.09.2021
 *
 * @author roland
 **/

@Entity
@Data
public class AccessToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    String accessToken;
    String refreshToken;
    String userName;
}
