import 'package:flutter/material.dart';
import 'package:jobhud/models/career_tip_model.dart';
import 'package:jobhud/services/tips_service.dart';
import 'package:share_plus/share_plus.dart';

class DailyTipScreen extends StatefulWidget {
  const DailyTipScreen({super.key});

  @override
  State<DailyTipScreen> createState() => _DailyTipScreenState();
}

class _DailyTipScreenState extends State<DailyTipScreen> {
  List<CareerTip> _dailyTips = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
  }

  Future<void> _loadDailyTip() async {
    await _getNewTip(); // Reuse the same logic as _getNewTip for consistency
  }

  Future<void> _getNewTip() async {
    setState(() => _isLoading = true);

    try {
      final tips = await TipsService.getRandomTips(count: 3);
      if (mounted) {
        setState(() {
          _dailyTips = tips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _shareTip(CareerTip tip) {
    Share.share(
      '💡 ${tip.title}\n\n${tip.tip}\n\n- Shared from JobHud',
      subject: 'Career Tip',
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'people': Icons.people,
      'description': Icons.description,
      'school': Icons.school,
      'email': Icons.email,
      'star': Icons.star,
      'videocam': Icons.videocam,
      'flag': Icons.flag,
      'search': Icons.search,
      'badge': Icons.badge,
      'favorite': Icons.favorite,
      'trending_up': Icons.trending_up,
      'help': Icons.help_outline,
      'work': Icons.work,
      'schedule': Icons.schedule,
      'feedback': Icons.feedback,
      'checkroom': Icons.checkroom,
      'notifications': Icons.notifications,
      'psychology': Icons.psychology,
      'newspaper': Icons.newspaper,
      'emoji_events': Icons.emoji_events,
    };
    return iconMap[iconName] ?? Icons.lightbulb;
  }

  Color _getCategoryColor(String category) {
    final colorMap = {
      'networking': Colors.blue,
      'resume': Colors.purple,
      'skills': Colors.orange,
      'interview': Colors.green,
      'branding': Colors.pink,
      'motivation': Colors.red,
      'job_search': Colors.teal,
    };
    return colorMap[category] ?? Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Career Tips'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadDailyTip,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _dailyTips.isEmpty
                  ? const Center(
                      child: Text('No tips available'),
                    )
                  : RefreshIndicator(
                      onRefresh: _getNewTip,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Badge
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Tip of the moment',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tips List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _dailyTips.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final tip = _dailyTips[index];
                                return _buildTipCard(tip);
                              },
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _getNewTip,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('New Tip'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(color: _getCategoryColor(_dailyTips[0].category)),
                                      foregroundColor: _getCategoryColor(_dailyTips[0].category),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _shareTip(_dailyTips[0]),
                                    icon: const Icon(Icons.share),
                                    label: const Text('Share'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: _getCategoryColor(_dailyTips[0].category),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.format_quote, color: Colors.grey[400], size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your career journey starts with small steps every day.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }


  Widget _buildTipCard(CareerTip tip) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(tip.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconData(tip.icon),
                    color: _getCategoryColor(tip.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () => _shareTip(tip),
                  tooltip: 'Share tip',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip.tip,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(tip.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tip.category.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: _getCategoryColor(tip.category),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
