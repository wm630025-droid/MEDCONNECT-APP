// ===================== Sign Up Screen  =====================
import 'package:flutter/material.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/signInScreen.dart';
import 'package:flutter/services.dart';
import 'package:medconnect_app/services/postRegister.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
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
  final selectedGovernorateController = TextEditingController();
    // أضف المتحكمات لباقي الحقول
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseNumberController = TextEditingController();
  
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
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
    // دالة التسجيل
  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.signUp(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: _passwordController.text,
        address: addressController.text.trim(),
        governorate: selectedGovernorate!,
        nationalId: nationalIdController.text.trim(),
        phone: phoneController.text.trim(),
        licenseNumber: licenseNumberController.text.trim(),
        profileImage: profileImage,
      );

      if (result['success']) {
        Fluttertoast.showToast(
          msg: "Registration successful!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => HomeScreen())
        );
      } else {
        String errorMessage = result['message'] ?? 'Registration failed';
        
        if (result['errors'] != null && result['errors'].isNotEmpty) {
          errorMessage = result['errors'].values.first[0];
        }
        
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
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
    selectedGovernorateController.dispose();
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
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                     Image.asset("assets/images/logoPNG.png", color: Colors.white, fit: BoxFit.contain, height: 25),
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
          backgroundImage: profileImage != null 
              ? FileImage(profileImage!) 
              : null,
          child: profileImage == null
              ? const Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF0066FF),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              onPressed: pickImage, // غيرناها من (){} لـ _pickImage
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

                    _buildTextField(label: 'full_name', validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (RegExp(r'[0-9]').hasMatch(v)) return 'No numbers allowed';
                      return null;
                    }),

                    _buildTextField(
                      label: 'national_id',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)],
                      validator: (v) => v?.length != 14 ? 'Must be 14 digits' : null,
                    ),

                    _buildTextField(label: 'Address', suffixIcon: const Icon(Icons.location_on_outlined, color: Colors.blue)),

                    const SizedBox(height: 32),
                    const Text('Account Information', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField(
                   label: 'governorate',
                   readOnly: true,
                   hintText: '$selectedGovernorate',
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  validator: (v) => selectedGovernorate == null ? 'Required' : null,
                  onTap: () => _showGovernorateSheet(),
                  ),

                    _buildTextField(
                      label: 'email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!) ? 'Invalid email' : null,
                    ),

                    _buildTextField(
                      label: 'phone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                      validator: (v) => v?.length != 11 ? 'Must be 11 digits' : null,
                    ),

            _buildTextField(
             label: 'password',
             controller: _passwordController,
            obscureText: _obscurePassword,
             suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
             onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
             validator: (v) {
  if (v == null || v.isEmpty) return 'Required';
  if (v.length < 8) return 'At least 8 characters';
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*[\d@#$!%*?&]).+$').hasMatch(v)) {
    return 'Letters + numbers/symbols';
  }
  return null;
},
                    ),

                    _buildTextField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                    ),

                    const SizedBox(height: 32),
                    const Text('Professional License Requirements', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'license_number',
                      keyboardType: TextInputType.number,
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signUp();
                          }
                        },
child: isLoading
    ? const CircularProgressIndicator(color: Colors.white)
    : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),                      ),
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

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function()? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
        validator: validator,
      ),
    );
  }
}
