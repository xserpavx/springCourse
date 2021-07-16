package org.example.app.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * Created on 17.07.2021
 *
 * @author roland
 **/
@Configuration
@ComponentScan(basePackages = "org.example.app")
public class AppContextConfig {

}
