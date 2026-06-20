import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/services/notification_service.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
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
              const _NotificationTile(),
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
