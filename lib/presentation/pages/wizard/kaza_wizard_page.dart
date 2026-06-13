import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/core/utils/validators.dart';
import 'package:kaza_takip/presentation/bloc/kaza_calculator/kaza_calculator_bloc.dart';
import 'package:kaza_takip/presentation/pages/wizard/kaza_result_page.dart';
import 'package:kaza_takip/presentation/widgets/common/date_picker_field.dart';

class KazaWizardPage extends StatefulWidget {
  const KazaWizardPage({super.key});

  @override
  State<KazaWizardPage> createState() => _KazaWizardPageState();
}

class _KazaWizardPageState extends State<KazaWizardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KazaCalculatorBloc, KazaCalculatorState>(
      listener: (context, state) {
        if (state.status == KazaCalculatorStatus.success &&
            state.result != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<KazaCalculatorBloc>(),
              child: const KazaResultPage(),
            ),
          ));
        }
        if (state.status == KazaCalculatorStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Hata oluştu')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Kaza Borcu Hesapla'),
            leading: _currentPage > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _prevPage,
                  )
                : null,
          ),
          body: Column(
            children: [
              _WizardProgressBar(current: _currentPage, total: 4),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _GenderStep(onNext: _nextPage),
                    _BirthDateStep(onNext: _nextPage),
                    _PubertyDateStep(onNext: _nextPage),
                    _RegularStartStep(
                      onSubmit: () => context
                          .read<KazaCalculatorBloc>()
                          .add(const KazaCalculationSubmitted()),
                      isLoading: state.status == KazaCalculatorStatus.loading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WizardProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _WizardProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adım ${current + 1} / $total',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / total,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Gender ────────────────────────────────────────────────────────────

class _GenderStep extends StatelessWidget {
  final VoidCallback onNext;
  const _GenderStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<KazaCalculatorBloc>();
    return BlocBuilder<KazaCalculatorBloc, KazaCalculatorState>(
      builder: (context, state) {
        return _StepWrapper(
          title: 'Cinsiyet',
          subtitle: 'Hanım hesabı, hayz günlerini otomatik düşer.',
          child: Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Erkek',
                  icon: Icons.man,
                  selected: !state.isFemale,
                  onTap: () =>
                      bloc.add(const KazaGenderChanged(false)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  label: 'Hanım',
                  icon: Icons.woman,
                  selected: state.isFemale,
                  onTap: () =>
                      bloc.add(const KazaGenderChanged(true)),
                ),
              ),
            ],
          ),
          onNext: onNext,
          canProceed: true,
        );
      },
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderCard(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 48, color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.titleLarge.copyWith(
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Birth Date ────────────────────────────────────────────────────────

class _BirthDateStep extends StatelessWidget {
  final VoidCallback onNext;
  const _BirthDateStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KazaCalculatorBloc, KazaCalculatorState>(
      builder: (context, state) {
        return _StepWrapper(
          title: 'Doğum Tarihiniz',
          subtitle: 'Ergenlik yaşını hesaplamak için kullanılır.',
          child: DatePickerField(
            label: 'Doğum Tarihi',
            value: state.birthDate,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            onChanged: (date) => context
                .read<KazaCalculatorBloc>()
                .add(KazaBirthDateChanged(date)),
            errorText: AppValidators.birthDate(state.birthDate),
          ),
          onNext: onNext,
          canProceed: state.birthDate != null,
        );
      },
    );
  }
}

// ── Step 3: Puberty Date ──────────────────────────────────────────────────────

class _PubertyDateStep extends StatelessWidget {
  final VoidCallback onNext;
  const _PubertyDateStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KazaCalculatorBloc, KazaCalculatorState>(
      builder: (context, state) {
        return _StepWrapper(
          title: 'Ergenlik (Bülûğ) Tarihi',
          subtitle:
              'Bu tarihten itibaren namaz farz olmaktadır.',
          child: DatePickerField(
            label: 'Ergenlik Tarihi',
            value: state.pubertyDate,
            firstDate: state.birthDate ?? DateTime(1900),
            lastDate: DateTime.now(),
            onChanged: (date) => context
                .read<KazaCalculatorBloc>()
                .add(KazaPubertyDateChanged(date)),
            errorText:
                AppValidators.pubertyDate(state.pubertyDate, state.birthDate),
          ),
          onNext: onNext,
          canProceed: state.pubertyDate != null,
        );
      },
    );
  }
}

// ── Step 4: Regular Start Date ────────────────────────────────────────────────

class _RegularStartStep extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isLoading;
  const _RegularStartStep(
      {required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KazaCalculatorBloc, KazaCalculatorState>(
      builder: (context, state) {
        return _StepWrapper(
          title: 'Düzenli Namaza Başlama',
          subtitle:
              'Bu tarihten sonra tüm namazları düzenli kıldığınızı varsayıyoruz.',
          child: DatePickerField(
            label: 'Düzenli Namaz Başlangıcı',
            value: state.regularStartDate,
            firstDate: state.pubertyDate ?? DateTime(1900),
            lastDate: DateTime.now(),
            onChanged: (date) => context
                .read<KazaCalculatorBloc>()
                .add(KazaRegularStartDateChanged(date)),
            errorText: AppValidators.regularStartDate(
                state.regularStartDate, state.pubertyDate),
          ),
          onNext: onSubmit,
          nextLabel: isLoading ? null : 'Hesapla',
          canProceed: state.canSubmit && !isLoading,
          isLoading: isLoading,
        );
      },
    );
  }
}

// ── Shared step wrapper ───────────────────────────────────────────────────────

class _StepWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final bool canProceed;
  final String? nextLabel;
  final bool isLoading;

  const _StepWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    required this.canProceed,
    this.nextLabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(subtitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.black54)),
          const SizedBox(height: 32),
          child,
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(nextLabel ?? 'Devam Et'),
            ),
          ),
        ],
      ),
    );
  }
}
