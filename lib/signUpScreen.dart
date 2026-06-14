import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medconnect_app/signinScreen.dart';
import 'package:medconnect_app/services/register_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:medconnect_app/services/image_store.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers للحقول
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseNumberController = TextEditingController();

  // متغيرات الصورة الشخصية
  Uint8List? profileImageBytes;
  String? profileImageUrl;
  final ImageStore _imageStore = ImageStore();
  final ImagePicker imagePicker = ImagePicker();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          profileImageBytes = imageBytes;
          profileImageUrl = null;
          // persist selected image in the in-memory store so it survives navigation
          _imageStore.profileImageBytes = imageBytes;
        });
        // clear any previously saved API url (user chose a local image)
        await _imageStore.saveUrl(null);
        print('🖼️ [signUpScreen] selected image path: ${pickedFile.path}');
        print('🖼️ [signUpScreen] selected image bytes: ${imageBytes.lengthInBytes} bytes');
      } else {
        print('🖼️ [signUpScreen] image selection canceled');
      }
    } catch (e) {
      print('❌ [signUpScreen] Error picking image: $e');
    }
  }
  // خريطة لتخزين أخطاء API لكل حقل (المفتاح هو اسم الحقل كما يرجعه الـ API)
  Map<String, String?> apiFieldErrors = {};

  @override
  void dispose() {
    fullNameController.dispose();
    nationalIdController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    licenseNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // restore any previously selected image URL from persistent store
    _imageStore.load().then((_) {
      setState(() {
        profileImageBytes = _imageStore.profileImageBytes;
        profileImageUrl = _imageStore.profileImageUrl;
      });
    });
  }

  // دالة اختيار الصورة
 

  // دالة التسجيل المعدلة
  Future<void> register() async {
    setState(() {
      apiFieldErrors.clear();
      isLoading = true;
    });

    try {
      print('🔔 [signUpScreen] registering user with email=${emailController.text.trim()}, fullName=${fullNameController.text.trim()}');
      print('🔔 [signUpScreen] current profileImageUrl=$profileImageUrl');
      print('🔔 [signUpScreen] current profileImageBytes present=${profileImageBytes != null}');

      final result = await apiService.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: _passwordController.text,
        address: addressController.text.trim(),
        nationalId: nationalIdController.text.trim(),
        phone: phoneController.text.trim(),
        licenseNumber: licenseNumberController.text.trim(),
      );

      print('🔔 [signUpScreen] register result: $result');

      if (result['success']) {
        setState(() {
          profileImageUrl = result['profileImageUrl'] as String?;
          // clear in-memory bytes after successful registration
          profileImageBytes = null;
          _imageStore.profileImageBytes = null;
        });
        // persist the API-provided image url to storage
        await _imageStore.saveUrl(profileImageUrl);
        print('✅ [signUpScreen] registration success');
        print('✅ [signUpScreen] profileImageUrl from API: $profileImageUrl');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Registration successful! Please verify your email."),
            backgroundColor: Colors.green,
          ),
        );
       
      } else if (result['statusCode'] == 422) {
        print('⚠️ [signUpScreen] validation errors: ${result['errors']}');
        setState(() {
          apiFieldErrors = _convertErrorsToMap(result['errors']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fix the errors below"), backgroundColor: Colors.red),
        );
      } else if (result['statusCode'] == 403) {
        print('⛔ [signUpScreen] registration forbidden: ${result['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Registration not permitted'), backgroundColor: Colors.red),
        );
      } else {
        print('❌ [signUpScreen] registration failed: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('❌ [signUpScreen] exception during register: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Map<String, String?> _convertErrorsToMap(Map<String, dynamic>? errors) {
    if (errors == null) return {};
    Map<String, String?> mapped = {};
    errors.forEach((key, value) {
      String fieldKey = _mapApiFieldToUiField(key);
      if (value is List && value.isNotEmpty) {
        mapped[fieldKey] = value.first.toString();
      } else if (value is String) {
        mapped[fieldKey] = value;
      }
    });
    return mapped;
  }

  void _showImagePreview() {
    if (profileImageBytes == null && (profileImageUrl == null || profileImageUrl!.isEmpty)) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                profileImageBytes != null
                    ? Image.memory(profileImageBytes!, fit: BoxFit.contain)
                    : Image.network(profileImageUrl!, fit: BoxFit.contain),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة لربط أسماء الحقول من API بأسماء الحقول المحلية
  String _mapApiFieldToUiField(String apiField) {
    switch (apiField) {
      case 'full_name':
        return 'fullName';
      case 'email':
        return 'email';
      case 'password':
        return 'password';
      case 'address':
        return 'address';
     
      case 'national_id':
        return 'nationalId';
      case 'phone':
        return 'phone';
      case 'license_number':
        return 'licenseNumber';
      default:
        return apiField;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0088FF)]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Image.asset("assets/images/logoPNG.png", color: Colors.white, height: 25),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ===== حقل الصورة الشخصية (تمت إعادته) =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: profileImageBytes != null || profileImageUrl != null ? _showImagePreview : null,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: profileImageBytes != null
                                    ? MemoryImage(profileImageBytes!)
                                    : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                                        ? NetworkImage(profileImageUrl!)
                                        : null),
                                child: profileImageBytes == null && (profileImageUrl == null || profileImageUrl!.isEmpty)
                                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF0066FF),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                  onPressed: pickImage,
                                ),
                              ),
                            ),
                            if (profileImageBytes != null || (profileImageUrl != null && profileImageUrl!.isNotEmpty))
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.redAccent,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                    onPressed: () async {
                                      setState(() {
                                        profileImageBytes = null;
                                        profileImageUrl = null;
                                        _imageStore.profileImageBytes = null;
                                      });
                                      await _imageStore.saveUrl(null);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    const Text('User Information', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // الحقول مع عرض خطأ API تحتها إن وجد
                    _buildTextFieldWithApiError(
                      controller: fullNameController,
                      label: 'Full Name',
                      fieldKey: 'fullName',
                     
  // السماح بالأحرف العربية والإنجليزية والمسافات فقط (بدون أرقام)
  
                    ),
                    _buildTextFieldWithApiError(
                      controller: nationalIdController,
                      label: 'National ID',
                      fieldKey: 'nationalId',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)],
                    ),
                    _buildTextFieldWithApiError(
                      controller: addressController,
                      label: 'Address',
                      fieldKey: 'address',
                      suffixIcon: const Icon(Icons.location_on_outlined, color: Colors.blue),
                    ),
                   

                    const SizedBox(height: 32),
                    const Text('Account Information', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildTextFieldWithApiError(
                      controller: emailController,
                      label: 'Email',
                      fieldKey: 'email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextFieldWithApiError(
                      controller: phoneController,
                      label: 'Phone',
                      fieldKey: 'phone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                    ),
                    _buildTextFieldWithApiError(
                      controller: _passwordController,
                      label: 'Password',
                      fieldKey: 'password',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                     
                       
                    ),
                    _buildTextFieldWithApiError(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      fieldKey: 'confirmPassword', // هذا الحقل ليس في API لكن نستخدمه للعرض
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
      ),

                    const SizedBox(height: 32),
                    const Text('Professional License', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildTextFieldWithApiError(
                      controller: licenseNumberController,
                      label: 'License Number',
                      fieldKey: 'licenseNumber',
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 -]'))],
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                         onPressed: isLoading ? null : () => register(),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already Have An Account? ', style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                          child: const Text('Sign In', style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء TextFormField مع إمكانية عرض خطأ API أسفله
  Widget _buildTextFieldWithApiError({
  required TextEditingController controller,
  required String label,
  required String fieldKey,
  TextInputType? keyboardType,
  bool obscureText = false,
  Widget? suffixIcon,
  String? hintText,
  List<TextInputFormatter>? inputFormatters,
}) {
  String? apiError = apiFieldErrors[fieldKey];
  bool hasError = apiError != null && apiError.isNotEmpty;
  
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: hasError ? const Color(0xFFFFEBEE) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF0066FF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorText: apiError, // ✅ هذا هو المكان الصحيح لعرض الخطأ
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
}

