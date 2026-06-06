package com.narae.repository;

import com.narae.entity.Journal;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface JournalRepository extends JpaRepository<Journal, Long> {
    List<Journal> findAllByUserIdOrderByCreatedAtDesc(Long userId);
    boolean existsByUserIdAndCreatedAtAfter(Long userId, LocalDateTime dateTime);
}
