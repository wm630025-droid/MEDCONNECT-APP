// ===================== Sign Up Screen  =====================
import 'package:flutter/material.dart';
import 'package:medconnect_app/signInScreen.dart';
import 'package:flutter/services.dart';
import 'package:medconnect_app/services/Register_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Map<String, String> fieldErrors = {};
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final selectedGovernorateController = TextEditingController();
  // أضف المتحكمات لباقي الحقول
  final fullnameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final specialtyController = TextEditingController();

  // متغير للصورة
  File? profileImage;
  final ImagePicker imagePicker = ImagePicker();

  // متغير للـ loading
  bool isLoading = false;

  void _showGovernorateSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: egyptGovernorates.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(egyptGovernorates[index]),
              onTap: () {
                setState(() {
                  selectedGovernorate = egyptGovernorates[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? selectedGovernorate;

  final List<String> egyptGovernorates = [
    'Cairo',
    'Giza',
    'Alexandria',
    'Dakahlia',
    'Red Sea',
    'Beheira',
    'Fayoum',
    'Gharbia',
    'Ismailia',
    'Menofia',
    'Minya',
    'Qaliubiya',
    'New Valley',
    'Suez',
    'Aswan',
    'Assiut',
    'Beni Suef',
    'Port Said',
    'Damietta',
    'Sharkia',
    'South Sinai',
    'Kafr El Sheikh',
    'Matrouh',
    'Luxor',
    'Qena',
    'North Sinai',
    'Sohag',
  ];
  // دالة اختيار الصورة
  Future<void> pickImage() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        // 🔥 مهم جداً
        profileImage = File(pickedFile.path);
      });

      print("Image Path: ${pickedFile.path}"); // للتأكد
    }
  }

  // دالة التسجيل
  Future<bool> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (selectedGovernorate == null) {
      Fluttertoast.showToast(msg: "Please select governorate");
      return false;
    }

    setState(() {
      isLoading = true;
    });

    final result = await ApiService.signUp(
      fullname: fullnameController.text.trim(),
      email: emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      address: addressController.text.trim(),
      governorate: selectedGovernorate!,
      nationalId: nationalIdController.text.trim(),
      phone: phoneController.text.trim(),
      licenseNumber: licenseNumberController.text.trim(),
      profileImage: profileImage,
      specialty: specialtyController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    // ✅ SUCCESS
    if (result['success'] == true) {
      fieldErrors.clear();

      // 🔥 هنا نحفظ البيانات
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['data']['token']);

      await prefs.setString('fullname', fullnameController.text);
      await prefs.setString('email', emailController.text);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString('license_number', licenseNumberController.text);
      await prefs.setString('address', addressController.text);
      await prefs.setString('governorate', selectedGovernorate!);
      await prefs.setString('nationalId', nationalIdController.text);
      await prefs.setString('specialty', specialtyController.text);

      Fluttertoast.showToast(
        msg:
            result['data']['message'] ??
            "Registered successfully..Please verify your email",
        backgroundColor: Colors.green,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInScreen()), // أو أي صفحة
      );

      return true; // 👈 مهم
    }
    // ❌ VALIDATION ERRORS (422)
    else if (result['errors'] != null && result['errors'].isNotEmpty) {
      setState(() {
        fieldErrors.clear();

        result['errors'].forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value[0]; // ناخد أول رسالة فقط
          } else if (value is String && value.isNotEmpty) {
            fieldErrors[key] = value; // لو رجع String مباشر
          }
        });
      });
      return false;
    }
    // 🚫 GENERAL ERROR (403 أو غيره)
    else {
      Fluttertoast.showToast(
        msg:
            result['message'] ??
            "Registration not permitted. Please check your license details",
        backgroundColor: Colors.red,
      );

      return false;
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    nationalIdController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    licenseNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    selectedGovernorateController.dispose();
    specialtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF0088FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // زرار الرجوع للـ Intro
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      "assets/images/logoPNG.png",
                      color: Colors.white,
                      fit: BoxFit.contain,
                      height: 25,
                    ),
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

                    // الصورة الشخصية في اليمين + أيقونة الكاميرا
                    // الصورة الشخصية في اليمين + أيقونة الكاميرا
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: profileImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        profileImage!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF0066FF),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed:
                                      pickImage, // غيرناها من (){} لـ _pickImage
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'full_name',
                      controller: fullnameController,
                      errorText: fieldErrors['full_name'],
                    ),

                    _buildTextField(
                      label: 'national_id',
                      keyboardType: TextInputType.number,
                      controller: nationalIdController,
                      errorText: fieldErrors['national_id'],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(14),
                      ],
                    ),

                    _buildTextField(
                      label: 'Address',
                      controller: addressController,
                      errorText: fieldErrors['address'],
                      suffixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'governorate',
                      controller: selectedGovernorateController,
                      errorText: fieldErrors['governorate'],
                      readOnly: true,
                      hintText: '$selectedGovernorate',
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      onTap: () => _showGovernorateSheet(),
                    ),

                    _buildTextField(
                      label: 'email',
                      controller: emailController,
                      errorText: fieldErrors['email'],

                      keyboardType: TextInputType.emailAddress,
                    ),

                    _buildTextField(
                      label: 'phone',
                      controller: phoneController,
                      errorText: fieldErrors['phone'],
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    _buildTextField(
                      label: 'specialty',
                      controller: specialtyController,
                      errorText: fieldErrors['specialty'],
                    ),

                    _buildTextField(
                      label: 'password',
                      controller: _passwordController,
                      errorText: fieldErrors['password'],
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),

                    _buildTextField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      errorText: fieldErrors['password_confirmation'],
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Professional License Requirements',

                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'license_number',
                      errorText: fieldErrors['license_number'],
                      controller: licenseNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9 -]'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await signUp(); // 👈 استنى النتيجة

                            if (success) {
                              // لا نحتاج للانتقال هنا، لأن signUp() يتعامل مع الانتقال
                            }
                          }
                        },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign Up',

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already Have An Account? ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF0066FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    Function()? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        // ✅ هنا التعديل
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
          errorText: errorText,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.grey.shade300,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : const Color(0xFF0066FF),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
