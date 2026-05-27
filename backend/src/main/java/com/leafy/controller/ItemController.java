package com.leafy.controller;

import com.leafy.common.CommonResponse;
import com.leafy.dto.item.UserItemResponse;
import com.leafy.entity.Item;
import com.leafy.security.JwtTokenProvider;
import com.leafy.service.ItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Item", description = "상점 및 아이템 관리 API")
@RestController
@RequestMapping("/api/items")
@RequiredArgsConstructor
public class ItemController {

    private final ItemService itemService;
    private final JwtTokenProvider jwtTokenProvider;

    @Operation(summary = "전체 아이템 목록 조회", description = "상점에서 판매 중인 모든 아이템 목록을 조회합니다.")
    @GetMapping
    public CommonResponse<List<Item>> getAllItems() {
        return CommonResponse.success(itemService.getAllItems());
    }

    @Operation(summary = "내 아이템 목록 조회", description = "내가 소유한 모든 아이템 목록을 조회합니다.")
    @GetMapping("/my")
    public CommonResponse<List<UserItemResponse>> getMyItems(Authentication authentication) {
        Long userId = getUserId(authentication);
        return CommonResponse.success(itemService.getUserItems(userId));
    }

    @Operation(summary = "아이템 구매", description = "특정 아이템을 구매하여 내 인벤토리에 추가합니다.")
    @PostMapping("/{itemId}/purchase")
    public CommonResponse<Void> purchaseItem(@PathVariable Long itemId, Authentication authentication) {
        Long userId = getUserId(authentication);
        itemService.purchaseItem(userId, itemId);
        return CommonResponse.success("아이템 구매가 완료되었습니다.", null);
    }

    @Operation(summary = "아이템 장착", description = "내 인벤토리의 아이템을 장착합니다.")
    @PatchMapping("/user-items/{userItemId}/equip")
    public CommonResponse<Void> equipItem(@PathVariable Long userItemId, Authentication authentication) {
        Long userId = getUserId(authentication);
        itemService.equipItem(userId, userItemId);
        return CommonResponse.success("아이템을 장착하였습니다.", null);
    }

    private Long getUserId(Authentication authentication) {
        String token = (String) authentication.getCredentials();
        return jwtTokenProvider.getUserId(token);
    }
}
