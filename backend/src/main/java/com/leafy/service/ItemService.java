package com.leafy.service;

import com.leafy.dto.item.UserItemResponse;
import com.leafy.entity.Item;
import com.leafy.entity.User;
import com.leafy.entity.UserItem;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.ItemRepository;
import com.leafy.repository.UserItemRepository;
import com.leafy.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ItemService {

    private final ItemRepository itemRepository;
    private final UserItemRepository userItemRepository;
    private final UserRepository userRepository;

    public List<Item> getAllItems() {
        return itemRepository.findAll();
    }

    public List<UserItemResponse> getUserItems(Long userId) {
        return userItemRepository.findAllByUserId(userId).stream()
                .map(UserItemResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional
    public void purchaseItem(Long userId, Long itemId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_INPUT_VALUE));

        UserItem userItem = UserItem.builder()
                .user(user)
                .item(item)
                .build();
        userItemRepository.save(userItem);
    }

    @Transactional
    public void equipItem(Long userId, Long userItemId) {
        UserItem userItem = userItemRepository.findById(userItemId)
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_INPUT_VALUE));

        if (!userItem.getUser().getId().equals(userId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }

        // Unequip previous item of the same type if needed (simplified here)
        userItemRepository.findByUserIdAndIsEquippedTrue(userId)
                .ifPresent(UserItem::unequip);

        userItem.equip();
    }

    /**
     * 장착 중인 아이템 기반의 추천 컨텐츠 필터링 로직 (T032 고도화 예시)
     */
    public String getActivePersonaStyle(Long userId) {
        return userItemRepository.findByUserIdAndIsEquippedTrue(userId)
                .map(ui -> ui.getItem().getItemName())
                .orElse("DEFAULT");
    }
}
