import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medconnect_app/services/Get_Doctor_Profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedEquip - Doctor Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF005A9C),
          secondary: Color(0xFF4DBAC0),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF212529),
          onSurfaceVariant: Color(0xFF6C757D),
          outline: Color(0xFFE5E7EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF005A9C),
          secondary: Color(0xFF4DBAC0),
          surface: Color(0xFF1F2937),
          onSurface: Color(0xFFFFFFFF),
          onSurfaceVariant: Color(0xFF9CA3AF),
          outline: Color(0xFF374151),
        ),
        scaffoldBackgroundColor: const Color(0xFF101C22),
      ),
      themeMode: ThemeMode.system,
      home: const DoctorProfilePage(),
    );
  }
}

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
  
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  // Selected bottom navigation index
  int _selectedIndex = 3; // Profile is selected

  // Address field that can be edited
String fullname = '';
String email = '';
String phone = '';
String licenseNumber = '';
String address = '';
String governorate = '';
String issueAuthority = '';
bool isLoading = true;



  // 👇 حط الفنكشن هنا
  Future<void> getProfileData() async {
    final result = await GetDoctorProfile.doctorProfile();

    if (result['success']) {
      final data = result['data'];

      setState(() {
        fullname = data['fullname'] ?? '';
        email = data['email'] ?? '';
        phone = data["doctor"]['phone'] ?? '';
        licenseNumber = data["doctor"]["doctor_license"]['license_number'] ?? '';
        address = data['address'] ?? '';
        governorate = data['governorate'] ?? '';
        issueAuthority = data["doctor"]["doctor_license"]['issue_authority'] ?? '';

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
void initState() {
  super.initState();
  getProfileData(); // 👈 دي أهم سطر
}
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Sticky Header
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                shadowColor: Colors.black.withOpacity(0.05),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: colorScheme.onSurface,
                ),
                title: const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings coming soon'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    color: colorScheme.onSurface,
                  ),
                ],
              ),

              // Main Profile Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _buildProfileHeader(isDark, colorScheme),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(isDark, colorScheme),
                    const SizedBox(height: 20),
                    _buildProfessionalCredentialsSection(isDark, colorScheme),
                    const SizedBox(height: 20),
                    _buildAddressSection(isDark, colorScheme),
                    const SizedBox(height: 20),
                    _buildChangePasswordButton(isDark, colorScheme),
                    const SizedBox(height: 80), // Bottom padding for fixed navbar
                  ]),
                ),
              ),
            ],
          ),

          // Fixed Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    _buildNavItem(
                      icon: Icons.receipt_outlined,
                      activeIcon: Icons.receipt,
                      label: 'Orders',
                      index: 1,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    _buildNavItem(
                      icon: Icons.chat_bubble_outline,
                      activeIcon: Icons.chat_bubble,
                      label: 'Messages',
                      index: 2,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      index: 3,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Column(
        children: [
          // Profile Image with Edit Button
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.grey[700]!, Colors.grey[800]!]
                        : [const Color(0xFFDBEAFE), const Color(0xFFEFF6FF)],
                  ),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 64,
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : colorScheme.primary.withOpacity(0.4),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fullname,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
         
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildLockedInfoField(
              label: 'fullname',
              value: fullname,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildLockedInfoField(
              label: 'email',
              value: email,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildLockedInfoField(
              label: 'phone',
              value: phone,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCredentialsSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.badge,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Professional Credentials',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildLockedInfoField(
              label: 'licenseNumber',
              value: licenseNumber,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
           

            const SizedBox(height: 16),
            _buildLockedInfoField(
              label: 'issueAuthority',
              value: issueAuthority,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'address',
                      
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  onPressed: () => _showEditAddressDialog(isDark, colorScheme),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
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

  Widget _buildChangePasswordButton(bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Change password feature coming soon'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Password verification required',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedInfoField({
    required String label,
    required String value,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigating to $label'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(bool isDark, ColorScheme colorScheme) {
    final TextEditingController controller = TextEditingController(text: address);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Practice Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your practice address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                   onPressed: () async {
  final newAddress = controller.text;

  // loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

   final Map<String,dynamic> result = await GetDoctorProfile.updateAddress(newAddress);

  Navigator.pop(context); // close loading

  if (result['success'] == true) {
    setState(() {
      address = newAddress; // تحديث UI
    });

    Navigator.pop(context); // close dialog

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Address updated successfully")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? "Update failed")),
    );
  }
},
                     
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), 
    );
  }
}