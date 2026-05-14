package com.leafy.repository;

import com.leafy.entity.UserItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserItemRepository extends JpaRepository<UserItem, Long> {
    List<UserItem> findAllByUserId(Long userId);
    Optional<UserItem> findByUserIdAndIsEquippedTrue(Long userId);
}
