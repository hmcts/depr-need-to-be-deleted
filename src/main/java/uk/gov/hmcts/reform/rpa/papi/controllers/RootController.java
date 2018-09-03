package uk.gov.hmcts.reform.rpa.papi.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.ResponseEntity.ok;

/**
 * Default endpoints per application.
 */
@RestController
public class RootController {

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
        return ok("Welcome to Professional API");
    }

    @GetMapping()
    public ResponseEntity<String> ping() {
        return ok("pong");
    }

    @GetMapping("/true")
    public ResponseEntity<Boolean> isTrue() {
        return ok(true);
    }

}
