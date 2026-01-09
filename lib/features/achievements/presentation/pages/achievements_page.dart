import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/gamification_service.dart';
import '../../../../models/achievement_model.dart';
import '../../../auth/data/user_service.dart';
import '../../../../utils/backfill_points.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final _firebaseService = FirebaseService();
  final _gamificationService = GamificationService();
  final _userService = UserService();
  final _backfillUtility = BackfillPointsUtility();

  bool _isLoading = true;
  bool _isBackfilling = false;
  List<Achievement> _achievements = [];
  int _userPoints = 0;
  int _userLevel = 1;
  int _nextLevelPoints = 100;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final user = _firebaseService.currentUser;
      if (user == null) return;

      // Get user data
      final userData = await _userService.getUser(user.uid);
      final points = userData?.points ?? 0;
      final level = _gamificationService.calculateLevel(points);
      final nextLevel = _gamificationService.pointsForNextLevel(level);

      // Get all achievements
      final achievements = await _gamificationService.getUserAchievements(
        user.uid,
      );

      if (mounted) {
        setState(() {
          _userPoints = points;
          _userLevel = level;
          _nextLevelPoints = nextLevel;
          _achievements = achievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _backfillPoints() async {
    setState(() => _isBackfilling = true);

    try {
      final result = await _backfillUtility.backfillAllPoints();

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Puntos actualizados! ${result['totalPoints']} pts por ${result['incomeCount']} ingresos y ${result['expenseCount']} gastos',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          // Wait a moment for Firebase to propagate changes
          await Future.delayed(const Duration(milliseconds: 500));
          await _loadData(); // Reload to show new points
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackfilling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final unlockedAchievements = _achievements
        .where((a) => a.isUnlocked)
        .toList();
    final lockedAchievements = _achievements
        .where((a) => !a.isUnlocked)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Logros y Progreso',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),

            // Level Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tu Nivel',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Nivel $_userLevel',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            '$_userPoints pts',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso al Nivel ${_userLevel + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$_userPoints / $_nextLevelPoints',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _userPoints / _nextLevelPoints,
                          minHeight: 12,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sync Points Button (only show if points are 0)
            if (_userPoints == 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¿Tienes transacciones pero no puntos?',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sincroniza tus puntos para recibir crédito por tus transacciones anteriores.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isBackfilling ? null : _backfillPoints,
                      icon: _isBackfilling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(
                        _isBackfilling
                            ? 'Sincronizando...'
                            : 'Sincronizar Puntos',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Unlocked Achievements
            if (unlockedAchievements.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Desbloqueados',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${unlockedAchievements.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...unlockedAchievements.map(
                (achievement) => _buildAchievementCard(achievement, true),
              ),
              const SizedBox(height: 24),
            ],

            // Locked Achievements
            if (lockedAchievements.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Por Desbloquear',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lockedAchievements.length}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...lockedAchievements.map(
                (achievement) => _buildAchievementCard(achievement, false),
              ),
            ],

            // Empty State
            if (_achievements.isEmpty) ...[
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin logros aún',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comienza a usar la app para desbloquear logros',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: isUnlocked
            ? Border.all(color: AppTheme.secondaryColor.withOpacity(0.3))
            : null,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppTheme.secondaryColor.withOpacity(0.1)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getAchievementIcon(achievement.type),
              color: isUnlocked
                  ? AppTheme.secondaryColor
                  : Colors.grey.shade600,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked
                        ? Colors.grey.shade600
                        : Colors.grey.shade500,
                  ),
                ),
                if (isUnlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Desbloqueado: ${_formatDate(achievement.unlockedAt!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.secondaryColor
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${achievement.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String type) {
    switch (type) {
      case 'first_expense':
        return Icons.shopping_cart;
      case 'first_income':
        return Icons.account_balance_wallet;
      case 'streak_7':
      case 'streak_30':
        return Icons.local_fire_department;
      case 'budget_set':
        return Icons.savings;
      case 'expense_50':
      case 'expense_100':
        return Icons.receipt_long;
      case 'savings_goal':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
