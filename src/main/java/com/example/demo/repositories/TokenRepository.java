package com.example.demo.repositories;

import com.example.demo.entity.AccessToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Created on 20.08.2021
 *
 * @author roland
 **/
@Repository
public interface TokenRepository extends JpaRepository<AccessToken, Integer> {

    AccessToken findAccessTokenByAccessToken(String token);

}
