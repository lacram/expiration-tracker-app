import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/gift_card_model.dart';
import '../providers/gift_card_provider.dart';
import '../widgets/card_list_item.dart';
import 'add_card_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<GiftCardProvider>(context, listen: false);
    await provider.loadCards();
    await provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유효기간 관리'),
        actions: [
          // 필터 버튼
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Consumer<GiftCardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '등록된 카드가 없습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '하단의 + 버튼을 눌러 카드를 등록하세요',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final filteredCards = provider.filteredCards;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              children: [
                // 통계 표시
                if (provider.stats != null) _buildStatsCard(provider.stats!),

                // 카드 목록
                Expanded(
                  child: filteredCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                '필터 조건에 맞는 카드가 없습니다',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            return CardListItem(card: filteredCards[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('카드 등록'),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('전체', stats['total'] ?? 0, Colors.blue),
                _buildStatItem('사용 가능', stats['active'] ?? 0, Colors.green),
                _buildStatItem('만료', stats['expired'] ?? 0, Colors.red),
                _buildStatItem('사용 완료', stats['used'] ?? 0, Colors.grey),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('7일 이내', stats['expiringSoon7'] ?? 0, Colors.orange),
                _buildStatItem('30일 이내', stats['expiringSoon30'] ?? 0, Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    final provider = Provider.of<GiftCardProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('전체'),
                    selected: provider.selectedStatus == null,
                    onSelected: (selected) {
                      provider.setStatusFilter(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...CardStatus.values.map((status) => FilterChip(
                        label: Text(CardStatus.toDisplayName(status)),
                        selected: provider.selectedStatus == status,
                        onSelected: (selected) {
                          provider.setStatusFilter(selected ? status : null);
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
              const SizedBox(height: 16),
              const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('전체'),
                    selected: provider.selectedCategory == null,
                    onSelected: (selected) {
                      provider.setCategoryFilter(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...Category.values.map((category) => FilterChip(
                        label: Text(Category.toDisplayName(category)),
                        selected: provider.selectedCategory == category,
                        onSelected: (selected) {
                          provider.setCategoryFilter(selected ? category : null);
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
