package uk.gov.hmcts.reform.rpa.papi.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.ResponseEntity.ok;

/**
 * Default endpoints per application.
 */
@RestController
public class RootController {


    private static final Logger log = LoggerFactory.getLogger(RootController.class);

    /**
     * Root GET endpoint.
     *
     * <p>Azure application service has a hidden feature of making requests to root endpoint when
     * "Always On" is turned on.
     * This is the endpoint to deal with that and therefore silence the unnecessary 404s as a response code.
     *
     * @return Welcome message from the service.
     */
    @GetMapping("/hello")
    public ResponseEntity<String> welcome() {
        log.error("is that an welcome error ");
        return ok("Welcome to Professional API");
    }

    @GetMapping("/")
    public ResponseEntity<String> ping() {
        log.error("is that an ping error ");
        return ok("pong");
    }

    @GetMapping("/true")
    public ResponseEntity<Boolean> isTrue() {
        log.error("is that an true error ");
        return ok(true);
    }

}
