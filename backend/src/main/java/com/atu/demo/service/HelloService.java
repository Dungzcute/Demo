package com.atu.demo.service;

import java.util.concurrent.ThreadLocalRandom;
import org.springframework.stereotype.Service;

@Service
public class HelloService {
    public String getMessage() {
        return ThreadLocalRandom.current().nextBoolean() ? "Đỏ gay" : "Đỏ ngu";
    }
}
