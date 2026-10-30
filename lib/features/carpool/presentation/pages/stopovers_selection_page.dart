import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/stopovers_remote_datasource.dart';
import '../../data/repositories/stopovers_repository_impl.dart';
import '../../domain/entities/route_option.dart';
import '../../domain/entities/stopover.dart';
import '../../domain/usecases/get_stopovers_usecase.dart';
import '../bloc/stopovers/stopovers_bloc.dart';
import '../bloc/stopovers/stopovers_event.dart';
import '../bloc/stopovers/stopovers_state.dart';

/// "Add stopovers to get more passengers" screen matching the attached screenshot.
/// Allows drivers to select and add intermediate halts/cities along the route.
class StopoversSelectionPage extends StatefulWidget {
  final String origin;
  final String destination;
  final RouteOption? selectedRoute;
  final VoidCallback onBack;
  final ValueChanged<List<String>> onStopoversConfirmed;

  const StopoversSelectionPage({
    super.key,
    required this.origin,
    required this.destination,
    this.selectedRoute,
    required this.onBack,
    required this.onStopoversConfirmed,
  });

  @override
  State<StopoversSelectionPage> createState() => _StopoversSelectionPageState();
}

class _StopoversSelectionPageState extends State<StopoversSelectionPage> {
  late final StopoversBloc _stopoversBloc;
  bool _isLocalBloc = false;

  @override
  void initState() {
    super.initState();
    try {
      _stopoversBloc = context.read<StopoversBloc>();
    } catch (_) {
      _isLocalBloc = true;
      final remoteDataSource = StopoversRemoteDataSourceImpl();
      final repository =
          StopoversRepositoryImpl(remoteDataSource: remoteDataSource);
      _stopoversBloc = StopoversBloc(
        getStopoversUseCase: GetStopoversUseCase(repository),
      );
    }

    _stopoversBloc.add(
      LoadStopoversEvent(
        origin: widget.origin,
        destination: widget.destination,
        selectedRoute: widget.selectedRoute,
      ),
    );
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _stopoversBloc.close();
    }
    super.dispose();
  }

  void _onConfirm() {
    final selectedNames = _stopoversBloc.state.selectedStopoverNames;
    widget.onStopoversConfirmed(selectedNames);
  }

  void _showAddCityDialog() {
    final textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Stopover City',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1E34),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textCtrl,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A1E34),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter city, junction, or landmark',
                  hintStyle: const TextStyle(color: Color(0xFF708C91)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF0070E0)),
                  filled: true,
                  fillColor: const Color(0xFFF4F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (val) {
                  final trimmed = val.trim();
                  if (trimmed.isNotEmpty) {
                    _stopoversBloc.add(AddCustomStopoverEvent(trimmed));
                    Navigator.pop(bottomSheetContext);
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0070E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final trimmed = textCtrl.text.trim();
                    if (trimmed.isNotEmpty) {
                      _stopoversBloc.add(AddCustomStopoverEvent(trimmed));
                      Navigator.pop(bottomSheetContext);
                    }
                  },
                  child: const Text(
                    'Add City',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stopoversBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Back Arrow matching screenshot
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0070E0),
                        size: 26,
                      ),
                      onPressed: widget.onBack,
                    ),

                    const SizedBox(height: 24),

                    // Big Bold Title matching screenshot: "Add stopovers to get more passengers"
                    Text(
                      'Add stopovers to get\nmore passengers',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0A1E34),
                        height: 1.22,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Stopover List & "Add city"
                    Expanded(
                      child: BlocBuilder<StopoversBloc, StopoversState>(
                        builder: (context, state) {
                          if (state.isLoading && state.stopovers.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0070E0),
                                ),
                              ),
                            );
                          }

                          return ListView(
                            padding: const EdgeInsets.only(bottom: 90),
                            children: [
                              for (int i = 0;
                                  i < state.stopovers.length;
                                  i++) ...[
                                _buildStopoverTile(state.stopovers[i]),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFEFF3F6),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // "Add city" button matching screenshot
                              InkWell(
                                onTap: _showAddCityDialog,
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    'Add city',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0070E0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Right Floating Button matching screenshot
              Positioned(
                right: 20,
                bottom: 24,
                child: Material(
                  color: const Color(0xFF0070E0),
                  shape: const CircleBorder(),
                  elevation: 6,
                  shadowColor: const Color(0xFF0070E0).withAlpha(120),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _onConfirm,
                    child: Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopoverTile(Stopover stopover) {
    return InkWell(
      onTap: () {
        _stopoversBloc.add(ToggleStopoverEvent(stopover.id));
      },
      splashColor: const Color(0xFF0070E0).withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Custom Rounded Checkbox matching screenshot
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: stopover.isSelected
                    ? const Color(0xFF0070E0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5.5),
                border: Border.all(
                  color: const Color(0xFF0070E0),
                  width: stopover.isSelected ? 0 : 2.0,
                ),
              ),
              alignment: Alignment.center,
              child: stopover.isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Stopover City Name
            Expanded(
              child: Text(
                stopover.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1E34),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
