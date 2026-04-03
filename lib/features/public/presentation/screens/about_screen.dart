import 'package:flutter/material.dart';

import '../../models/public_models.dart';
import '../public_ui.dart';
import '../url_launcher_helper.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<TeamMember> _members = [
    TeamMember(
      name: 'Luis Emilio Cedano',
      matricula: '2024-0128',
      photoAsset: 'assets/team/luis.png',
      phone: '+1 829-405-5959',
      telegram: '@luiscdano',
      email: 'luiscdano@gmail.com',
    ),
    TeamMember(
      name: 'Rafael J. Silfa',
      matricula: '2024-0034',
      photoAsset: 'assets/team/rafael.png',
      phone: 'PENDIENTE ACTUALIZAR',
      telegram: '@pendiente',
      email: 'pendiente@itla.edu.do',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PublicUi.bg,
      appBar: AppBar(
        title: const Text('Acerca del equipo'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: PublicUi.cardDecoration(),
            child: const Text(
              'Proyecto final de Introduccion al Desarrollo de Aplicaciones Moviles (ITLA).',
              style: TextStyle(color: PublicUi.muted, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          ..._members.map((member) => _MemberCard(member: member)),
          const SizedBox(height: 6),
          Text(
            'Nota: actualiza telefono/correo de Rafael antes de la entrega final.',
            style: TextStyle(color: Colors.orange.shade200, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: PublicUi.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    member.photoAsset,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.white.withValues(alpha: 0.06),
                      child: const Icon(Icons.person, color: PublicUi.muted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          color: PublicUi.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Matricula ${member.matricula}',
                        style: const TextStyle(color: PublicUi.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.phone,
              label: member.phone,
              onTap: member.phone.contains('PENDIENTE')
                  ? null
                  : () => openExternalUrl(
                      context,
                      'tel:${member.phone.replaceAll(' ', '')}',
                    ),
            ),
            _ContactRow(
              icon: Icons.telegram,
              label: member.telegram,
              onTap: member.telegram == '@pendiente'
                  ? null
                  : () => openExternalUrl(
                      context,
                      'https://t.me/${member.telegram.replaceFirst('@', '')}',
                    ),
            ),
            _ContactRow(
              icon: Icons.email_outlined,
              label: member.email,
              onTap: member.email.startsWith('pendiente')
                  ? null
                  : () => openExternalUrl(context, 'mailto:${member.email}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: PublicUi.cream),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: onTap != null ? PublicUi.text : PublicUi.muted,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: PublicUi.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
