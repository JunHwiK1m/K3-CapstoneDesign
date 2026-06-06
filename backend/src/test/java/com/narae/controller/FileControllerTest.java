package com.narae.controller;

import com.narae.service.StorageService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@org.springframework.test.context.ActiveProfiles("test")
public class FileControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private StorageService storageService;

    @Test
    @DisplayName("파일 업로드 성공 테스트")
    @WithMockUser
    void uploadFile_Success() throws Exception {
        // given
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "test image content".getBytes()
        );
        given(storageService.store(any())).willReturn("http://localhost:8080/uploads/test.jpg");

        // when & then
        mockMvc.perform(multipart("/api/files/upload")
                        .file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").value("http://localhost:8080/uploads/test.jpg"));
    }

    @Test
    @DisplayName("다중 파일 업로드 성공 테스트")
    @WithMockUser
    void uploadFiles_Success() throws Exception {
        // given
        MockMultipartFile file1 = new MockMultipartFile("files", "test1.jpg", MediaType.IMAGE_JPEG_VALUE, "content1".getBytes());
        MockMultipartFile file2 = new MockMultipartFile("files", "test2.jpg", MediaType.IMAGE_JPEG_VALUE, "content2".getBytes());
        
        given(storageService.storeAll(any())).willReturn(List.of(
                "http://localhost:8080/uploads/test1.jpg",
                "http://localhost:8080/uploads/test2.jpg"
        ));

        // when & then
        mockMvc.perform(multipart("/api/files/upload-multiple")
                        .file(file1)
                        .file(file2))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0]").value("http://localhost:8080/uploads/test1.jpg"))
                .andExpect(jsonPath("$.data[1]").value("http://localhost:8080/uploads/test2.jpg"));
    }
}
