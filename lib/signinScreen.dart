import 'package:flutter/material.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/signupScreen.dart';
import 'package:medconnect_app/forgotPasswordScreen.dart';
import '../services/api_service.dart'; // استيراد ApiService

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

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    // 1. Validation
    if (!_formKey.currentState!.validate()) {
      setState(() {});
      return;
    }

    // 2. Loading
    setState(() => _isLoading = true);

    // 3. API Call
    final result = await _apiService.login(
      email: _identifierController.text.trim(),
      password: _passwordController.text,
      role: 'doctor',
    );

    // 4. Stop Loading
    if (!mounted) return;
    setState(() => _isLoading = false);

    // 5. Handle Result
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('sign in succesfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      _showErrorDialog(result['error']);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Ok')),
        ],
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 32),

              child: Form(
                key: _formKey,

                autovalidateMode: AutovalidateMode.disabled,

                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Avatar (كما هو)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 47,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white70,
                                ),
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
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // ---------------- EMAIL ----------------
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
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v)) {
                          return "Invalid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ---------------- PASSWORD ----------------
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
                            color: const Color(0xFF0066FF),
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
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 8) return 'At least 8 characters';
                        if (!RegExp(
                          r'^(?=.*[A-Za-z])(?=.*[\d@#$!%*?&]).+$',
                        ).hasMatch(v)) {
                          return 'Letters + numbers/symbols';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
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
