package com.crazymaker.springcloud.hystrix.test;

import com.netflix.hystrix.HystrixCommand;
import com.netflix.hystrix.HystrixCommandGroupKey;

public class CircleAreaCalculatorCommand extends HystrixCommand<Double> {

    private final Double radius;

    public CircleAreaCalculatorCommand(Double radius) {
        super(HystrixCommandGroupKey.Factory.asKey("ExampleGroup"));
        this.radius = radius;
    }

    @Override
    protected Double run() throws Exception {
        return Math.PI * (radius * radius);
    }

    @Override
    protected String getCacheKey() {
        return String.valueOf(radius);
    }
}
