package com.leafy.controller;

import com.leafy.common.CommonResponse;
import com.leafy.service.StorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Tag(name = "File", description = "파일 업로드 API")
@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    private final StorageService storageService;

    @Operation(summary = "단일 파일 업로드", description = "이미지 또는 음성 파일을 업로드하고 접근 가능한 URL을 반환합니다.")
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CommonResponse<String> uploadFile(@RequestPart("file") MultipartFile file) {
        String url = storageService.store(file);
        return CommonResponse.success("파일 업로드 성공", url);
    }

    @Operation(summary = "다중 파일 업로드", description = "여러 개의 파일을 업로드하고 접근 가능한 URL 리스트를 반환합니다.")
    @PostMapping(value = "/upload-multiple", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CommonResponse<List<String>> uploadFiles(@RequestPart("files") List<MultipartFile> files) {
        List<String> urls = storageService.storeAll(files);
        return CommonResponse.success("다중 파일 업로드 성공", urls);
    }
}
