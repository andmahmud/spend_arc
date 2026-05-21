class AppConstants {
  static const String appName = 'SpendArc';
  static const String hiveBoxName = 'spendarc_box';
  static const String transactionsKey = 'transactions';
  static const String budgetKey = 'budget';
  static const String syncQueueKey = 'sync_queue';
  static const String lastSyncKey = 'last_sync_timestamp';

  static const double defaultMonthlyBudget = 5000.0;
  static const int animationDurationMs = 600;
  static const int syncIntervalMinutes = 15;

  static const double arcStartAngle = -210;
  static const double arcSweepAngle = 240;
  static const double maxArcPercentage = 1.0;
}
