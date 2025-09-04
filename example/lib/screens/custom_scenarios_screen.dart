import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/cache_provider.dart';

/// 🎯 Custom Scenarios Screen
///
/// Real-world caching scenarios and use cases:
/// - E-commerce product catalog
/// - Social media feed caching
/// - API response caching
/// - User profile management
/// - Dynamic content optimization
/// - Enterprise data patterns
class CustomScenariosScreen extends StatefulWidget {
  const CustomScenariosScreen({super.key});

  @override
  State<CustomScenariosScreen> createState() => _CustomScenariosScreenState();
}

class _CustomScenariosScreenState extends State<CustomScenariosScreen>
    with TickerProviderStateMixin {
  String _selectedUserLevel = 'Beginner';
  String _selectedScenario = '';
  bool _isScenarioRunning = false;
  final Map<String, _ScenarioResult> _scenarioResults = {};
  _ScenarioExecution? _currentExecution;

  // Animation controllers
  late AnimationController _cardController;
  late AnimationController _progressController;
  late AnimationController _resultController;

  final List<String> _userLevels = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _progressController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Scenarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset all scenarios',
            onPressed: _isScenarioRunning ? null : _resetAllScenarios,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Level Selection
            _buildUserLevelSelector(),

            const SizedBox(height: 16),

            // Introduction
            _buildIntroduction(),

            const SizedBox(height: 16),

            // Scenarios Grid
            _buildScenariosGrid(),

            const SizedBox(height: 16),

            // Current Execution Progress
            if (_currentExecution != null) _buildExecutionProgress(),

            const SizedBox(height: 16),

            // Scenario Results
            if (_scenarioResults.isNotEmpty) _buildScenarioResults(),

            const SizedBox(height: 16),

            // Best Practices
            if (_scenarioResults.isNotEmpty) _buildBestPractices(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLevelSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Select Your Experience Level',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _userLevels.map((level) {
                final isSelected = _selectedUserLevel == level;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getUserLevelIcon(level),
                        size: 16,
                        color: isSelected ? Colors.white : null,
                      ),
                      const SizedBox(width: 4),
                      Text(level),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && !_isScenarioRunning) {
                      setState(() {
                        _selectedUserLevel = level;
                        _selectedScenario = '';
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getUserLevelDescription(_selectedUserLevel),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _cardController.value),
          child: Opacity(
            opacity: _cardController.value,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Real-World Caching Scenarios',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getIntroText(_selectedUserLevel),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tips_and_updates,
                              color: Colors.amber[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getTipText(_selectedUserLevel),
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontSize: 12,
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
          ),
        );
      },
    );
  }

  Widget _buildScenariosGrid() {
    final scenarios = _getScenariosForUserLevel(_selectedUserLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Scenarios',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _selectedUserLevel == 'Beginner' ? 1 : 2,
            childAspectRatio: _selectedUserLevel == 'Beginner' ? 2.5 : 1.3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            return _buildScenarioCard(scenarios[index]);
          },
        ),
      ],
    );
  }

  Widget _buildScenarioCard(_CustomScenario scenario) {
    final isSelected = _selectedScenario == scenario.name;
    final hasResult = _scenarioResults.containsKey(scenario.name);
    final isRunning = _currentExecution?.scenarioName == scenario.name;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isRunning ? Colors.blue[50] : null,
        child: InkWell(
          onTap: _isScenarioRunning ? null : () => _runScenario(scenario),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scenario.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(scenario.icon, color: scenario.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scenario.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (_selectedUserLevel != 'Beginner') ...[
                            const SizedBox(height: 4),
                            Text(
                              scenario.category,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasResult)
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  scenario.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: _selectedUserLevel == 'Beginner' ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scenario.industry,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getComplexityColor(scenario.complexity)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        scenario.complexity,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getComplexityColor(scenario.complexity),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasResult && _selectedUserLevel != 'Beginner') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Success Rate: ${(_scenarioResults[scenario.name]!.successRate * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionProgress() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Running: ${_currentExecution!.scenarioName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentExecution!.currentStep,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: Colors.blue[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentExecution!.currentStepNumber} of ${_currentExecution!.totalSteps}',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioResults() {
    return AnimatedBuilder(
      animation: _resultController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _resultController.value)),
          child: Opacity(
            opacity: _resultController.value,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.teal[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Scenario Results',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _exportScenarioResults,
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildResultsOverview(),
                    const SizedBox(height: 16),
                    _buildDetailedResults(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsOverview() {
    final totalScenarios = _scenarioResults.length;
    final successfulScenarios =
        _scenarioResults.values.where((r) => r.successRate >= 0.8).length;
    final averageSuccess = _scenarioResults.values
            .map((r) => r.successRate)
            .reduce((a, b) => a + b) /
        totalScenarios;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[50]!, Colors.teal[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOverviewMetric(
              'Scenarios Tested',
              '$totalScenarios',
              Icons.science,
              Colors.blue[600]!,
            ),
          ),
          Expanded(
            child: _buildOverviewMetric(
              'Successful',
              '$successfulScenarios',
              Icons.check_circle,
              Colors.green[600]!,
            ),
          ),
          Expanded(
            child: _buildOverviewMetric(
              'Average Success',
              '${(averageSuccess * 100).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailedResults() {
    final sortedResults = _scenarioResults.entries.toList()
      ..sort((a, b) => b.value.successRate.compareTo(a.value.successRate));

    return Column(
      children: sortedResults.map((entry) {
        final scenarioName = entry.key;
        final result = entry.value;
        return _buildResultCard(scenarioName, result);
      }).toList(),
    );
  }

  Widget _buildResultCard(String scenarioName, _ScenarioResult result) {
    final successColor = _getSuccessColor(result.successRate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: successColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  scenarioName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: successColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(result.successRate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedUserLevel != 'Beginner') ...[
            Row(
              children: [
                Expanded(
                  child: _buildResultMetric(
                    'Operations',
                    '${result.totalOperations}',
                    Icons.play_arrow,
                  ),
                ),
                Expanded(
                  child: _buildResultMetric(
                    'Cache Hits',
                    '${result.cacheHits}',
                    Icons.flash_on,
                  ),
                ),
                Expanded(
                  child: _buildResultMetric(
                    'Errors',
                    '${result.errors}',
                    Icons.error_outline,
                  ),
                ),
                Expanded(
                  child: _buildResultMetric(
                    'Duration',
                    '${result.executionTime.inSeconds}s',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            result.summary,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          if (result.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...result.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildResultMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBestPractices() {
    final practices = _generateBestPractices();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  'Best Practices & Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...practices.map((practice) => _buildPracticeItem(practice)),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeItem(_BestPractice practice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: practice.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(practice.icon, color: practice.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  practice.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: practice.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  practice.description,
                  style: const TextStyle(fontSize: 13),
                ),
                if (practice.example.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      practice.example,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Scenario execution
  Future<void> _runScenario(_CustomScenario scenario) async {
    if (_isScenarioRunning) return;

    setState(() {
      _isScenarioRunning = true;
      _selectedScenario = scenario.name;
      _currentExecution = _ScenarioExecution(
        scenarioName: scenario.name,
        currentStep: 'Initializing scenario...',
        currentStepNumber: 0,
        totalSteps: scenario.steps.length,
      );
    });

    _progressController.reset();

    try {
      final cache = context.read<CacheProvider>().currentCache;
      final result = _ScenarioResult(
        scenarioName: scenario.name,
        totalOperations: 0,
        cacheHits: 0,
        errors: 0,
        executionTime: Duration.zero,
        successRate: 0.0,
        summary: '',
        recommendations: [],
        timestamp: DateTime.now(),
      );

      final stopwatch = Stopwatch()..start();
      int totalOps = 0;
      int hits = 0;
      int errors = 0;

      for (int i = 0; i < scenario.steps.length; i++) {
        final step = scenario.steps[i];

        setState(() {
          _currentExecution = _currentExecution!.copyWith(
            currentStep: step.description,
            currentStepNumber: i + 1,
          );
        });

        _progressController.animateTo((i + 1) / scenario.steps.length);

        try {
          final stepResult = await _executeStep(cache, step);
          totalOps += stepResult.operations;
          hits += stepResult.hits;
          await Future.delayed(Duration(milliseconds: 200 + (i * 100)));
        } catch (e) {
          errors++;
        }
      }

      stopwatch.stop();

      final successRate =
          errors == 0 ? 1.0 : math.max(0.0, 1.0 - (errors / totalOps));
      final summary =
          _generateSummary(scenario, totalOps, hits, errors, successRate);
      final recommendations =
          _generateRecommendations(scenario, successRate, hits, totalOps);

      final finalResult = result.copyWith(
        totalOperations: totalOps,
        cacheHits: hits,
        errors: errors,
        executionTime: stopwatch.elapsed,
        successRate: successRate,
        summary: summary,
        recommendations: recommendations,
      );

      setState(() {
        _scenarioResults[scenario.name] = finalResult;
        _currentExecution = null;
        _isScenarioRunning = false;
        _selectedScenario = '';
      });

      _resultController.reset();
      _resultController.forward();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${scenario.name} completed! Success rate: ${(successRate * 100).toStringAsFixed(1)}%',
            ),
            backgroundColor: successRate >= 0.8 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _currentExecution = null;
        _isScenarioRunning = false;
        _selectedScenario = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scenario failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<_StepResult> _executeStep(dynamic cache, _ScenarioStep step) async {
    int operations = 0;
    int hits = 0;

    switch (step.type) {
      case 'read':
        for (int i = 0; i < step.iterations; i++) {
          final value = await cache.get<String>('${step.key}_$i', () async {
            await Future.delayed(Duration(milliseconds: step.delay));
            return 'Data ${step.key}_$i';
          });
          operations++;
          if (value != null) hits++;
        }
        break;

      case 'write':
        for (int i = 0; i < step.iterations; i++) {
          await cache.set('${step.key}_$i', 'Data ${step.key}_$i');
          operations++;
          hits++; // Writes are always successful
        }
        break;

      case 'update':
        for (int i = 0; i < step.iterations; i++) {
          await cache.set('${step.key}_$i', 'Updated ${step.key}_$i');
          operations++;
          hits++;
        }
        break;

      case 'delete':
        for (int i = 0; i < step.iterations; i++) {
          await cache.remove('${step.key}_$i');
          operations++;
          hits++;
        }
        break;
    }

    return _StepResult(operations: operations, hits: hits);
  }

  void _resetAllScenarios() {
    setState(() {
      _scenarioResults.clear();
      _selectedScenario = '';
      _currentExecution = null;
    });
    _resultController.reset();
  }

  void _exportScenarioResults() {
    final export = _scenarioResults.entries
        .map((entry) => {
              'scenario': entry.key,
              'success_rate': entry.value.successRate,
              'total_operations': entry.value.totalOperations,
              'cache_hits': entry.value.cacheHits,
              'errors': entry.value.errors,
              'duration_seconds': entry.value.executionTime.inSeconds,
              'summary': entry.value.summary,
            })
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Would export ${_scenarioResults.length} scenario results'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Export Results'),
                content: SingleChildScrollView(
                  child: Text(
                    export.map((e) => e.toString()).join('\n\n'),
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper methods
  IconData _getUserLevelIcon(String level) {
    switch (level) {
      case 'Beginner':
        return Icons.school;
      case 'Intermediate':
        return Icons.code;
      case 'Expert':
        return Icons.rocket_launch;
      default:
        return Icons.person;
    }
  }

  String _getUserLevelDescription(String level) {
    switch (level) {
      case 'Beginner':
        return 'Simple, real-world examples that are easy to understand and follow';
      case 'Intermediate':
        return 'More complex scenarios with detailed metrics and multiple use cases';
      case 'Expert':
        return 'Advanced enterprise scenarios with comprehensive analysis and optimization';
      default:
        return '';
    }
  }

  String _getIntroText(String level) {
    switch (level) {
      case 'Beginner':
        return 'Explore how caching works in real applications! These scenarios show you practical examples from everyday apps like shopping sites and social media.';
      case 'Intermediate':
        return 'Dive deeper into caching strategies used by professional developers. Learn how different industries solve performance challenges.';
      case 'Expert':
        return 'Advanced caching patterns for enterprise applications. Analyze complex scenarios and optimize for production environments.';
      default:
        return '';
    }
  }

  String _getTipText(String level) {
    switch (level) {
      case 'Beginner':
        return 'Start with the "Online Store" scenario - it shows how product pages load faster with caching!';
      case 'Intermediate':
        return 'Try running multiple scenarios to see how different patterns perform in various situations.';
      case 'Expert':
        return 'Compare scenarios across different complexity levels to identify optimal patterns for your use case.';
      default:
        return '';
    }
  }

  List<_CustomScenario> _getScenariosForUserLevel(String level) {
    final allScenarios = [
      // Beginner Scenarios
      _CustomScenario(
        name: 'Online Store',
        description:
            'A shopping website that caches product information, user reviews, and shopping cart data to provide fast browsing experience.',
        category: 'E-commerce',
        industry: 'Retail',
        complexity: 'Simple',
        icon: Icons.shopping_cart,
        color: Colors.green,
        steps: [
          _ScenarioStep('read', 'Load product catalog', 'product', 20, 50,
              'Loading 20 popular products'),
          _ScenarioStep('read', 'Load user reviews', 'review', 15, 30,
              'Fetching customer reviews'),
          _ScenarioStep('write', 'Save to cart', 'cart', 5, 10,
              'Adding items to shopping cart'),
          _ScenarioStep('read', 'Load cart items', 'cart', 3, 20,
              'Displaying cart contents'),
        ],
      ),

      _CustomScenario(
        name: 'Health & Fitness App',
        description:
            'Cache workout plans, progress, and nutrition logs for instant access and offline usability.',
        category: 'Health & Fitness',
        industry: 'Wellness',
        complexity: 'Simple',
        icon: Icons.fitness_center,
        color: Colors.pink,
        steps: [
          _ScenarioStep('write', 'Save workout plan', 'workout', 10, 20,
              'Saving workout plans'),
          _ScenarioStep('read', 'Load workout plan', 'workout', 10, 20,
              'Loading workout plans'),
          _ScenarioStep('write', 'Save nutrition log', 'nutrition', 10, 20,
              'Saving nutrition logs'),
          _ScenarioStep('read', 'Load nutrition log', 'nutrition', 10, 20,
              'Loading nutrition logs'),
        ],
      ),

      _CustomScenario(
        name: 'Education Platform',
        description:
            'Cache course content, quiz results, and user progress for fast access and reduced bandwidth.',
        category: 'Education',
        industry: 'EdTech',
        complexity: 'Simple',
        icon: Icons.school,
        color: Colors.indigo,
        steps: [
          _ScenarioStep('write', 'Save course content', 'course', 5, 30,
              'Saving course materials'),
          _ScenarioStep('read', 'Load course content', 'course', 5, 30,
              'Loading course materials'),
          _ScenarioStep('write', 'Save quiz result', 'quiz', 5, 20,
              'Saving quiz results'),
          _ScenarioStep('read', 'Load quiz result', 'quiz', 5, 20,
              'Loading quiz results'),
        ],
      ),

      _CustomScenario(
        name: 'Real-time Chat',
        description:
            'Cache messages, user status, and media for instant chat experience and offline history.',
        category: 'Communication',
        industry: 'Social',
        complexity: 'Simple',
        icon: Icons.chat,
        color: Colors.lightBlue,
        steps: [
          _ScenarioStep('write', 'Save messages', 'message', 20, 10,
              'Saving chat messages'),
          _ScenarioStep('read', 'Load messages', 'message', 20, 10,
              'Loading chat messages'),
          _ScenarioStep('write', 'Save user status', 'status', 10, 10,
              'Saving user status'),
          _ScenarioStep('read', 'Load user status', 'status', 10, 10,
              'Loading user status'),
        ],
      ),

      _CustomScenario(
        name: 'Travel Booking',
        description:
            'Cache flight/hotel data and user itineraries for fast search and booking.',
        category: 'Travel',
        industry: 'Tourism',
        complexity: 'Simple',
        icon: Icons.flight,
        color: Colors.deepPurple,
        steps: [
          _ScenarioStep('write', 'Save flight search', 'flight', 5, 40,
              'Saving flight search results'),
          _ScenarioStep('read', 'Load flight search', 'flight', 5, 40,
              'Loading flight search results'),
          _ScenarioStep('write', 'Save itinerary', 'itinerary', 5, 30,
              'Saving user itineraries'),
          _ScenarioStep('read', 'Load itinerary', 'itinerary', 5, 30,
              'Loading user itineraries'),
        ],
      ),

      _CustomScenario(
        name: 'Gaming Leaderboard',
        description:
            'Cache scores, player stats, and match history for instant leaderboard and profile access.',
        category: 'Gaming',
        industry: 'Entertainment',
        complexity: 'Simple',
        icon: Icons.emoji_events,
        color: Colors.amber,
        steps: [
          _ScenarioStep('write', 'Save leaderboard', 'leaderboard', 10, 20,
              'Saving leaderboard data'),
          _ScenarioStep('read', 'Load leaderboard', 'leaderboard', 10, 20,
              'Loading leaderboard data'),
          _ScenarioStep('write', 'Save player stats', 'stats', 10, 20,
              'Saving player stats'),
          _ScenarioStep('read', 'Load player stats', 'stats', 10, 20,
              'Loading player stats'),
        ],
      ),

      _CustomScenario(
        name: 'Social Media App',
        description:
            'A social platform that caches user feeds, profile information, and media content for instant loading.',
        category: 'Social',
        industry: 'Technology',
        complexity: 'Simple',
        icon: Icons.people,
        color: Colors.blue,
        steps: [
          _ScenarioStep('read', 'Load news feed', 'feed', 25, 40,
              'Fetching latest posts'),
          _ScenarioStep('read', 'Load user profiles', 'profile', 10, 60,
              'Loading friend profiles'),
          _ScenarioStep(
              'write', 'Cache new posts', 'post', 8, 20, 'Saving new content'),
          _ScenarioStep('read', 'Load notifications', 'notification', 12, 25,
              'Checking notifications'),
        ],
      ),

      // Intermediate Scenarios
      if (level != 'Beginner') ...[
        _CustomScenario(
          name: 'News Portal',
          description:
              'A news website with article caching, comment systems, trending topics, and personalized recommendations.',
          category: 'Content Management',
          industry: 'Media',
          complexity: 'Medium',
          icon: Icons.newspaper,
          color: Colors.orange,
          steps: [
            _ScenarioStep('read', 'Load trending articles', 'trending', 30, 45,
                'Fetching popular news'),
            _ScenarioStep('read', 'Load article content', 'article', 40, 80,
                'Loading full articles'),
            _ScenarioStep('read', 'Load comments', 'comment', 35, 35,
                'Displaying reader comments'),
            _ScenarioStep('write', 'Cache recommendations', 'recommendation',
                20, 60, 'Generating personalized content'),
            _ScenarioStep('update', 'Update view counts', 'viewcount', 25, 15,
                'Tracking article popularity'),
          ],
        ),
        _CustomScenario(
          name: 'Banking System',
          description:
              'Financial application with secure account data caching, transaction history, and real-time balance updates.',
          category: 'Financial Services',
          industry: 'Finance',
          complexity: 'Medium',
          icon: Icons.account_balance,
          color: Colors.teal,
          steps: [
            _ScenarioStep('read', 'Load account balance', 'balance', 15, 100,
                'Fetching current balance'),
            _ScenarioStep('read', 'Load transaction history', 'transaction', 50,
                120, 'Loading recent transactions'),
            _ScenarioStep('write', 'Cache security tokens', 'token', 10, 30,
                'Storing authentication data'),
            _ScenarioStep('read', 'Load account statements', 'statement', 20,
                90, 'Retrieving monthly statements'),
            _ScenarioStep('update', 'Update last login', 'login', 5, 25,
                'Recording login activity'),
          ],
        ),
      ],

      // Expert Scenarios
      if (level == 'Expert') ...[
        _CustomScenario(
          name: 'Multi-tenant SaaS',
          description:
              'Enterprise SaaS platform with tenant isolation, role-based caching, analytics data, and cross-region sync.',
          category: 'Enterprise SaaS',
          industry: 'Technology',
          complexity: 'Complex',
          icon: Icons.business_center,
          color: Colors.purple,
          steps: [
            _ScenarioStep('read', 'Load tenant configuration', 'tenant_config',
                25, 80, 'Loading tenant-specific settings'),
            _ScenarioStep('read', 'Load user permissions', 'permissions', 40,
                60, 'Fetching role-based access controls'),
            _ScenarioStep('read', 'Load analytics data', 'analytics', 60, 120,
                'Generating dashboard metrics'),
            _ScenarioStep('write', 'Cache computed reports', 'reports', 35, 150,
                'Storing generated reports'),
            _ScenarioStep('update', 'Sync cross-region data', 'sync', 20, 200,
                'Syncing data across regions'),
            _ScenarioStep('read', 'Load API rate limits', 'ratelimit', 30, 40,
                'Checking usage quotas'),
          ],
        ),
        _CustomScenario(
          name: 'IoT Data Platform',
          description:
              'Internet of Things platform processing sensor data, device status, alerts, and predictive analytics at scale.',
          category: 'IoT & Analytics',
          industry: 'Manufacturing',
          complexity: 'Complex',
          icon: Icons.sensors,
          color: Colors.red,
          steps: [
            _ScenarioStep('write', 'Ingest sensor data', 'sensor_data', 100, 20,
                'Processing incoming sensor readings'),
            _ScenarioStep('read', 'Load device status', 'device_status', 75, 50,
                'Checking device health'),
            _ScenarioStep('write', 'Cache alert rules', 'alert_rules', 25, 70,
                'Storing monitoring rules'),
            _ScenarioStep('read', 'Load historical trends', 'trends', 80, 100,
                'Analyzing historical data'),
            _ScenarioStep('write', 'Cache predictions', 'predictions', 40, 180,
                'Storing ML predictions'),
            _ScenarioStep('update', 'Update device configs', 'device_config',
                50, 90, 'Updating device settings'),
          ],
        ),
        _CustomScenario(
          name: 'Global CDN',
          description:
              'Content Delivery Network with edge caching, geo-routing, bandwidth optimization, and real-time cache invalidation.',
          category: 'Infrastructure',
          industry: 'Technology',
          complexity: 'Complex',
          icon: Icons.public,
          color: Colors.indigo,
          steps: [
            _ScenarioStep('read', 'Load from edge cache', 'edge_content', 150,
                30, 'Serving content from edge locations'),
            _ScenarioStep('write', 'Cache at origin', 'origin_content', 80, 100,
                'Storing content at origin servers'),
            _ScenarioStep('update', 'Invalidate cache entries', 'invalidation',
                45, 60, 'Purging outdated content'),
            _ScenarioStep('read', 'Load geo-routing rules', 'geo_rules', 60, 80,
                'Applying geographic routing'),
            _ScenarioStep('write', 'Cache bandwidth metrics', 'bandwidth', 70,
                40, 'Tracking bandwidth usage'),
            _ScenarioStep('read', 'Load performance stats', 'perf_stats', 90,
                70, 'Monitoring CDN performance'),
          ],
        ),
      ],
    ];

    return allScenarios;
  }

  Color _getComplexityColor(String complexity) {
    switch (complexity) {
      case 'Simple':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Complex':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSuccessColor(double successRate) {
    if (successRate >= 0.9) return Colors.green;
    if (successRate >= 0.7) return Colors.blue;
    if (successRate >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _generateSummary(_CustomScenario scenario, int totalOps, int hits,
      int errors, double successRate) {
    if (successRate >= 0.9) {
      return 'Excellent performance! The ${scenario.category.toLowerCase()} scenario executed flawlessly with ${(successRate * 100).toStringAsFixed(1)}% success rate.';
    } else if (successRate >= 0.7) {
      return 'Good performance for the ${scenario.category.toLowerCase()} scenario. Minor issues encountered but overall successful execution.';
    } else if (successRate >= 0.5) {
      return 'Moderate performance. The ${scenario.category.toLowerCase()} scenario completed but with some challenges that should be addressed.';
    } else {
      return 'Performance issues detected in the ${scenario.category.toLowerCase()} scenario. Significant optimization needed.';
    }
  }

  List<String> _generateRecommendations(
      _CustomScenario scenario, double successRate, int hits, int totalOps) {
    final recommendations = <String>[];

    if (successRate < 0.8) {
      recommendations
          .add('Consider implementing retry mechanisms for failed operations');
      recommendations
          .add('Review cache configuration and increase capacity if needed');
    }

    final hitRate = totalOps > 0 ? hits / totalOps : 0.0;
    if (hitRate < 0.6) {
      recommendations
          .add('Optimize cache keys and TTL values for better hit rates');
      recommendations
          .add('Consider pre-warming cache with frequently accessed data');
    }

    switch (scenario.complexity) {
      case 'Complex':
        recommendations
            .add('Implement distributed caching for better scalability');
        recommendations.add('Monitor cache performance metrics in production');
        break;
      case 'Medium':
        recommendations
            .add('Consider implementing cache compression for large datasets');
        break;
      case 'Simple':
        recommendations.add(
            'Great foundation! Consider exploring more advanced caching patterns');
        break;
    }

    return recommendations;
  }

  List<_BestPractice> _generateBestPractices() {
    final practices = <_BestPractice>[];
    final totalScenarios = _scenarioResults.length;
    final averageSuccess = _scenarioResults.values
            .map((r) => r.successRate)
            .reduce((a, b) => a + b) /
        totalScenarios;

    if (averageSuccess >= 0.8) {
      practices.add(_BestPractice(
        title: 'Cache Key Strategy',
        description:
            'Your cache key patterns are working well. Consistent naming and proper namespacing improve cache hit rates.',
        example: 'user:123:profile, product:456:details',
        icon: Icons.vpn_key,
        color: Colors.green,
      ));
    }

    practices.add(_BestPractice(
      title: 'TTL Configuration',
      description:
          'Set appropriate Time-To-Live values based on data volatility. Frequently changing data should have shorter TTL.',
      example: 'Static content: 24h, User data: 1h, Real-time data: 5min',
      icon: Icons.schedule,
      color: Colors.blue,
    ));

    if (_selectedUserLevel != 'Beginner') {
      practices.add(_BestPractice(
        title: 'Cache Invalidation',
        description:
            'Implement proper cache invalidation strategies to ensure data consistency across your application.',
        example: 'await cache.remove("user:*") // Clear all user data',
        icon: Icons.refresh,
        color: Colors.orange,
      ));
    }

    if (_selectedUserLevel == 'Expert') {
      practices.add(_BestPractice(
        title: 'Monitoring & Metrics',
        description:
            'Track cache hit rates, memory usage, and performance metrics to optimize cache configuration.',
        example: 'Hit rate: 85%, Memory: 64MB, Avg response: 12ms',
        icon: Icons.analytics,
        color: Colors.purple,
      ));
    }

    return practices;
  }
}

// Data classes
class _CustomScenario {
  final String name;
  final String description;
  final String category;
  final String industry;
  final String complexity;
  final IconData icon;
  final Color color;
  final List<_ScenarioStep> steps;

  _CustomScenario({
    required this.name,
    required this.description,
    required this.category,
    required this.industry,
    required this.complexity,
    required this.icon,
    required this.color,
    required this.steps,
  });
}

class _ScenarioStep {
  final String type; // 'read', 'write', 'update', 'delete'
  final String description;
  final String key;
  final int iterations;
  final int delay; // milliseconds
  final String displayText;

  _ScenarioStep(this.type, this.displayText, this.key, this.iterations,
      this.delay, this.description);
}

class _ScenarioExecution {
  final String scenarioName;
  final String currentStep;
  final int currentStepNumber;
  final int totalSteps;

  _ScenarioExecution({
    required this.scenarioName,
    required this.currentStep,
    required this.currentStepNumber,
    required this.totalSteps,
  });

  _ScenarioExecution copyWith({
    String? scenarioName,
    String? currentStep,
    int? currentStepNumber,
    int? totalSteps,
  }) {
    return _ScenarioExecution(
      scenarioName: scenarioName ?? this.scenarioName,
      currentStep: currentStep ?? this.currentStep,
      currentStepNumber: currentStepNumber ?? this.currentStepNumber,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}

class _ScenarioResult {
  final String scenarioName;
  final int totalOperations;
  final int cacheHits;
  final int errors;
  final Duration executionTime;
  final double successRate;
  final String summary;
  final List<String> recommendations;
  final DateTime timestamp;

  _ScenarioResult({
    required this.scenarioName,
    required this.totalOperations,
    required this.cacheHits,
    required this.errors,
    required this.executionTime,
    required this.successRate,
    required this.summary,
    required this.recommendations,
    required this.timestamp,
  });

  _ScenarioResult copyWith({
    String? scenarioName,
    int? totalOperations,
    int? cacheHits,
    int? errors,
    Duration? executionTime,
    double? successRate,
    String? summary,
    List<String>? recommendations,
    DateTime? timestamp,
  }) {
    return _ScenarioResult(
      scenarioName: scenarioName ?? this.scenarioName,
      totalOperations: totalOperations ?? this.totalOperations,
      cacheHits: cacheHits ?? this.cacheHits,
      errors: errors ?? this.errors,
      executionTime: executionTime ?? this.executionTime,
      successRate: successRate ?? this.successRate,
      summary: summary ?? this.summary,
      recommendations: recommendations ?? this.recommendations,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class _StepResult {
  final int operations;
  final int hits;

  _StepResult({required this.operations, required this.hits});
}

class _BestPractice {
  final String title;
  final String description;
  final String example;
  final IconData icon;
  final Color color;

  _BestPractice({
    required this.title,
    required this.description,
    required this.example,
    required this.icon,
    required this.color,
  });
}
