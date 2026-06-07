package com.narae.service;

import com.narae.exception.BusinessException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.util.FileSystemUtils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
public class LocalStorageServiceTest {

    @Autowired
    private LocalStorageService localStorageService;

    private final String uploadDir = "./test-uploads/";

    @BeforeEach
    void setUp() throws IOException {
        Files.createDirectories(Paths.get(uploadDir));
    }

    @AfterEach
    void tearDown() throws IOException {
        FileSystemUtils.deleteRecursively(Paths.get(uploadDir));
    }

    @Test
    @DisplayName("파일 저장 및 URL 반환 테스트")
    void store_Success() {
        // given
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test-image.png",
                "image/png",
                "test data".getBytes()
        );

        // when
        String url = localStorageService.store(file);

        // then
        assertThat(url).startsWith("http://localhost:8080/uploads/");
        String fileName = url.substring(url.lastIndexOf("/") + 1);
        assertThat(Files.exists(Paths.get(uploadDir).resolve(fileName))).isTrue();
    }

    @Test
    @DisplayName("다중 파일 저장 테스트")
    void storeAll_Success() {
        // given
        MockMultipartFile file1 = new MockMultipartFile("files", "1.txt", "text/plain", "data1".getBytes());
        MockMultipartFile file2 = new MockMultipartFile("files", "2.txt", "text/plain", "data2".getBytes());

        // when
        List<String> urls = localStorageService.storeAll(List.of(file1, file2));

        // then
        assertThat(urls).hasSize(2);
        urls.forEach(url -> {
            String fileName = url.substring(url.lastIndexOf("/") + 1);
            assertThat(Files.exists(Paths.get(uploadDir).resolve(fileName))).isTrue();
        });
    }
}
