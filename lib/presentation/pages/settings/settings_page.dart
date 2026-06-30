import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/services/notification_service.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
import 'package:kaza_takip/presentation/blocs/prayer_time/prayer_time_cubit.dart';
import 'package:kaza_takip/presentation/pages/wizard/wizard_page.dart';

/// Ana shell içinde gömülü kullanıma uygun Ayarlar gövdesi (AppBar içermez).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<KazaBloc, KazaState>(
        builder: (context, state) {
          final pending = state is KazaLoaded ? state.pendingChanges : 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const _CityTile(),
              const _NotificationTile(),
              const _SpiritualNotificationTile(),
              _SettingsTile(
                icon: Icons.calculate_outlined,
                title: 'Kaza Borcunu Yeniden Hesapla',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<KazaBloc>(),
                      child: const WizardPage(),
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.cloud_sync_outlined,
                title: 'Buluta Yedekle',
                subtitle:
                    pending > 0 ? '$pending değişiklik bekliyor' : 'Her şey güncel',
                trailing: pending > 0
                    ? const Icon(Icons.cloud_upload, color: AppColors.warning)
                    : const Icon(Icons.cloud_done, color: AppColors.success),
                onTap: () =>
                    context.read<KazaBloc>().add(const SyncDataWithCloud()),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Hakkında',
                subtitle: '%100 ücretsiz, reklamsız',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Kaza Takip',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'İbadet Planlayıcısı & Kaza Namazı Takip Uygulaması',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "Şehir Değiştir" — Aladhan vakitleri için aktif şehri günceller.
class _CityTile extends StatelessWidget {
  const _CityTile();

  static const _popular = [
    'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Adana', 'Antalya',
    'Konya', 'Gaziantep', 'Kayseri', 'Eskişehir', 'Trabzon',
    'Samsun', 'Aksaray', 'Şanlıurfa', 'Diyarbakır',
  ];

  Future<void> _showDialog(BuildContext context) async {
    final cubit = context.read<PrayerTimeCubit>();
    final controller = TextEditingController(text: cubit.currentCity);

    final picked = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Şehir Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Örn. Aksaray',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                autofocus: true,
                onSubmitted: (v) => Navigator.of(dialogCtx).pop(v),
              ),
              const SizedBox(height: 16),
              Text('Popüler şehirler', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _popular
                    .map(
                      (c) => ActionChip(
                        label: Text(c),
                        onPressed: () => Navigator.of(dialogCtx).pop(c),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogCtx).pop(controller.text.trim()),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (picked != null && picked.isNotEmpty) {
      await cubit.changeCity(picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şehir güncellendi: $picked')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (ctx, state) {
        final city = switch (state) {
          PrayerTimeLoading(:final city) => city,
          PrayerTimeLoaded(:final city) => city,
          PrayerTimeNoConnection(:final city) => city,
          _ => ctx.read<PrayerTimeCubit>().currentCity,
        };
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: ListTile(
            leading:
                const Icon(Icons.location_on_outlined, color: AppColors.primary),
            title: Text('Şehir Değiştir', style: AppTextStyles.titleMedium),
            subtitle: Text('Aktif: $city', style: AppTextStyles.bodySmall),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDialog(context),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatefulWidget {
  const _NotificationTile();

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  final NotificationService _svc = sl<NotificationService>();
  late bool _enabled = _svc.isEnabled;
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    setState(() => _busy = true);
    if (value) {
      final ok = await _svc.enable();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Bildirim izni verilmedi. Ayarlardan etkinleştirebilirsiniz.'),
          ),
        );
      }
      setState(() => _enabled = _svc.isEnabled);
    } else {
      await _svc.disable();
      setState(() => _enabled = false);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined,
            color: AppColors.primary),
        activeColor: AppColors.primary,
        title: Text('Namaz Vakti Hatırlatıcısı',
            style: AppTextStyles.titleMedium),
        subtitle: Text(
          _busy
              ? 'Ayarlanıyor...'
              : (_enabled
                  ? 'Her vakitte kaza namazı hatırlatılır'
                  : 'Kapalı'),
          style: AppTextStyles.bodySmall,
        ),
        value: _enabled,
        onChanged: _busy ? null : _toggle,
      ),
    );
  }
}

/// Manevi (AI-destekli) günlük mesajlar için aç/kapa + 1/2 frekans seçici.
class _SpiritualNotificationTile extends StatefulWidget {
  const _SpiritualNotificationTile();

  @override
  State<_SpiritualNotificationTile> createState() =>
      _SpiritualNotificationTileState();
}

class _SpiritualNotificationTileState
    extends State<_SpiritualNotificationTile> {
  final NotificationService _svc = sl<NotificationService>();
  late bool _enabled = _svc.isSpiritualEnabled;
  late int _freq = _svc.spiritualFrequency;
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    setState(() => _busy = true);
    if (value) {
      final ok = await _svc.enableSpiritual();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Bildirim izni verilmedi. Cihaz ayarlarından etkinleştirebilirsiniz.'),
          ),
        );
      }
      setState(() => _enabled = _svc.isSpiritualEnabled);
    } else {
      await _svc.disableSpiritual();
      setState(() => _enabled = false);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _setFreq(int value) async {
    await _svc.setSpiritualFrequency(value);
    setState(() => _freq = value);
    if (_enabled) await _svc.rescheduleSpiritual();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome,
                color: AppColors.matteGoldDark),
            activeColor: AppColors.imperial,
            title: Text('Manevi Bildirimler',
                style: AppTextStyles.titleMedium),
            subtitle: Text(
              _busy
                  ? 'Ayarlanıyor...'
                  : (_enabled
                      ? 'Ayet, hadis, Mevlana, Gazali, Risale-i Nur\'dan '
                          '${_freq == 2 ? "günde 2" : "günde 1"} mesaj'
                      : 'Kapalı — açınca akıllı seçimle gün sana mesaj yollar'),
              style: AppTextStyles.bodySmall,
            ),
            value: _enabled,
            onChanged: _busy ? null : _toggle,
          ),
          if (_enabled)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                children: [
                  Text('Sıklık',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.matteGoldDark,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SegmentedButton<int>(
                      style: ButtonStyle(
                        side: WidgetStateProperty.all(const BorderSide(
                            color: AppColors.matteGold, width: 0.8)),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((s) =>
                                s.contains(WidgetState.selected)
                                    ? AppColors.imperial
                                    : AppColors.paper),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((s) =>
                                s.contains(WidgetState.selected)
                                    ? Colors.white
                                    : AppColors.imperial),
                      ),
                      segments: const [
                        ButtonSegment(value: 1, label: Text('Günde 1')),
                        ButtonSegment(value: 2, label: Text('Günde 2')),
                      ],
                      selected: {_freq},
                      onSelectionChanged: (s) => _setFreq(s.first),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.bodySmall)
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
