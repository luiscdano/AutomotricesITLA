import 'package:flutter/material.dart';

import '../public_ui.dart';
import 'about_screen.dart';
import 'catalog_screen.dart';
import 'forum_screen.dart';
import 'news_list_screen.dart';
import 'videos_screen.dart';

class PublicHubScreen extends StatefulWidget {
  const PublicHubScreen({super.key});

  @override
  State<PublicHubScreen> createState() => _PublicHubScreenState();
}

class _PublicHubScreenState extends State<PublicHubScreen> {
  final PageController _pageController = PageController();
  int _activeSlide = 0;

  final List<_HubSlide> _slides = const [
    _HubSlide(
      icon: Icons.newspaper_rounded,
      title: 'Noticias automotrices',
      subtitle: 'Titulares y detalles de Noticias.',
    ),
    _HubSlide(
      icon: Icons.video_library_rounded,
      title: 'Videos educativos',
      subtitle: 'Material de apoyo sobre automotrices.',
    ),
    _HubSlide(
      icon: Icons.forum_rounded,
      title: 'Foro comunitario',
      subtitle: 'Lectura pública de temas y respuestas recientes.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PublicUi.bg,
      appBar: AppBar(
        title: const Text('Área publica'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                color: PublicUi.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accesos rapidos del área pública.',
              style: TextStyle(color: PublicUi.muted),
            ),
            const SizedBox(height: 12),
            Container(
              height: 170,
              decoration: PublicUi.cardDecoration(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _activeSlide = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, color: PublicUi.cream, size: 34),
                        const SizedBox(height: 10),
                        Text(
                          slide.title,
                          style: const TextStyle(
                            color: PublicUi.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide.subtitle,
                          style: const TextStyle(color: PublicUi.muted),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: _activeSlide == index ? 18 : 7,
                  decoration: BoxDecoration(
                    color: _activeSlide == index
                        ? PublicUi.brown
                        : Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _HubTile(
                  icon: Icons.newspaper_rounded,
                  title: 'Noticias',
                  subtitle: 'Automotrices',
                  onTap: () => _push(context, const NewsListScreen()),
                ),
                _HubTile(
                  icon: Icons.smart_display_rounded,
                  title: 'Videos',
                  subtitle: 'Educativos',
                  onTap: () => _push(context, const VideosScreen()),
                ),
                _HubTile(
                  icon: Icons.directions_car_filled_rounded,
                  title: 'Catalogo',
                  subtitle: 'De autos',
                  onTap: () => _push(context, const CatalogScreen()),
                ),
                _HubTile(
                  icon: Icons.forum,
                  title: 'Foro público',
                  subtitle: 'Solo lectura',
                  onTap: () => _push(context, const ForumScreen()),
                ),
                _HubTile(
                  icon: Icons.groups_2_rounded,
                  title: 'Acerca de',
                  subtitle: 'Equipo',
                  onTap: () => _push(context, const AboutScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _HubSlide {
  const _HubSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: PublicUi.cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: PublicUi.cream),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: PublicUi.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: PublicUi.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
