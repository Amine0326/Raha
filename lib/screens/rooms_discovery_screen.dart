import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;
import '../models/room_models.dart';
import '../services/apiservice.dart';

class RoomsDiscoveryScreen extends StatefulWidget {
  const RoomsDiscoveryScreen({super.key});

  @override
  State<RoomsDiscoveryScreen> createState() => _RoomsDiscoveryScreenState();
}

class _RoomsDiscoveryScreenState extends State<RoomsDiscoveryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];
  final RoomFilters _filters = RoomFilters();
  bool _showFilters = false;
  late AnimationController _filterAnimationController;
  bool _isLoading = false;
  String? _error;

  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
    // Fetch rooms after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRooms();
    });
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().get('/rooms', withAuth: true);
      if (data is List) {
        final rooms = data
            .map<Room>((e) => Room.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        setState(() {
          _allRooms = rooms;
          _filteredRooms = List<Room>.from(_allRooms);
        });
        if (kDebugMode) {
          print('🛏️ تم جلب الغرف (${_allRooms.length}) من الخادم.');
        }
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب الغرف.');
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
        print('🚫 خطأ أثناء جلب الغرف: $e');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ غير متوقع أثناء جلب الغرف.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ غير متوقع أثناء جلب الغرف.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
      if (kDebugMode) {
        print('❗ استثناء غير متوقع في _fetchRooms: $e');
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
    _filterAnimationController.dispose();
    super.dispose();
  }


  List<MedicalCenter> _getUniqueCenters() {
    final centerMap = <int, MedicalCenter>{};
    for (final room in _allRooms) {
      centerMap[room.center.id] = room.center;
    }
    return centerMap.values.toList();
  }

  List<int> _getUniqueCapacities() {
    final capacities = _allRooms.map((room) => room.capacity).toSet().toList();
    capacities.sort();
    return capacities;
  }

  void _applyFilters() {
    setState(() {
      _filteredRooms = _allRooms.where((room) {
        // Search query filter
        if (_filters.searchQuery.isNotEmpty) {
          final query = _filters.searchQuery.toLowerCase();
          if (!room.roomNumber.toLowerCase().contains(query) &&
              !room.type.toLowerCase().contains(query) &&
              !room.description.toLowerCase().contains(query) &&
              !room.center.name.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Availability filter
        if (_filters.isAvailable != null &&
            room.isAvailable != _filters.isAvailable) {
          return false;
        }

        // Capacity filter
        if (_filters.capacity != null && room.capacity != _filters.capacity) {
          return false;
        }

        // Center filter
        if (_filters.centerId != null && room.centerId != _filters.centerId) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _filters.searchQuery = query;
    _applyFilters();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _resetFilters() {
    setState(() {
      _filters.reset();
      _searchController.clear();
      _filteredRooms = _allRooms;
    });
  }

  Future<void> _handleRefreshRooms() async {
    await _fetchRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchRooms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context, isDark),

                    // Search and Filter Bar
                    _buildSearchAndFilterBar(context, isDark),

                    // Filter Panel
                    _buildFilterPanel(context, isDark),

                    // Results Header
                    _buildResultsHeader(context, isDark),

                    // Rooms List
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _buildRoomsList(context, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getPrimaryColor(isDark),
            AppTheme.getSecondaryColor(isDark),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استكشف الغرف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'اكتشف غرفنا المميزة والمجهزة بأحدث التقنيات',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Icon(
              Icons.hotel_rounded,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(isDark),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث عن غرفة، نوع، أو مركز...',
                  hintStyle: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: screenWidth * 0.035,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.getHintColor(isDark),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.035,
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.03),

          // Filter Button
          GestureDetector(
            onTap: _toggleFilters,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.035),
              decoration: BoxDecoration(
                gradient: _showFilters
                    ? LinearGradient(
                        colors: [
                          AppTheme.getPrimaryColor(isDark),
                          AppTheme.getSecondaryColor(isDark),
                        ],
                      )
                    : null,
                color: _showFilters ? null : AppTheme.getCardColor(isDark),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.tune,
                color: _showFilters
                    ? Colors.white
                    : AppTheme.getOnSurfaceColor(isDark),
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _filterAnimation.value * 200,
          child: _filterAnimation.value > 0
              ? SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(isDark),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تصفية النتائج',
                              style: TextStyle(
                                color: AppTheme.getOnSurfaceColor(isDark),
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _resetFilters,
                              child: Text(
                                'إعادة تعيين',
                                style: TextStyle(
                                  color: AppTheme.getPrimaryColor(isDark),
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenWidth * 0.03),

                        // Availability Filter
                        Text(
                          'الحالة',
                          style: TextStyle(
                            color: AppTheme.getOnSurfaceColor(isDark),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Wrap(
                          spacing: screenWidth * 0.02,
                          children: [
                            _buildFilterChip(
                              context,
                              isDark,
                              'متاحة فقط',
                              _filters.isAvailable == true,
                              () {
                                setState(() {
                                  _filters.isAvailable =
                                      _filters.isAvailable == true
                                      ? null
                                      : true;
                                  _applyFilters();
                                });
                              },
                            ),
                            _buildFilterChip(
                              context,
                              isDark,
                              'جميع الغرف',
                              _filters.isAvailable == null,
                              () {
                                setState(() {
                                  _filters.isAvailable = null;
                                  _applyFilters();
                                });
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: screenWidth * 0.04),

                        // Capacity Filter
                        Text(
                          'السعة',
                          style: TextStyle(
                            color: AppTheme.getOnSurfaceColor(isDark),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Wrap(
                          spacing: screenWidth * 0.02,
                          runSpacing: screenWidth * 0.02,
                          children: _getUniqueCapacities().map((capacity) {
                            return _buildFilterChip(
                              context,
                              isDark,
                              '$capacity ${capacity == 1 ? 'شخص' : 'أشخاص'}',
                              _filters.capacity == capacity,
                              () {
                                setState(() {
                                  _filters.capacity =
                                      _filters.capacity == capacity
                                      ? null
                                      : capacity;
                                  _applyFilters();
                                });
                              },
                            );
                          }).toList(),
                        ),

                        SizedBox(height: screenWidth * 0.04),

                        // Center Filter
                        Text(
                          'المركز الطبي',
                          style: TextStyle(
                            color: AppTheme.getOnSurfaceColor(isDark),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Column(
                          children: _getUniqueCenters().map((center) {
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: screenWidth * 0.02,
                              ),
                              child: _buildCenterFilterChip(
                                context,
                                isDark,
                                center,
                                _filters.centerId == center.id,
                                () {
                                  setState(() {
                                    _filters.centerId =
                                        _filters.centerId == center.id
                                        ? null
                                        : center.id;
                                    _applyFilters();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    bool isDark,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(isDark),
                    AppTheme.getSecondaryColor(isDark),
                  ],
                )
              : null,
          color: isSelected ? null : AppTheme.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.getHintColor(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.getOnSurfaceColor(isDark),
            fontSize: screenWidth * 0.032,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFilterChip(
    BuildContext context,
    bool isDark,
    MedicalCenter center,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(isDark),
                    AppTheme.getSecondaryColor(isDark),
                  ],
                )
              : null,
          color: isSelected ? null : AppTheme.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.getHintColor(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_hospital,
              color: isSelected
                  ? Colors.white
                  : AppTheme.getPrimaryColor(isDark),
              size: screenWidth * 0.04,
            ),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                center.name,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.getOnSurfaceColor(isDark),
                  fontSize: screenWidth * 0.032,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تم العثور على ${_filteredRooms.length} غرفة',
            style: TextStyle(
              color: AppTheme.getOnSurfaceColor(isDark),
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_filteredRooms.length != _allRooms.length)
            Text(
              'من أصل ${_allRooms.length}',
              style: TextStyle(
                color: AppTheme.getHintColor(isDark),
                fontSize: screenWidth * 0.032,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                size: screenWidth * 0.16,
                color: AppTheme.getHintColor(isDark),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getHintColor(isDark),
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              ElevatedButton.icon(
                onPressed: _fetchRooms,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              )
            ],
          ),
        ),
      );
    }

    if (_filteredRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: screenWidth * 0.15,
              color: AppTheme.getHintColor(isDark),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'لم يتم العثور على غرف',
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'جرب تغيير معايير البحث أو المرشحات',
              style: TextStyle(
                color: AppTheme.getHintColor(isDark),
                fontSize: screenWidth * 0.035,
              ),
            ),
            SizedBox(height: screenWidth * 0.06),
            ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getPrimaryColor(isDark),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenWidth * 0.03,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              child: Text(
                'إعادة تعيين المرشحات',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: _filteredRooms.length,
      itemBuilder: (context, index) {
        return _buildRoomCard(context, isDark, _filteredRooms[index]);
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, bool isDark, Room room) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showRoomDetails(context, room),
      child: Container(
        margin: EdgeInsets.only(bottom: screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDark),
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Header
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                    AppTheme.getSecondaryColor(isDark).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.04),
                  topRight: Radius.circular(screenWidth * 0.04),
                ),
              ),
              child: Row(
                children: [
                  // Room Icon
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.getPrimaryColor(isDark),
                          AppTheme.getSecondaryColor(isDark),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    ),
                    child: Icon(
                      _getRoomIcon(room.type),
                      color: Colors.white,
                      size: screenWidth * 0.05,
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  // Room Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'غرفة ${room.roomNumber}',
                              style: TextStyle(
                                color: AppTheme.getOnSurfaceColor(isDark),
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.025,
                                vertical: screenWidth * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: room.isAvailable
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.02,
                                ),
                              ),
                              child: Text(
                                room.availabilityText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.028,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          room.type,
                          style: TextStyle(
                            color: AppTheme.getHintColor(isDark),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Room Details
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    room.description,
                    style: TextStyle(
                      color: AppTheme.getOnSurfaceColor(isDark),
                      fontSize: screenWidth * 0.035,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.03),

                  // Room Features
                  Row(
                    children: [
                      _buildFeatureChip(
                        context,
                        isDark,
                        Icons.people,
                        '${room.capacity} أشخاص',
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      if (room.isAccessible)
                        _buildFeatureChip(
                          context,
                          isDark,
                          Icons.accessible,
                          'مناسبة للإعاقة',
                        ),
                    ],
                  ),

                  SizedBox(height: screenWidth * 0.03),

                  // Center Info
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(isDark),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                      border: Border.all(
                        color: AppTheme.getHintColor(
                          isDark,
                        ).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          color: AppTheme.getPrimaryColor(isDark),
                          size: screenWidth * 0.04,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            room.center.name,
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: screenWidth * 0.032,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.03),

                  // Price Display
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.getPrimaryColor(
                            isDark,
                          ).withValues(alpha: 0.1),
                          AppTheme.getSecondaryColor(
                            isDark,
                          ).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'السعر لليلة الواحدة',
                          style: TextStyle(
                            color: AppTheme.getHintColor(isDark),
                            fontSize: screenWidth * 0.032,
                          ),
                        ),
                        Text(
                          room.formattedPrice,
                          style: TextStyle(
                            color: AppTheme.getPrimaryColor(isDark),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildFeatureChip(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(
          color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.getPrimaryColor(isDark),
            size: screenWidth * 0.035,
          ),
          SizedBox(width: screenWidth * 0.015),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getPrimaryColor(isDark),
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoomIcon(String roomType) {
    switch (roomType) {
      case 'فردية':
        return Icons.single_bed;
      case 'مزدوجة':
        return Icons.bed;
      case 'جناح ملكي':
        return Icons.hotel;
      case 'عناية مركزة':
        return Icons.local_hospital;
      default:
        return Icons.hotel_rounded;
    }
  }

  void _showRoomDetails(BuildContext context, Room room) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<theme_provider.ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(isDark),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.06),
                topRight: Radius.circular(screenWidth * 0.06),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: screenWidth * 0.03),
                  width: screenWidth * 0.12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getHintColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تفاصيل غرفة ${room.roomNumber}',
                          style: TextStyle(
                            color: AppTheme.getOnSurfaceColor(isDark),
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.getOnSurfaceColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room basic info
                        _buildDetailSection(context, isDark, 'معلومات الغرفة', [
                          _buildDetailRow(
                            context,
                            isDark,
                            'رقم الغرفة',
                            room.roomNumber,
                          ),
                          _buildDetailRow(context, isDark, 'النوع', room.type),
                          _buildDetailRow(
                            context,
                            isDark,
                            'السعة',
                            '${room.capacity} أشخاص',
                          ),
                          _buildDetailRow(
                            context,
                            isDark,
                            'الحالة',
                            room.availabilityText,
                          ),
                          _buildDetailRow(
                            context,
                            isDark,
                            'إمكانية الوصول',
                            room.accessibilityText,
                          ),
                        ]),

                        SizedBox(height: screenWidth * 0.04),

                        // Center info
                        _buildDetailSection(context, isDark, 'معلومات المركز', [
                          _buildDetailRow(
                            context,
                            isDark,
                            'اسم المركز',
                            room.center.name,
                          ),
                          _buildDetailRow(
                            context,
                            isDark,
                            'العنوان',
                            room.center.address,
                          ),
                          _buildDetailRow(
                            context,
                            isDark,
                            'الهاتف',
                            room.center.phone,
                          ),
                          _buildDetailRow(
                            context,
                            isDark,
                            'البريد الإلكتروني',
                            room.center.email,
                          ),
                        ]),

                        SizedBox(height: screenWidth * 0.04),

                        // Description
                        _buildDetailSection(context, isDark, 'الوصف', [
                          Text(
                            room.description,
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: screenWidth * 0.035,
                              height: 1.5,
                            ),
                          ),
                        ]),

                        SizedBox(height: screenWidth * 0.06),

                        // Price and booking button
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.getPrimaryColor(
                                  isDark,
                                ).withValues(alpha: 0.1),
                                AppTheme.getSecondaryColor(
                                  isDark,
                                ).withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.04,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'السعر لليلة الواحدة',
                                    style: TextStyle(
                                      color: AppTheme.getHintColor(isDark),
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                  Text(
                                    room.formattedPrice,
                                    style: TextStyle(
                                      color: AppTheme.getPrimaryColor(isDark),
                                      fontSize: screenWidth * 0.05,
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    bool isDark,
    String title,
    List<Widget> children,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: AppTheme.getHintColor(isDark).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.getOnSurfaceColor(isDark),
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    bool isDark,
    String label,
    String value,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.25,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.getHintColor(isDark),
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: screenWidth * 0.032,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
