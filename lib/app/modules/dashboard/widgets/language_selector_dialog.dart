import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard_controller.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  Future<Map<String, bool>> _checkLanguageAvailability(DashboardController controller) async {
    final result = <String, bool>{};
    for (final code in controller.availableLanguages.keys) {
      result[code] = await controller.isLanguageAvailable(code);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Bahasa Voice',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih bahasa untuk output suara (Text-to-Speech)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, bool>>(
              future: _checkLanguageAvailability(controller),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final availableLanguages = controller.availableLanguages;
                final languageStatus = snapshot.data!;

                return Obx(() {
                  final current = controller.currentTtsLanguage.value;
                  
                  return Column(
                    children: availableLanguages.entries.map((entry) {
                      final code = entry.key;
                      final label = entry.value;
                      final isSelected = current == code;
                      final isAvailable = languageStatus[code] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isAvailable
                                    ? theme.colorScheme.outline.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3)),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : (isAvailable
                                  ? Colors.transparent
                                  : Colors.grey.withOpacity(0.05)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          enabled: isAvailable,
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isAvailable
                                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                                    : Colors.grey),
                          ),
                          title: Text(
                            label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isAvailable
                                      ? theme.colorScheme.onSurface
                                      : Colors.grey),
                            ),
                          ),
                          subtitle: !isAvailable
                              ? Text(
                                  'Tidak tersedia di device',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red.shade700,
                                    fontSize: 11,
                                  ),
                                )
                              : null,
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Aktif',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : (!isAvailable
                                  ? Icon(Icons.warning_amber, color: Colors.orange, size: 20)
                                  : null),
                          onTap: !isAvailable
                              ? null
                              : () async {
                                  final success = await controller.setTtsLanguage(code);
                                  if (success) {
                                    Get.snackbar(
                                      'Bahasa Diubah',
                                      'Voice assistant sekarang menggunakan $label',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      duration: const Duration(seconds: 2),
                                    );
                                    // Test speak in new language
                                    await controller.speak('Halo, saya sekarang berbicara dalam $label');
                                  } else {
                                    Get.snackbar(
                                      'Gagal',
                                      'Gagal mengatur bahasa $label',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red.shade100,
                                    );
                                  }
                                },
                        ),
                      );
                    }).toList(),
                  );
                });
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jika bahasa tidak tersedia, download TTS engine dari Play Store (Google Text-to-Speech)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

