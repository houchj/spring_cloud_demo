package com.houchj.mytask.controller;

import com.houchj.mytask.data.Task;
import com.houchj.mytask.service.TaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "tasks")
public class TaskController {

    @Autowired
    TaskService taskService;

    @RequestMapping(value="hello")
    public String hello() {
        return "Hello from test controller";
    }

    @RequestMapping(method = RequestMethod.GET)
    public List<Task> tasks() {
        return taskService.getAll();
    }

    @PatchMapping(path = "/{id}")
    public ResponseEntity putTask(@PathVariable(name = "id") Long id, @RequestBody Task task) {
        boolean updated = taskService.updateTask(id, task);
        if (!updated)
            return new ResponseEntity(HttpStatus.NOT_FOUND);
        return new ResponseEntity(HttpStatus.OK);
    }

    @GetMapping(path = "/{id}")
    public ResponseEntity getTask(@PathVariable(name = "id") Long id) {
        Task task = taskService.getTask(id);
        if (task == null)
            return new ResponseEntity(HttpStatus.NOT_FOUND);
        return new ResponseEntity(task, HttpStatus.OK);
    }

    @DeleteMapping(path = "/{id}")
    public ResponseEntity delTask(@PathVariable(name = "id") Long id) {
        boolean deleted = taskService.deleteTask(id);
        if (!deleted)
            return new ResponseEntity(HttpStatus.NOT_FOUND);
        return new ResponseEntity(HttpStatus.OK);
    }

    @PostMapping
    @ResponseBody
    public ResponseEntity createTask(@RequestBody Task task) {
        if (taskService.createTask(task) == null)
            return new ResponseEntity(HttpStatus.BAD_REQUEST);
        return new ResponseEntity(HttpStatus.CREATED);
    }


}
