import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medconnect_app/services/Get_Doctor_Profile.dart';
import 'package:medconnect_app/doctorAccount.dart';
import 'package:medconnect_app/forgotPasswordScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medconnect_app/services/register_services.dart';

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

  // Address field that can be edited
  String fullname = '';
  String email = '';
  String phone = '';
  String licenseNumber = '';
  String address = '';
  String governorate = '';
  String issueAuthority = '';
  String profileImageUrl = '';
  bool isLoading = true;


Future<void> _pickAndUploadImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked == null) return;

  // show loading
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  final result = await RegisterService.updateProfileImage(
    picked,
  );

  if (!mounted) return;
  Navigator.pop(context); // close loading

  if (result['success'] == true) {
    setState(() {
      profileImageUrl = result['image_url'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(result['message'] ?? 'Profile image updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Update failed')),
    );
  }
}
Future<void> _deleteProfileImage() async {
  // confirm dialog الأول
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Profile Image'),
      content: const Text('Are you sure you want to delete your profile image?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  // show loading
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  final result = await RegisterService.deleteProfileImage();

  if (!mounted) return;
  Navigator.pop(context); // close loading

  if (result['success'] == true) {
    setState(() {
      profileImageUrl = result['image_url']; // بيرجع default image
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Image deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Delete failed'
      ),
      ),
    );
  }
}
  // 👇 حط الفنكشن هنا
  Future<void> getProfileData() async {
    final result = await GetDoctorProfile.doctorProfile();
      print('👤 Profile result: $result'); // ✅ أضف ده


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
        profileImageUrl = data["doctor"]['profile_image_url'] ?? '';

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
    

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                shadowColor: Colors.black.withOpacity(0.05),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  doctorAccountPage(),
                      ),
                    );
                  },
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
                // actions: [
                //   IconButton(
                //     icon: const Icon(Icons.settings),
                //     onPressed: () {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Settings coming soon'),
                //           behavior: SnackBarBehavior.floating,
                //           duration: Duration(seconds: 1),
                //         ),
                //       );
                //     },
                //     color: colorScheme.onSurface,
                //   ),
                // ],
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
         
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, ColorScheme colorScheme) {
  return Center(
    child: Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
              child: profileImageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(isDark, colorScheme);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(isDark, colorScheme),
            ),

            // 👇 زرار التعديل
           Positioned(
  bottom: 4,
  right: 4,
  child: GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Change Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage();
                },
              ),
             ListTile(
  leading: const Icon(Icons.delete, color: Colors.red),
  title: const Text('Delete Image', style: TextStyle(color: Colors.red)),
  onTap: () async {
    Navigator.pop(context); // ✅ أول حاجة اقفل الـ BottomSheet
    
    // بعدين اعرض الـ confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Profile Image'),
        content: const Text('Are you sure you want to delete your profile image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteProfileImage();
    }
  },
),
            ],
          ),
        ),
      );
    },
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(
        Icons.camera_alt,
        size: 16,
        color: Colors.white,
      ),
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

Widget _buildDefaultAvatar(bool isDark, ColorScheme colorScheme) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [Colors.grey[700]!, Colors.grey[800]!]
            : [const Color(0xFFDBEAFE), const Color(0xFFEFF6FF)],
      ),
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
  );
}

  Widget _buildPersonalInfoSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: Colors.blue,
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
        color: Colors.white,
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
                  color: Colors.blue,
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
        color: Colors.white,
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
                      color: Colors.blue,
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ForgotPasswordScreen(isChangePassword: true),
    ),
  );
},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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