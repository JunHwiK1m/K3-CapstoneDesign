package com.leafy.repository;

import com.leafy.entity.Emotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface EmotionRepository extends JpaRepository<Emotion, Long> {
    Optional<Emotion> findByJournalId(Long journalId);

    @Query("SELECT e FROM Emotion e JOIN e.journal j WHERE j.user.id = :userId AND e.analyzedAt >= :since")
    List<Emotion> findAllByUserIdAndAnalyzedAtAfter(@Param("userId") Long userId, @Param("since") LocalDateTime since);
}
