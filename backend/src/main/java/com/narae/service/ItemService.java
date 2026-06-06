package com.narae.service;

import com.narae.dto.item.UserItemResponse;
import com.narae.entity.Item;
import com.narae.entity.User;
import com.narae.entity.UserItem;
import com.narae.exception.BusinessException;
import com.narae.exception.ErrorCode;
import com.narae.repository.ItemRepository;
import com.narae.repository.UserItemRepository;
import com.narae.repository.UserRepository;
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

        // Unequip previous items of the same type
        com.narae.entity.ItemType targetType = userItem.getItem().getItemType();
        userItemRepository.findAllByUserId(userId).stream()
                .filter(ui -> ui.isEquipped() && ui.getItem().getItemType() == targetType)
                .forEach(UserItem::unequip);

        userItem.equip();
    }

    @Transactional
    public void unequipItem(Long userId, Long userItemId) {
        UserItem userItem = userItemRepository.findById(userItemId)
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_INPUT_VALUE));

        if (!userItem.getUser().getId().equals(userId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }

        userItem.unequip();
    }

    /**
     * 장착 중인 아이템 기반의 추천 컨텐츠 필터링 로직 (T032 고도화 예시)
     */
    public String getActivePersonaStyle(Long userId) {
        return userItemRepository.findAllByUserId(userId).stream()
                .filter(ui -> ui.isEquipped() && ui.getItem().getItemType() == com.narae.entity.ItemType.PERSONA)
                .findFirst()
                .map(ui -> ui.getItem().getItemName())
                .orElse("DEFAULT");
    }
}
