import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../data/models/gift_card_model.dart';
import '../providers/gift_card_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _memoController = TextEditingController();

  String _selectedCategory = Category.giftcard;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String? _imageBase64;
  File? _imageFile;
  bool _isProcessingOcr = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // 사진 촬영
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (photo != null) {
      await _processImage(photo);
    }
  }

  // 갤러리에서 선택
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      await _processImage(image);
    }
  }

  // 이미지 처리 및 OCR
  Future<void> _processImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    setState(() {
      _imageFile = File(image.path);
      _imageBase64 = base64Image;
    });

    // OCR 처리
    if (mounted) {
      final shouldProcessOcr = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('OCR 처리'),
          content: const Text('이미지에서 정보를 자동으로 추출하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('수동 입력'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OCR 처리'),
            ),
          ],
        ),
      );

      if (shouldProcessOcr == true && mounted) {
        await _performOcr(base64Image);
      }
    }
  }

  // OCR 수행
  Future<void> _performOcr(String imageBase64) async {
    setState(() => _isProcessingOcr = true);

    final provider = Provider.of<GiftCardProvider>(context, listen: false);
    final response = await provider.processImageOcr(imageBase64);

    setState(() => _isProcessingOcr = false);

    if (response != null && response.success && mounted) {
      // OCR 결과를 폼에 채우기
      if (response.name != null && response.name!.isNotEmpty) {
        _nameController.text = response.name!;
      }
      if (response.barcode != null && response.barcode!.isNotEmpty) {
        _barcodeController.text = response.barcode!;
      }
      if (response.parsedExpirationDate != null) {
        setState(() {
          _selectedDate = response.parsedExpirationDate!;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?.message ?? 'OCR 처리에 실패했습니다'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // 날짜 선택
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10년
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 카드 저장
  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final card = GiftCard(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      expirationDate: _selectedDate,
      status: CardStatus.active,
      imageBase64: _imageBase64,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      memo: _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim(),
    );

    final provider = Provider.of<GiftCardProvider>(context, listen: false);
    final success = await provider.createCard(card);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카드가 등록되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? '카드 등록에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 등록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 이미지 선택/미리보기
              if (_imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      _imageBase64 = null;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('이미지 삭제'),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('사진 촬영'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('갤러리'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // OCR 처리 중 표시
              if (_isProcessingOcr) ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('이미지 분석 중...'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 카드 이름
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '카드 이름',
                  hintText: '예: 스타벅스 아메리카노',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '카드 이름을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 카테고리
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: Category.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(Category.toDisplayName(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 유효기간
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '유효기간',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormat.format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // 바코드
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: '바코드 번호 (선택)',
                  hintText: '숫자 입력',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 메모
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '예: 생일 선물로 받음',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // 저장 버튼
              Consumer<GiftCardProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveCard,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('저장', style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
