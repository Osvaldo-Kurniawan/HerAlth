import 'package:flutter/material.dart';

class PartnerLogoStrip extends StatelessWidget {
  final double schoolSize;
  final double opsiWidth;
  final double opsiHeight;
  final double gap;

  const PartnerLogoStrip({
    super.key,
    required this.schoolSize,
    required this.opsiWidth,
    required this.opsiHeight,
    this.gap = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'School and Opsi logos',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo_sekolah.png',
            width: schoolSize,
            height: schoolSize,
            fit: BoxFit.contain,
            semanticLabel: 'Al Azhar school logo',
          ),
          SizedBox(width: gap),
          SizedBox(
            width: opsiWidth,
            height: opsiHeight,
            child: Image.asset(
              'assets/images/logo_opsi.png',
              fit: BoxFit.contain,
              semanticLabel: 'Olimpiade Penelitian Siswa Indonesia logo',
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeBrandRow extends StatelessWidget {
  const WelcomeBrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 280;
        return Semantics(
          container: true,
          label: 'Moon, school, and Opsi logos',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.nightlight_round_outlined,
                size: isCompact ? 28 : 36,
                color: const Color(0xFFD6708A),
              ),
              SizedBox(width: isCompact ? 6 : 8),
              PartnerLogoStrip(
                schoolSize: isCompact ? 28 : 36,
                opsiWidth: isCompact ? 56 : 72,
                opsiHeight: isCompact ? 28 : 36,
                gap: isCompact ? 4 : 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
