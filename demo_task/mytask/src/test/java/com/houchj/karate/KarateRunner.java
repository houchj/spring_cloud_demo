package com.houchj.karate;

import com.intuit.karate.junit5.Karate;

/**
 * @note start up task spring boot application before starting the test, it's api testing.
 */
public class KarateRunner {

    @Karate.Test
    Karate testUsers() {
        return Karate.run("taskCases").relativeTo(getClass());
    }
}
