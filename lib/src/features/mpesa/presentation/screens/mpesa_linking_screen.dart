import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/mpesa/services/unified_mpesa_sync_service.dart';
import 'package:expensetracker/src/features/mpesa/presentation/screens/setup_database_screen.dart';
import 'package:expensetracker/src/shared/theme.dart';

class MpesaLinkingScreen extends StatefulWidget {
  const MpesaLinkingScreen({super.key});

  @override
  State<MpesaLinkingScreen> createState() => _MpesaLinkingScreenState();
}

class _MpesaLinkingScreenState extends State<MpesaLinkingScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _syncService = UnifiedMpesaSyncService();
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isLinking = false;
  bool _isLinked = false;
  bool _showSuccess = false;
  String? _linkedPhone;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLinkingStatus();
    _syncService.addListener(_onSyncServiceUpdate);
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  void _onSyncServiceUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _checkLinkingStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    final phone = user?.userMetadata?['mpesa_phone'];
    
    if (phone != null) {
      setState(() {
        _isLinked = true;
        _linkedPhone = phone;
        _phoneController.text = phone;
        _currentStep = 3;
      });
    }
  }

  Future<void> _linkMpesaAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLinking = true;
      _currentStep = 1;
    });

    try {
      // Step 1: Request permissions
      await Future.delayed(const Duration(milliseconds: 500));
      final hasPermission = await _syncService.requestPermissions();
      
      if (!hasPermission) {
        throw Exception('SMS permission is required for M-Pesa integration');
      }

      setState(() => _currentStep = 2);
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Update user metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {'mpesa_phone': _phoneController.text.trim()},
        ),
      );

      // Step 3: Test connection
      await _syncService.testConnection();
      
      // Step 4: Start monitoring and sync
      await _syncService.startMonitoring();
      final synced = await _syncService.syncHistoricalSms(); // No limit - process all historical transactions

      setState(() {
        _isLinked = true;
        _linkedPhone = _phoneController.text.trim();
        _currentStep = 3;
        _showSuccess = true;
      });

      _pulseController.repeat(reverse: true);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'M-Pesa linked successfully! Synced $synced transactions.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _currentStep = 0);

      if (mounted) {
        // Check if it's a database table issue
        final isTableMissing = e.toString().contains('relation') &&
                              e.toString().contains('does not exist');

        if (isTableMissing) {
          // Show dialog with setup option
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Database Setup Required'),
              content: const Text(
                'The M-Pesa transactions table needs to be created in your Supabase database. '
                'Would you like to go to the setup screen to create it?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SetupDatabaseScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryStart,
                    foregroundColor: AppColors.whiteText,
                  ),
                  child: const Text('Setup Database'),
                ),
              ],
            ),
          );
        } else {
          // Show regular error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Failed to link M-Pesa: $e')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } finally {
      setState(() => _isLinking = false);
    }
  }

  Future<void> _unlinkAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unlink M-Pesa Account'),
        content: const Text(
          'Are you sure you want to unlink your M-Pesa account? This will stop automatic transaction imports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Unlink', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'mpesa_phone': null}),
        );
        
        _syncService.stopMonitoring();
        
        setState(() {
          _isLinked = false;
          _linkedPhone = null;
          _currentStep = 0;
          _showSuccess = false;
        });
        
        _phoneController.clear();
        _pulseController.stop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('M-Pesa account unlinked successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to unlink account: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _phoneController.dispose();
    _syncService.removeListener(_onSyncServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppTheme.buildGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildSecurityBanner(),
                          const SizedBox(height: 32),
                          _buildMainCard(),
                          const SizedBox(height: 24),
                          if (_isLinked) _buildStatsCard(),
                        ],
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Link M-Pesa Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (_isLinked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'LINKED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return AppTheme.buildGlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.security,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank-Level Security',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'We only read M-Pesa SMS messages. Your data is encrypted and never shared.',
                  style: TextStyle(
                    color: AppColors.greyText,
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

  Widget _buildMainCard() {
    return AppTheme.buildGlassmorphicCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLinking) _buildProgressIndicator(),
            if (!_isLinking && !_isLinked) _buildPhoneInput(),
            if (!_isLinking && _isLinked) _buildLinkedStatus(),
            const SizedBox(height: 24),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = [
      'Requesting permissions...',
      'Connecting to M-Pesa...',
      'Syncing transactions...',
      'Complete!'
    ];

    return Column(
      children: [
        Text(
          steps[_currentStep],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: (_currentStep + 1) / steps.length,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryStart),
        ),
        const SizedBox(height: 16),
        Text(
          'Step ${_currentStep + 1} of ${steps.length}',
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'M-Pesa Phone Number',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the phone number linked to your M-Pesa account',
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(
            hintText: '254712345678',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.phone_android,
                color: AppColors.primaryStart,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryStart, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your M-Pesa phone number';
            }
            if (!RegExp(r'^254[17]\d{8}$').hasMatch(value)) {
              return 'Please enter a valid Kenyan phone number (254XXXXXXXXX)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLinkedStatus() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _showSuccess ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Account Linked Successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _linkedPhone ?? '',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _syncService.isMonitoring ? Icons.sync : Icons.sync_disabled,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _syncService.isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    if (_isLinking) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Linking Account...'),
            ],
          ),
        ),
      );
    }

    if (_isLinked) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _unlinkAccount,
              icon: const Icon(Icons.link_off),
              label: const Text('Unlink Account'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _linkMpesaAccount,
        icon: const Icon(Icons.link),
        label: const Text('Link M-Pesa Account'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryStart,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return AppTheme.buildGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sync Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Transactions Processed',
                  '${_syncService.transactionsProcessed}',
                  Icons.receipt_long,
                  AppColors.primaryStart,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Status',
                  _syncService.isMonitoring ? 'Active' : 'Inactive',
                  _syncService.isMonitoring ? Icons.sync : Icons.sync_disabled,
                  _syncService.isMonitoring ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greyText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}