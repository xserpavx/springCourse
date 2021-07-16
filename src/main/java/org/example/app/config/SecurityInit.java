package org.example.app.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.web.context.AbstractSecurityWebApplicationInitializer;

/**
 * Created on 17.07.2021
 *
 * @author roland
 **/

public class SecurityInit extends AbstractSecurityWebApplicationInitializer {
    private final static Logger log = LoggerFactory.getLogger(SecurityInit.class);
}
