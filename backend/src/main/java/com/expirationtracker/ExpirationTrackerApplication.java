package com.expirationtracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ExpirationTrackerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ExpirationTrackerApplication.class, args);
    }
}
