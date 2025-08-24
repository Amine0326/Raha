import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;

import 'package:flutter/foundation.dart';
import '../services/apiservice.dart';
class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  final List<Map<String, dynamic>> allCenters = [

  ];

  List<Map<String, dynamic>> filteredCenters = [];
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  late WebViewController _webViewController;
  bool _isLoading = false;
  String? _error;
  String _currentMapType = 'street';

  bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  bool _centerIsActive(Map<String, dynamic> center) {
    final v = center['is_active'] ?? center['active'];
    return v == null ? true : _parseBool(v);
  }

  @override
  void initState() {
    super.initState();
    filteredCenters = allCenters; // سيتم استبدالها بعد الجلب من الخادم
    _initializeWebView();
    // جلب المراكز من API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCenters();
    });
  }

  Future<void> _fetchCenters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().get('/centers', withAuth: true);
      if (data is List) {
        final fetched = data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() {
          allCenters
            ..clear()
            ..addAll(fetched);
          // اعرض فقط المراكز النشطة
          filteredCenters = allCenters.where(_centerIsActive).toList();
        });
        if (kDebugMode) {
          print('🏥 تم جلب المراكز (${filteredCenters.length}) من الخادم.');
        }
        // تحديث الخريطة بعد تحديث البيانات
        _webViewController.loadHtmlString(_generateMapHtml());
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب المراكز.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
      if (kDebugMode) {
        print('🚫 خطأ أثناء جلب المراكز: $e');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ غير متوقع أثناء جلب المراكز.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ غير متوقع أثناء جلب المراكز.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
      if (kDebugMode) {
        print('❗ استثناء غير متوقع في _fetchCenters: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_generateMapHtml());
  }

  String _generateMapHtml() {
    final centerMarkers = filteredCenters
        .map((center) {
          return '''
        L.marker([${center['latitude']}, ${center['longitude']}])
          .addTo(map)
          .bindPopup('<div style="text-align: center; font-family: Arial;"><b>${center['name']}</b><br><small>${center['address']}</small></div>');
      ''';
        })
        .join('\n');

    String tileUrl;
    String attribution;

    switch (_currentMapType) {
      case 'satellite':
        tileUrl =
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        attribution = '© Esri';
        break;
      case 'terrain':
        tileUrl = 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
        attribution = '© OpenTopoMap';
        break;
      default:
        tileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
        attribution = '© OpenStreetMap contributors';
    }

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>مراكزنا الطبية</title>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <style>
            body { margin: 0; padding: 0; }
            #map { height: 100vh; width: 100%; }
            .leaflet-popup-content { text-align: center; }
        </style>
    </head>
    <body>
        <div id="map"></div>
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <script>
            var map = L.map('map').setView([36.7527780, 3.0422220], 13);

            L.tileLayer('$tileUrl', {
                attribution: '$attribution',
                maxZoom: 18
            }).addTo(map);

            $centerMarkers
        </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AppTheme.getBackgroundColor(isDark),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(isDark),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppTheme.getOnSurfaceColor(isDark),
                  size: 18,
                ),
              ),
            ),
            title: Text(
              'مراكزنا الطبية',
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: _selectedIndex == 1
                ? [
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.layers_rounded,
                        color: AppTheme.getOnSurfaceColor(isDark),
                        size: 20,
                      ),
                      onSelected: (value) => _changeMapType(value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'street',
                          child: Row(
                            children: [
                              Icon(Icons.map_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('خريطة الشوارع'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'satellite',
                          child: Row(
                            children: [
                              Icon(Icons.satellite_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('صور الأقمار الصناعية'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'terrain',
                          child: Row(
                            children: [
                              Icon(Icons.terrain_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('التضاريس'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: _selectedIndex == 0
              ? Column(
                  children: [
                    _buildSearchField(isDark),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchCenters,
                        child: _buildCentersList(isDark),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildMapSearchField(isDark),
                    Expanded(child: _buildMapView()),
                  ],
                ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(isDark),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.getPrimaryColor(isDark),
              unselectedItemColor: AppTheme.getHintColor(isDark),
              selectedFontSize: 12,
              unselectedFontSize: 11,
              iconSize: 22,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.view_list_rounded),
                  label: 'القائمة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map_rounded),
                  label: 'الخريطة',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCenters,
        decoration: InputDecoration(
          hintText: 'البحث عن مركز طبي...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterCenters('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.getCardColor(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMapSearchField(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _searchOnMap,
        decoration: InputDecoration(
          hintText: 'البحث في الخريطة...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppTheme.getCardColor(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCentersList(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.getHintColor(isDark),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getHintColor(isDark),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchCenters,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              )
            ],
          ),
        ),
      );
    }

    if (filteredCenters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.getHintColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مراكز تطابق البحث',
              style: TextStyle(
                color: AppTheme.getHintColor(isDark),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: filteredCenters.length,
      itemBuilder: (context, index) {
        final center = filteredCenters[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCenterCard(context, isDark, center),
        );
      },
    );
  }

  void _filterCenters(String query) {
    setState(() {
      final activeCenters = allCenters.where(_centerIsActive);
      if (query.isEmpty) {
        filteredCenters = activeCenters.toList();
      } else {
        filteredCenters = activeCenters.where((center) {
          final name = center['name'].toString().toLowerCase();
          final address = center['address'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || address.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _searchOnMap(String query) {
    if (query.isNotEmpty) {
      final activeCenters = allCenters.where(_centerIsActive);
      final matchingCenter = activeCenters.firstWhere(
        (center) => center['name'].toString().toLowerCase().contains(
          query.toLowerCase(),
        ),
        orElse: () => {},
      );

      if (matchingCenter.isNotEmpty) {
        _webViewController.runJavaScript('''
          map.setView([${matchingCenter['latitude']}, ${matchingCenter['longitude']}], 15);
        ''');
      }
    }
  }

  void _changeMapType(String mapType) {
    setState(() {
      _currentMapType = mapType;
    });
    _webViewController.loadHtmlString(_generateMapHtml());
  }

  Widget _buildMapView() {
    return WebViewWidget(controller: _webViewController);
  }

  Widget _buildCenterCard(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> center,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center['name'],
                        style: TextStyle(
                          color: AppTheme.getOnSurfaceColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: center['is_active']
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          center['is_active'] ? 'نشط' : 'غير نشط',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Compact Description
            Text(
              center['description'],
              style: TextStyle(
                color: AppTheme.getHintColor(isDark),
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Compact Info Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.getPrimaryColor(isDark),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          center['address'],
                          style: TextStyle(
                            color: AppTheme.getHintColor(isDark),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: AppTheme.getPrimaryColor(isDark),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  center['phone'],
                  style: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // See More Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCenterDetails(context, center, isDark),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(isDark),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_rounded, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'عرض المزيد',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _openMap(String latitude, String longitude) async {
    // Using Google Maps web URL for cross-platform compatibility
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('لا يمكن فتح الخريطة');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في فتح الخريطة');
    }
  }

  Future<void> _dialPhone(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]+'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('لا يمكن إجراء المكالمة');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في إجراء المكالمة');
    }
  }

  Future<void> _launchWebsite(String url) async {
    var normalized = url.trim();
    if (!(normalized.startsWith('http://') || normalized.startsWith('https://'))){
      normalized = 'https://$normalized';
    }
    final uri = Uri.parse(normalized);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('لا يمكن فتح الرابط');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء فتح الرابط');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showCenterDetails(
    BuildContext context,
    Map<String, dynamic> center,
    bool isDark,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CenterDetailsScreen(center: center),
      ),
    );
  }
}

class CenterDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> center;

  const CenterDetailsScreen({super.key, required this.center});

  @override
  State<CenterDetailsScreen> createState() => _CenterDetailsScreenState();
}

class _CenterDetailsScreenState extends State<CenterDetailsScreen> {
  late WebViewController _mapController;

  @override
  void initState() {
    super.initState();
    _initializeMapController();
  }

  void _initializeMapController() {
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
            <style>
                body { margin: 0; padding: 0; }
                #map { height: 100vh; width: 100%; }
            </style>
        </head>
        <body>
            <div id="map"></div>
            <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
            <script>
                var map = L.map('map').setView([${widget.center['latitude']}, ${widget.center['longitude']}], 15);

                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap contributors'
                }).addTo(map);

                L.marker([${widget.center['latitude']}, ${widget.center['longitude']}])
                  .addTo(map)
                  .bindPopup('<b>${widget.center['name']}</b><br>${widget.center['address']}')
                  .openPopup();
            </script>
        </body>
        </html>
      ''');
    }


  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _dialPhone(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]+'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('لا يمكن إجراء المكالمة');
      }
    } catch (e) {
      _showError('حدث خطأ في إجراء المكالمة');
    }
  }

  Future<void> _launchWebsite(String url) async {
    var normalized = url.trim();
    if (!(normalized.startsWith('http://') || normalized.startsWith('https://'))){
      normalized = 'https://$normalized';
    }
    final uri = Uri.parse(normalized);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('لا يمكن فتح الرابط');
      }
    } catch (e) {
      _showError('حدث خطأ أثناء فتح الرابط');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          body: CustomScrollView(
            slivers: [
              // Hero Header
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.getBackgroundColor(isDark),
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(isDark),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.getPrimaryColor(
                            isDark,
                          ).withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppTheme.getOnSurfaceColor(isDark),
                      size: 20,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'تفاصيل المركز',
                    style: TextStyle(
                      color: AppTheme.getOnSurfaceColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(isDark),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getPrimaryColor(
                              isDark,
                            ).withValues(alpha: 0.08),
                            offset: const Offset(0, 4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.getPrimaryColor(isDark),
                                  AppTheme.getPrimaryColor(
                                    isDark,
                                  ).withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.center['name'],
                                  style: TextStyle(
                                    color: AppTheme.getOnSurfaceColor(isDark),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.center['is_active']
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.center['is_active']
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.center['is_active']
                                            ? 'نشط'
                                            : 'غير نشط',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Description Section
                    _buildModernSection(
                      isDark,
                      'الوصف',
                      Icons.description_outlined,
                      widget.center['description'],
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            isDark,
                            'اتصال',
                            Icons.phone,
                            const Color(0xFF10B981),
                            () async {
                              await _dialPhone(widget.center['phone']);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            isDark,
                            'موقع ويب',
                            Icons.language,
                            const Color(0xFF3B82F6),
                            () async {
                              await _launchWebsite(widget.center['website']);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Contact Info Grid
                    _buildContactGrid(isDark),

                    const SizedBox(height: 20),

                    // Map Section
                    _buildMapSection(isDark),

                    const SizedBox(height: 20),

                    // Rooms Section
                    if (widget.center['rooms'] != null &&
                        (widget.center['rooms'] as List).isNotEmpty)
                      _buildRoomsSection(isDark)
                    else
                      _buildNoRoomsSection(isDark),

                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    bool isDark,
    String title,
    IconData icon,
    String content,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(
                    isDark,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.getPrimaryColor(isDark),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    bool isDark,
    IconData icon,
    String label,
    String value, {
    bool isPhone = false,
    bool isWebsite = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.getPrimaryColor(isDark),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (isPhone || isWebsite)
                  GestureDetector(
                    onTap: () async {
                      if (isPhone) {
                        await _dialPhone(value);
                      } else if (isWebsite) {
                        await _launchWebsite(value);
                      }
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.getPrimaryColor(isDark),
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      color: AppTheme.getOnSurfaceColor(isDark),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(bool isDark, Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryColor(isDark),
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getPrimaryColor(
                        isDark,
                      ).withValues(alpha: 0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.bed, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'غرفة ${room['room_number']}',
                          style: TextStyle(
                            color: AppTheme.getOnSurfaceColor(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: room['is_available']
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (room['is_available']
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFEF4444))
                                        .withValues(alpha: 0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Text(
                            room['is_available'] ? 'متاحة' : 'محجوزة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'نوع: ${room['type']} • السعة: ${room['capacity']} أشخاص',
                      style: TextStyle(
                        color: AppTheme.getHintColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(
                    isDark,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.getPrimaryColor(
                      isDark,
                    ).withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '${room['price_per_night']} دج/ليلة',
                  style: TextStyle(
                    color: AppTheme.getPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            room['description'],
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(
    bool isDark,
    String title,
    IconData icon,
    String content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.getPrimaryColor(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    bool isDark,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactGrid(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.contact_phone,
                  color: AppTheme.getPrimaryColor(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'معلومات الاتصال',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            isDark,
            Icons.location_on,
            'العنوان',
            widget.center['address'],
          ),
          _buildContactItem(
            isDark,
            Icons.phone,
            'الهاتف',
            widget.center['phone'],
            isClickable: true,
            isPhone: true,
          ),
          _buildContactItem(
            isDark,
            Icons.email,
            'البريد الإلكتروني',
            widget.center['email'],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    bool isDark,
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.getPrimaryColor(isDark),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isClickable)
                  GestureDetector(
                    onTap: () async {
                      if (isPhone) {
                        await _dialPhone(value);
                      } else {
                        await _launchWebsite(value);
                      }
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.getPrimaryColor(isDark),
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      color: AppTheme.getOnSurfaceColor(isDark),
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                        AppTheme.getPrimaryColor(
                          isDark,
                        ).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    color: AppTheme.getPrimaryColor(isDark),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'الموقع على الخريطة',
                  style: TextStyle(
                    color: AppTheme.getOnSurfaceColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getPrimaryColor(
                    isDark,
                  ).withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: WebViewWidget(controller: _mapController),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bed_outlined,
                  color: AppTheme.getPrimaryColor(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'الغرف المتاحة (${(widget.center['rooms'] as List).length})',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...((widget.center['rooms'] as List)
              .map((room) => _buildModernRoomCard(isDark, room))
              .toList()),
        ],
      ),
    );
  }

  Widget _buildNoRoomsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bed_outlined,
                  color: AppTheme.getPrimaryColor(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'الغرف المتاحة',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getHintColor(isDark).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getHintColor(isDark).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.getHintColor(isDark),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'لا توجد غرف متاحة حالياً',
                  style: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRoomCard(bool isDark, Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.08),
                  AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bed, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'غرفة ${room['room_number']}',
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: room['is_available']
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              room['is_available'] ? 'متاحة' : 'محجوزة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'نوع: ${room['type']} • السعة: ${room['capacity']} أشخاص',
                        style: TextStyle(
                          color: AppTheme.getHintColor(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['description'],
                  style: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: AppTheme.getPrimaryColor(isDark),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'السعر: ',
                      style: TextStyle(
                        color: AppTheme.getHintColor(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${room['price_per_night']} دج/ليلة',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
