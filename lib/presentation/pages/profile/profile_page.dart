import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';
import 'package:kaza_takip/presentation/pages/wizard/wizard_page.dart';

/// Profil / Ayarlar sekmesi.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: BlocBuilder<KazaBloc, KazaState>(
        builder: (context, state) {
          final pending =
              state is KazaLoaded ? state.pendingChanges : 0;
          final mode = state is KazaLoaded ? state.planMode : '—';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Üst kart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Misafir Kullanıcı',
                            style: AppTextStyles.titleLarge
                                .copyWith(color: Colors.white)),
                        Text('Yerel hesap · Mod: $mode',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                subtitle: pending > 0
                    ? '$pending değişiklik bekliyor'
                    : 'Her şey güncel',
                trailing: pending > 0
                    ? const Icon(Icons.cloud_upload,
                        color: AppColors.warning)
                    : const Icon(Icons.cloud_done,
                        color: AppColors.success),
                onTap: () => context
                    .read<KazaBloc>()
                    .add(const SyncDataWithCloud()),
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
        subtitle:
            subtitle != null ? Text(subtitle!, style: AppTextStyles.bodySmall) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
