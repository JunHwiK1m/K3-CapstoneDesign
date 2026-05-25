package com.leafy.dto.item;

import com.leafy.entity.ItemType;
import com.leafy.entity.UserItem;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
@Schema(description = "사용자 소유 아이템 조회 응답")
public record UserItemResponse(
    @Schema(description = "사용자 아이템 ID", example = "1")
    Long userItemId,

    @Schema(description = "아이템 ID", example = "1")
    Long itemId,

    @Schema(description = "아이템 이름", example = "기본 페르소나")
    String itemName,

    @Schema(description = "아이템 타입", example = "PERSONA")
    ItemType itemType,

    @Schema(description = "리소스 URL", example = "https://example.com/item.png")
    String resourceUrl,

    @Schema(description = "장착 여부", example = "true")
    boolean isEquipped,

    @Schema(description = "구매 일시")
    LocalDateTime purchasedAt
) {
    public static UserItemResponse from(UserItem userItem) {
        return UserItemResponse.builder()
                .userItemId(userItem.getId())
                .itemId(userItem.getItem().getId())
                .itemName(userItem.getItem().getItemName())
                .itemType(userItem.getItem().getItemType())
                .resourceUrl(userItem.getItem().getResourceUrl())
                .isEquipped(userItem.isEquipped())
                .purchasedAt(userItem.getPurchasedAt())
                .build();
    }
}
