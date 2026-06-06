package com.narae.repository;

import com.narae.entity.Todo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TodoRepository extends JpaRepository<Todo, Long> {
    List<Todo> findAllByUserIdOrderByDueDateAsc(Long userId);
    boolean existsByUserIdAndCreatedAtAfter(Long userId, java.time.LocalDateTime date);
}
