Feature: test script

  Background:
    * url 'http://localhost:8080/tasks'

  Scenario: get all tasks
    Given path ''
    When method get
    Then status 200
    Then print response

  Scenario: patch one task
    Given path '/1'
    Given request '{"id":1, "name":"patched name for task1", "description":"sss"}'
    And header Content-Type = 'application/json'
    When method patch
    Then status 200
    Then print response
    * def last = response[]

  Scenario: get one task
    Given path '/1'
    And header Content-Type = 'application/json'
    When method get
    Then status 200
    Then print response

  Scenario: get one task that doesn't exist
    Given path '/199999'
    And header Content-Type = 'application/json'
    When method get
    Then status 404
    Then print response

  Scenario: create one task with auto generate ID
    Given path ''
    Given request '{"name":"posted name for task", "description":"sss posted"}'
    And header Content-Type = 'application/json'
    When method post
    Then status 201
    Then print response

  Scenario: create one task with specified ID
    Given path ''
    Given request '{"id":9, "name":"posted name for task", "description":"sss posted"}'
    And header Content-Type = 'application/json'
    When method post
    Then status 201
    Then print response

  Scenario: delete one task
    Given path '/12'
    And header Content-Type = 'application/json'
    When method delete
    Then status 200
    Then print response

  Scenario: delete one task that doesn't exist
    Given path '/99999'
    And header Content-Type = 'application/json'
    When method delete
    Then status 404
    Then print response

