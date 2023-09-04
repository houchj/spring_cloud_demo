package com.houchj.mytask.service;

import com.houchj.mytask.data.Task;
import com.houchj.mytask.repo.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;

@Service
@Transactional
public class TaskService {

    @Autowired
    private TaskRepository taskRepository;

    public List<Task> getAll() {
        return taskRepository.findAll();
    }

    public boolean updateTask(long id, Task task) {
        boolean exist = taskRepository.existsById(id);
        if (!exist) return false;
        if (task == null) return false;

        Task old = taskRepository.findById(id).get();
        if (task.getName() != null)
            old.setName(task.getName());
        if (task.getDescription() != null)
            old.setDescription(task.getDescription());
        taskRepository.save(task);
        return true;
    }

    public Task createTask(Task task) {
        if (task == null) return null;
        return taskRepository.save(task);
    }

    public boolean deleteTask(Long id) {
        boolean exist = taskRepository.existsById(id);
        if (!exist) return false;
        taskRepository.deleteById(id);
        return true;
    }

    public Task getTask(Long id) {
        boolean exist = taskRepository.existsById(id);
        if (!exist) return null;
        return taskRepository.findById(id).get();
    }
}
