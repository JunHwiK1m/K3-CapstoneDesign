package com.leafy.repository;

import com.leafy.entity.Todo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TodoRepository extends JpaRepository<Todo, Long> {
    List<Todo> findAllByUserIdOrderByDueDateAsc(Long userId);
}
