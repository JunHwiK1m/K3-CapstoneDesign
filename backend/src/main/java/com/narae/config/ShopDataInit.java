package com.narae.config;

import com.narae.entity.Item;
import com.narae.entity.ItemType;
import com.narae.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class ShopDataInit implements CommandLineRunner {

    private final ItemRepository itemRepository;

    @Override
    public void run(String... args) {
        // 상점 테이블에 데이터가 없으면 초기 테스트 데이터를 추가합니다.
        if (itemRepository.count() == 0) {
            log.info("상점(Item) 데이터가 비어있어 기본 테스트 품목을 추가합니다.");

            List<Item> defaultItems = List.of(
                Item.builder()
                    .itemName("다크 모드 테마")
                    .itemType(ItemType.THEME)
                    .price(300)
                    .resourceUrl("theme_dark")
                    .build()
            );

            itemRepository.saveAll(defaultItems);
            log.info("총 {}개의 상점 품목이 등록되었습니다.", defaultItems.size());
        }
    }
}
