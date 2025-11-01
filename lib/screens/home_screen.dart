import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../view_models/home_screen_view_model.dart';
import '../view_models/settings_view_model.dart';
import 'add_transaction_screen.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'transaction_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final HomeScreenViewModel _viewModel = HomeScreenViewModel();

  int _selectedIndex = 0;
  int _currentPage = 0;
  bool _isLoadingMore = false;

  // ✅ THÊM: Reset pagination khi Stream rebuild
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset khi có dữ liệu mới (Stream rebuild)
    if (mounted) {
      setState(() {
        _currentPage = 0;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackground(settings.isDarkMode),
      appBar: _buildAppBar(settings, textTheme),
      body: StreamBuilder<List<Transaction>>(
        stream: _dbService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppConstants.errorMessage,
                style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final transactions = snapshot.data!;
          final summary = _viewModel.calculateSummary(transactions);

          // ✅ AN TOÀN: Reset nếu total < page hiện tại
          if (transactions.length <
              _currentPage * AppConstants.transactionsPerPage) {
            _currentPage = 0;
            _isLoadingMore = false;
          }

          final pagedTransactions = _viewModel.getPagedTransactions(
            transactions,
            _currentPage,
            AppConstants.transactionsPerPage,
          );

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.extentAfter < 300 &&
                  !_isLoadingMore &&
                  pagedTransactions.length < transactions.length) {
                _loadMoreTransactions(transactions.length);
              }
              return false;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(summary, settings, textTheme),
                _buildTransactionList(pagedTransactions, settings),
                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(settings),
    );
  }

  void _loadMoreTransactions(int total) {
    if (_isLoadingMore ||
        _currentPage * AppConstants.transactionsPerPage >= total) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoadingMore = false); // ĐÃ SỬA: BỎ DẤU GẠCH NGANG
      }
    });
  }

  // ------------------ UI COMPONENTS ------------------

  PreferredSizeWidget _buildAppBar(SettingsViewModel vm, TextTheme textTheme) {
    return AppBar(
      backgroundColor: vm.themeColor,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.greeting,
            style: textTheme.bodySmall?.copyWith(
              color: AppConstants.textSecondary(vm.isDarkMode),
            ),
          ),
          Text(
            AppConstants.appTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: vm.isDarkMode ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: AppConstants.avatarRadius,
            backgroundColor: AppConstants.cardBackground(vm.isDarkMode),
            child: Icon(
              Icons.person,
              color: vm.isDarkMode ? Colors.white70 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    Map<String, double> summary,
    SettingsViewModel vm,
    TextTheme textTheme,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(AppConstants.cardPadding),
              decoration: BoxDecoration(
                color: vm.themeColor,
                borderRadius: BorderRadius.circular(
                  AppConstants.cardBorderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _viewModel.getCurrentMonthYear(),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondary(vm.isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.formatCurrency(
                      summary['balance'] ?? 0,
                      vm.currency,
                    ),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.balanceLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondary(vm.isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        AppConstants.incomeLabel,
                        summary['income'] ?? 0,
                        AppConstants.incomeColor,
                        vm,
                      ),
                      _buildSummaryItem(
                        AppConstants.expenseLabel,
                        summary['expense'] ?? 0,
                        AppConstants.expenseColor,
                        vm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppConstants.recentTransactions,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: vm.isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    List<Transaction> transactions,
    SettingsViewModel vm,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final t = transactions[index];
        final isIncome = t.type == 'income';

        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: AppConstants.listItemMargin,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppConstants.cardBackground(vm.isDarkMode),
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: AppConstants.shadowColor.withOpacity(0.1),
                blurRadius: AppConstants.shadowBlurRadius,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: AppConstants.avatarRadius,
              backgroundColor:
                  (isIncome
                          ? AppConstants.incomeColor
                          : AppConstants.expenseColor)
                      .withOpacity(0.1),
              child: Icon(
                isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: isIncome
                    ? AppConstants.incomeColor
                    : AppConstants.expenseColor,
              ),
            ),
            title: Text(
              t.category,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(t.date),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              "${isIncome ? '+' : '-'}${AppConstants.formatCurrency(t.amount, vm.currency)}",
              style: TextStyle(
                color: isIncome
                    ? AppConstants.incomeColor
                    : AppConstants.expenseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionDetailScreen(transaction: t),
              ),
            ),
          ),
        );
      }, childCount: transactions.length),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            AppConstants.noTransactions,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text(AppConstants.addTransactionButton),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double value,
    Color color,
    SettingsViewModel vm,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: AppConstants.textSecondary(vm.isDarkMode)),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.formatCurrency(value, vm.currency),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  ConvexAppBar _buildBottomNav(SettingsViewModel vm) {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,
      backgroundColor: AppConstants.cardBackground(vm.isDarkMode),
      color: Colors.grey.shade600,
      activeColor: vm.themeColor,
      elevation: 8,
      items: const [
        TabItem(icon: Icons.home_rounded, title: 'Trang chủ'),
        TabItem(icon: Icons.pie_chart_rounded, title: 'Biểu đồ'),
        TabItem(icon: Icons.add, title: ''),
        TabItem(icon: Icons.bar_chart_rounded, title: 'Báo cáo'),
        TabItem(icon: Icons.settings_rounded, title: 'Cài đặt'),
      ],
      initialActiveIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);

        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpenseScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IncomeScreen()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
            break;
        }
      },
    );
  }
}
