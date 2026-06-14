import 'package:flutter/material.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/signUpScreen.dart';
import 'package:medconnect_app/forgotPasswordScreen.dart';
import '../services/api_service.dart';
 // استيراد ApiService

////////hagertestingacc@gmail.com
///P@ssword123


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  // String _selectedRole = 'doctor'; // doctor, supplier, admin
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
      _isLoading = true;
    });

    final result = await _apiService.login(
      email: _identifierController.text.trim(),
      password: _passwordController.text,
      role: 'doctor',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      final successMessage = result['message']?.toString() ?? 'Sign in successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      _setSignInErrors(result);
    }
  }

  void _setSignInErrors(Map<String, dynamic> result) {
    final errors = <String, dynamic>{};
    if (result['errors'] is Map) {
      errors.addAll(Map<String, dynamic>.from(result['errors']));
    }

    String? apiError = result['error']?.toString() ?? result['message']?.toString();
    if (apiError != null && apiError.isEmpty) apiError = null;

    String? emailError;
    String? passwordError;
    String? generalError;

    if (errors.containsKey('email')) {
      final emailErrors = errors['email'];
      if (emailErrors is List && emailErrors.isNotEmpty) {
        emailError = emailErrors.first.toString();
      } else {
        emailError = emailErrors?.toString();
      }
    }
    if (errors.containsKey('password')) {
      final passwordErrors = errors['password'];
      if (passwordErrors is List && passwordErrors.isNotEmpty) {
        passwordError = passwordErrors.first.toString();
      } else {
        passwordError = passwordErrors?.toString();
      }
    }

    if (emailError == null && passwordError == null) {
      if (errors.isNotEmpty) {
        final unknownErrors = errors.entries.where(
          (entry) => entry.key != 'email' && entry.key != 'password',
        );
        if (unknownErrors.isNotEmpty) {
          final firstError = unknownErrors.first.value;
          if (firstError is List && firstError.isNotEmpty) {
            generalError = firstError.first.toString();
          } else {
            generalError = firstError?.toString();
          }
        }
      }

      if (generalError == null && apiError != null) {
        final lower = apiError.toLowerCase();
        if (lower.contains('email') || lower.contains('البريد')) {
          emailError = apiError;
        } else if (lower.contains('password') || lower.contains('كلمة المرور')) {
          passwordError = apiError;
        } else {
          generalError = apiError;
        }
      }
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _generalError = generalError;
    });
  }

  // void _showErrorDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Ok')),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // AppBar (كما هو)
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
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const IntroScreen()));
                        }
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
              padding: const EdgeInsets.symmetric(horizontal: 32),

              child: Form(
                key: _formKey,

                autovalidateMode: AutovalidateMode.disabled,

                child: Column(
                  children: [
                    //const SizedBox(height: 20),

                    // Avatar (كما هو)
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Stack(
                    //       children: [
                    //         CircleAvatar(
                    //           radius: 50,
                    //           backgroundColor: Colors.white,
                    //           child: CircleAvatar(
                    //             radius: 47,
                    //             backgroundColor: Colors.grey[300],
                    //             child: const Icon(
                    //               Icons.person,
                    //               size: 60,
                    //               color: Colors.white70,
                    //             ),
                    //           ),
                    //         ),
                    //         Positioned(
                    //           bottom: 0,
                    //           right: 0,
                    //           child: CircleAvatar(
                    //             radius: 18,
                    //             backgroundColor: const Color(0xFF0066FF),
                    //             child: IconButton(
                    //               icon: const Icon(
                    //                 Icons.camera_alt,
                    //                 size: 18,
                    //                 color: Colors.white,
                    //               ),
                    //               onPressed: () {},
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(height: 50),

                    // ---------------- EMAIL ----------------
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _identifierController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 28,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          
                          errorText:_emailError,
                          errorStyle: const TextStyle(
                            fontSize: 12,
                            color:Colors.red,
                          ),
                        ),
                          onChanged: (_){
                            if(_emailError != null){
                              setState(() => _emailError=null);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------------- PASSWORD ----------------
                    Column(
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _passwordError != null ? Colors.red : const Color(0xFF0066FF),
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 28,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            errorText: _passwordError,
                            errorStyle: const TextStyle(
                              fontSize:  12,
                              color: Colors.red,
                            )
                          ),
                          onChanged: (_){
                            if(_passwordError != null){
                              setState(() => _passwordError=null);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {    // change by mohamed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Your Password?',
                          style: TextStyle(
                            color: Color(0xFF0066FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ---------------- SIGN IN BUTTON ----------------
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
                        onPressed: _isLoading ? null : _handleSignIn,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    if (_generalError != null && _generalError!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 16),
                        child: Text(
                          _generalError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don’t Have An Account? ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
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
}






















// import 'package:flutter/material.dart';
// //import 'package:medconnect_app/homeScreen.dart';
// import 'package:medconnect_app/mainScreen.dart';
// import 'package:medconnect_app/signupScreen.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final _identifierController = TextEditingController();
//   final _passwordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;

// //////////new editing for api
//   String _selectedRole = 'doctor';
//   bool _isloading =false;
//   //////////////////

//   @override
//   void dispose() {
//     _identifierController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Column(
//         children: [
//           Container(
//             height: 100,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF0066FF), Color(0xFF0088FF)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 26),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     const SizedBox(width: 8),
//                     Image.asset("assets/images/logoPNG.png",
//                         color: Colors.white, fit: BoxFit.contain, height: 25),
//                     const Spacer(),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 32),

//               child: Form(
//                 key: _formKey,

//                 // 🔥 أهم إضافة هنا 🔥
//                 autovalidateMode: AutovalidateMode.disabled,

//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 50,
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius: 47,
//                                 backgroundColor: Colors.grey[300],
//                                 child: const Icon(Icons.person, size: 60, color: Colors.white70),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: CircleAvatar(
//                                 radius: 18,
//                                 backgroundColor: const Color(0xFF0066FF),
//                                 child: IconButton(
//                                   icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
//                                   onPressed: () {},
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 50),
// /////////////-----------------------Role selection------------------------------/////////////////////////////
// Container(
//   padding: EdgeInsets.symmetric(horizontal: 12),
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(30),
//   ),
//   child: DropdownButtonFormField<String>(
//     value: _selectedRole,
//     decoration: InputDecoration(
//       border: InputBorder.none,
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     ),
//     items: [
//       DropdownMenuItem(value: 'doctor', child: Text('دكتور')),
//       DropdownMenuItem(value: 'supplier', child: Text('مورد')),
//       DropdownMenuItem(value: 'admin', child: Text('مشرف')),
//     ],
//     onChanged: (value) {
//       setState(() {
//         _selectedRole = value!;
//       });
//     },
//   ),
// ),
// SizedBox(height: 24),
// ////////////////////////////////////////////////////////////////






//                     // ---------------- EMAIL ----------------
//                     TextFormField(
//                       controller: _identifierController,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         hintText: 'Email',
//                         hintStyle: const TextStyle(color: Colors.grey),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 22, horizontal: 28),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return "Required";
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                             .hasMatch(v)) {
//                           return "Invalid email";
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),

//                     // ---------------- PASSWORD ----------------
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         hintText: 'Password',
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: const Color(0xFF0066FF),
//                           ),
//                           onPressed: () => setState(
//                               () => _obscurePassword = !_obscurePassword),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 22, horizontal: 28),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return 'Required';
//                         if (v.length < 8) return 'At least 8 characters';
//                         if (!RegExp(r'^(?=.*[A-Za-z])(?=.*[\d@#$!%*?&]).+$')
//                             .hasMatch(v)) {
//                           return 'Letters + numbers/symbols';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {},
//                         child: const Text(
//                           'Forgot Your Password?',
//                           style: TextStyle(
//                               color: Color(0xFF0066FF),
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // ---------------- SIGN IN BUTTON ----------------
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0066FF),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30)),
//                         ),
//                         onPressed: () {
//                           // 🔥 هنا بقى اللي هيظهر الرسائل الحمراء 🔥
//                           if (!_formKey.currentState!.validate()) {
//                             setState(() {}); // << يلزم لتحديث الشاشة وظهور errors
//                             return;
//                           }

//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => MainScreen()),
//                           );
//                         },
//                         child: const Text(
//                           'Sign In',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Don’t Have An Account? ',
//                             style: TextStyle(color: Colors.black54)),
//                         GestureDetector(
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const SignUpScreen())),
//                           child: const Text(
//                             'Sign Up',
//                             style: TextStyle(
//                                 color: Color(0xFF0066FF),
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
