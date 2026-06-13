import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/domain/entities/daily_log.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';

/// Aylık katkı takvimi — DailyLog durumlarını renk kodlarıyla gösterir.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final KazaRepository _repo = sl<KazaRepository>();

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  /// yyyy-MM-dd → DailyLog (mevcut ay için önbellek)
  Map<String, DailyLog> _logs = {};
  bool _loading = true;

  String? _userId;

  @override
  void initState() {
    super.initState();
    final state = context.read<KazaBloc>().state;
    if (state is KazaLoaded) _userId = state.userId;
    _loadMonth(_focusedMonth);
  }

  Future<void> _loadMonth(DateTime month) async {
    if (_userId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final logs = await _repo.getDailyLogs(_userId!, month);
    setState(() {
      _logs = {for (final l in logs) AppDateUtils.toStorage(l.date): l};
      _loading = false;
    });
  }

  DailyStatus _statusFor(DateTime day) {
    final log = _logs[AppDateUtils.toStorage(day)];
    if (log == null) return DailyStatus.none;
    return log.statusEnum;
  }

  Color _colorFor(DailyStatus s) => switch (s) {
        DailyStatus.completed => AppColors.success,
        DailyStatus.partial => AppColors.warning,
        DailyStatus.none => AppColors.calendarEmpty,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Katkı Takvimi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CalendarCard(
            child: TableCalendar(
              locale: 'tr_TR',
              firstDay: DateTime(2000),
              lastDay: DateTime.now().add(const Duration(days: 1)),
              focusedDay: _focusedMonth,
              selectedDayPredicate: (d) =>
                  _selectedDay != null &&
                  AppDateUtils.isSameDay(d, _selectedDay!),
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Ay'
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.titleLarge,
                leftChevronIcon: const Icon(Icons.chevron_left,
                    color: AppColors.primary),
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: AppColors.primary),
              ),
              onPageChanged: (focused) {
                _focusedMonth = focused;
                _loadMonth(focused);
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedMonth = focused;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, _) => _DayCell(
                  day: day,
                  color: _colorFor(_statusFor(day)),
                ),
                todayBuilder: (ctx, day, _) => _DayCell(
                  day: day,
                  color: _colorFor(_statusFor(day)),
                  isToday: true,
                ),
                outsideBuilder: (ctx, day, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Legend(),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            _MonthSummary(logs: _logs.values.toList()),
          if (_selectedDay != null) ...[
            const SizedBox(height: 16),
            _SelectedDayDetail(
              day: _selectedDay!,
              log: _logs[AppDateUtils.toStorage(_selectedDay!)],
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final Widget child;
  const _CalendarCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final Color color;
  final bool isToday;
  const _DayCell(
      {required this.day, required this.color, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    final isEmpty = color == AppColors.calendarEmpty;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppTextStyles.bodySmall.copyWith(
          color: isEmpty ? const Color(0xFF666666) : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(AppColors.success, 'Tamamlandı'),
          item(AppColors.warning, 'Kısmi'),
          item(AppColors.calendarEmpty, 'Boş'),
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final List<DailyLog> logs;
  const _MonthSummary({required this.logs});

  @override
  Widget build(BuildContext context) {
    final completed =
        logs.where((l) => l.statusEnum == DailyStatus.completed).length;
    final partial =
        logs.where((l) => l.statusEnum == DailyStatus.partial).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBox(value: '$completed', label: 'Tam gün', color: AppColors.success),
          _StatBox(value: '$partial', label: 'Kısmi gün', color: AppColors.warning),
          _StatBox(
              value: '${logs.length}',
              label: 'Aktif gün',
              color: AppColors.primary),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBox(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.headlineLarge.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _SelectedDayDetail extends StatelessWidget {
  final DateTime day;
  final DailyLog? log;
  const _SelectedDayDetail({required this.day, this.log});

  @override
  Widget build(BuildContext context) {
    final total = log?.totalCompleted ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppDateUtils.toDisplay(day),
                    style: AppTextStyles.titleMedium),
                Text(
                  total > 0
                      ? '$total kaza namazı tamamlandı'
                      : 'Bu gün kayıt yok',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
