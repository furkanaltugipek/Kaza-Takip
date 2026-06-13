import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
import 'package:kaza_takip/presentation/pages/main_shell.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/presentation/widgets/common/app_button.dart';
import 'package:kaza_takip/presentation/widgets/common/date_picker_field.dart';

/// 4 adımlı kaza borcu hesaplama sihirbazı.
class WizardPage extends StatefulWidget {
  const WizardPage({super.key});

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Form alanları
  DateTime? _birthDate;
  int _pubertyAge = PrayerConstants.defaultMalePubertyAge;
  DateTime? _startDate;
  int _offDays = 0;

  final _offDaysCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _pageCtrl.dispose();
    _offDaysCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic);
      setState(() => _page++);
    }
  }

  void _back() {
    if (_page > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic);
      setState(() => _page--);
    }
  }

  void _calculate() {
    if (_birthDate == null || _startDate == null) return;
    context.read<KazaBloc>().add(CalculateInitialDebt(
          birthDate: _birthDate!,
          pubertyAge: _pubertyAge,
          startDate: _startDate!,
          offDays: _offDays,
        ));
  }

  void _saveAndStart() {
    context.read<KazaBloc>().add(const SaveCalculatedDebt());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KazaBloc, KazaState>(
      listener: (context, state) {
        if (state is KazaLoaded) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => BlocProvider.value(
              value: context.read<KazaBloc>(),
              child: const MainShell(),
            )),
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  page: _page,
                  onBack: _page > 0 ? _back : null,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Step1BirthDate(
                        value: _birthDate,
                        onChanged: (d) => setState(() => _birthDate = d),
                        onNext: _birthDate != null ? _next : null,
                      ),
                      _Step2PubertyAge(
                        age: _pubertyAge,
                        onChanged: (v) => setState(() => _pubertyAge = v),
                        onNext: _next,
                      ),
                      _Step3StartDate(
                        birthDate: _birthDate,
                        value: _startDate,
                        offDays: _offDays,
                        offDaysCtrl: _offDaysCtrl,
                        onDateChanged: (d) => setState(() => _startDate = d),
                        onOffDaysChanged: (v) => setState(() => _offDays = v),
                        onNext: _startDate != null ? _calculate : null,
                        isLoading: state is KazaLoading,
                      ),
                      _Step4Result(
                        state: state,
                        onSave: _saveAndStart,
                        onBack: _back,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Üst başlık & ilerleme çubuğu ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int page;
  final VoidCallback? onBack;
  const _Header({required this.page, this.onBack});

  static const _titles = [
    'Doğum Tarihi',
    'Ergenlik Yaşı',
    'Namaz Başlangıcı',
    'Hesap Sonucu',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white70, size: 20),
                  onPressed: onBack,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  'Kaza Borcu Hesapla',
                  style: AppTextStyles.titleLarge
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adım ${page + 1}/4 — ${_titles[page]}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (page + 1) / 4,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Adım 1: Doğum tarihi ──────────────────────────────────────────────────────

class _Step1BirthDate extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback? onNext;
  const _Step1BirthDate(
      {required this.value,
      required this.onChanged,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.cake_outlined,
      title: 'Ne zaman doğdunuz?',
      subtitle:
          'Ergenlik tarihinizi otomatik hesaplamak için kullanılır.',
      child: DatePickerField(
        label: 'Doğum Tarihiniz',
        value: value,
        firstDate: DateTime(1920),
        lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        onChanged: onChanged,
      ),
      onNext: onNext,
      nextLabel: 'Devam Et',
    );
  }
}

// ── Adım 2: Ergenlik yaşı ────────────────────────────────────────────────────

class _Step2PubertyAge extends StatelessWidget {
  final int age;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;
  const _Step2PubertyAge(
      {required this.age,
      required this.onChanged,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.person_outline,
      title: 'Ergenlik (bülûğ) yaşınız?',
      subtitle:
          'Namazın farz olduğu yaş. Genellikle erkekte 12–14, kadında 9–12.',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AgeChip(
                  label: '9',
                  selected: age == 9,
                  onTap: () => onChanged(9)),
              _AgeChip(
                  label: '10',
                  selected: age == 10,
                  onTap: () => onChanged(10)),
              _AgeChip(
                  label: '12',
                  selected: age == 12,
                  onTap: () => onChanged(12)),
              _AgeChip(
                  label: '13',
                  selected: age == 13,
                  onTap: () => onChanged(13)),
              _AgeChip(
                  label: '14',
                  selected: age == 14,
                  onTap: () => onChanged(14)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
                iconSize: 32,
                onPressed: age > 7 ? () => onChanged(age - 1) : null,
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$age',
                    style: AppTextStyles.displayLarge,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                iconSize: 32,
                onPressed: age < 18 ? () => onChanged(age + 1) : null,
              ),
            ],
          ),
        ],
      ),
      onNext: onNext,
      nextLabel: 'Devam Et',
    );
  }
}

class _AgeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AgeChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(5),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

// ── Adım 3: Başlangıç tarihi + mazeret günleri ───────────────────────────────

class _Step3StartDate extends StatelessWidget {
  final DateTime? birthDate;
  final DateTime? value;
  final int offDays;
  final TextEditingController offDaysCtrl;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onOffDaysChanged;
  final VoidCallback? onNext;
  final bool isLoading;

  const _Step3StartDate({
    required this.birthDate,
    required this.value,
    required this.offDays,
    required this.offDaysCtrl,
    required this.onDateChanged,
    required this.onOffDaysChanged,
    required this.onNext,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.mosque_outlined,
      title: 'Düzenli namaza ne zaman başladınız?',
      subtitle:
          'Bu tarihten itibaren tüm namazları kıldığınız varsayılır.',
      child: Column(
        children: [
          DatePickerField(
            label: 'Namaz Başlangıç Tarihi',
            value: value,
            firstDate: birthDate ?? DateTime(1920),
            lastDate: DateTime.now(),
            onChanged: onDateChanged,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tahminî mazeret günleri',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Hastalık, yolculuk vb. toplam gün sayısı.\nHanım: hayz günleri otomatik hesaplanır.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 90,
                child: TextFormField(
                  controller: offDaysCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.primary),
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'gün',
                  ),
                  onChanged: (v) =>
                      onOffDaysChanged(int.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
      onNext: onNext,
      nextLabel: 'Hesapla',
      isLoading: isLoading,
    );
  }
}

// ── Adım 4: Sonuç önizleme ────────────────────────────────────────────────────

class _Step4Result extends StatelessWidget {
  final KazaState state;
  final VoidCallback onSave;
  final VoidCallback onBack;

  const _Step4Result({
    required this.state,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    if (state is KazaLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Hesaplanıyor...'),
          ],
        ),
      );
    }

    if (state is! KazaCalculated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              Text(
                state is KazaError
                    ? (state as KazaError).message
                    : 'Lütfen önceki adımlara dönün.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Geri Dön', onPressed: onBack),
            ],
          ),
        ),
      );
    }

    final result = (state as KazaCalculated).result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet kart
          _ResultSummaryCard(result: result),
          const SizedBox(height: 24),
          // Vakit dağılımı
          Text('Vakit Bazlı Dağılım',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...PrayerConstants.prayerKeys.map((key) {
            final idx = PrayerConstants.prayerKeys.indexOf(key);
            final name = PrayerConstants.prayerNames[idx];
            final count = result.breakdown[key] ?? 0;
            final rakats = count * (PrayerConstants.fardRakats[key] ?? 0);
            final color =
                AppColors.prayerColors[key] ?? AppColors.primary;
            return _VakitRow(
              name: name,
              count: count,
              rakats: rakats,
              color: color,
            );
          }),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Planı Başlat',
              onPressed: onSave,
              icon: Icons.play_arrow_rounded,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Tekrar Hesapla',
              onPressed: onBack,
              outlined: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSummaryCard extends StatelessWidget {
  final KazaCalculationResult result;
  const _ResultSummaryCard({required this.result});

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.mosque_rounded,
              color: Colors.white54, size: 44),
          const SizedBox(height: 12),
          Text(
            _fmt(result.totalPrayers),
            style: AppTextStyles.displayLarge
                .copyWith(color: Colors.white, fontSize: 52),
          ),
          Text('Toplam Kaza Namazı',
              style: AppTextStyles.titleMedium
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                  label: 'Gün',
                  value: _fmt(result.totalDays)),
              _StatItem(
                  label: 'Rekat',
                  value: _fmt(result.totalRakats)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ergenlik: ${AppDateUtils.toDisplay(result.pubertyDate)}',
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.displayMedium
                .copyWith(color: Colors.white, fontSize: 24)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white60)),
      ],
    );
  }
}

class _VakitRow extends StatelessWidget {
  final String name;
  final int count;
  final int rakats;
  final Color color;
  const _VakitRow(
      {required this.name,
      required this.count,
      required this.rakats,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: AppTextStyles.titleMedium),
          ),
          Text(
            '$count namaz · $rakats rekat',
            style: AppTextStyles.bodyMedium
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Paylaşılan adım sarmalayıcı ───────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool isLoading;

  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    this.nextLabel = 'Devam Et',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(subtitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: const Color(0xFF666666))),
          const SizedBox(height: 32),
          child,
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: nextLabel,
              onPressed: onNext,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
