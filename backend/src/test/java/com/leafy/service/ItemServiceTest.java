package com.leafy.service;

import com.leafy.dto.item.UserItemResponse;
import com.leafy.entity.Item;
import com.leafy.entity.UserItem;
import com.leafy.repository.ItemRepository;
import com.leafy.repository.UserItemRepository;
import com.leafy.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;

@ExtendWith(MockitoExtension.class)
class ItemServiceTest {

    @InjectMocks
    private ItemService itemService;

    @Mock
    private ItemRepository itemRepository;

    @Mock
    private UserItemRepository userItemRepository;

    @Mock
    private UserRepository userRepository;

    @Test
    @DisplayName("사용자 소유 아이템 목록 조회 테스트")
    void getUserItemsTest() {
        // Given
        Long userId = 1L;
        Item item = Item.builder().id(100L).itemName("테스트 아이템").build();
        UserItem userItem = UserItem.builder().id(1L).item(item).isEquipped(false).build();
        
        given(userItemRepository.findAllByUserId(userId))
                .willReturn(List.of(userItem));

        // When
        List<UserItemResponse> result = itemService.getUserItems(userId);

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).itemName()).isEqualTo("테스트 아이템");
        assertThat(result.get(0).userItemId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("장착 중인 아이템 기반 페르소나 스타일 조회 테스트")
    void getActivePersonaStyleTest() {
        // Given
        Long userId = 1L;
        Item item = Item.builder().itemName("FRIENDLY_BOT").build();
        UserItem userItem = UserItem.builder().item(item).isEquipped(true).build();
        
        given(userItemRepository.findByUserIdAndIsEquippedTrue(userId))
                .willReturn(Optional.of(userItem));

        // When
        String result = itemService.getActivePersonaStyle(userId);

        // Then
        assertThat(result).isEqualTo("FRIENDLY_BOT");
    }
}
