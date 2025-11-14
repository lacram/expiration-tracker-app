package com.expirationtracker.controller;

import com.expirationtracker.dto.OcrRequest;
import com.expirationtracker.dto.OcrResponse;
import com.expirationtracker.service.OcrService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ocr")
@RequiredArgsConstructor
public class OcrController {

    private final OcrService ocrService;

    @PostMapping("/process")
    public ResponseEntity<OcrResponse> processImage(@RequestBody OcrRequest request) {
        OcrResponse response = ocrService.processImage(request.getImageBase64());
        return ResponseEntity.ok(response);
    }
}
