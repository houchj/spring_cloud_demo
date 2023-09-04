package com.houchj.mytask.repo;

import com.houchj.mytask.data.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository//optional
public interface TaskRepository extends JpaRepository<Task, Long> {

}
