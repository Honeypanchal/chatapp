import 'package:chatapp/models/CustomClass.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth_services.dart';
import 'MainNavigation.dart';
import 'Profile.dart';
import 'SigninPage.dart';
import 'FirstPage.dart';

//
//
// class SignupPage extends StatefulWidget {
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool check = true;
//   bool showPass = false;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _firstnameController = TextEditingController();
//   final TextEditingController _lastnameController = TextEditingController();
//   int date = 1;
//   List<String> months = ['Jan', 'Feb', 'March', 'April', 'May'];
//   List<int> years = [2000, 2001, 2002, 2003, 2004, 2005];
//   int year = 2000;
//   String month = 'Jan';
//   String groupValue = 'Woman';
//
//   void _signup() async {
//     if (_formKey.currentState!.validate()) {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();
//       final firstName = _firstnameController.text.trim();
//       final lastName = _lastnameController.text.trim();
//       try {
//         CustomClass? user = await signUpUser(firstName, lastName,
//             groupValue, email, password);
//         if (user != null) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//                 builder: (context) => MainNavigationPage(currentUser: user)),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//             e.toString(),
//           ),
//           backgroundColor: Colors.red.shade200,
//         ));
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF242935),
//         leading: Padding(
//           padding: EdgeInsets.only(left: width * 0.064),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.of(context)
//                   .push(MaterialPageRoute(builder: (context) => Firstpage()));
//             },
//             child: Container(
//               height: height * 0.045,
//               width: width * 0.035,
//               decoration:
//                   BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//               child: Center(
//                 child: Padding(
//                   padding: EdgeInsets.only(left: width * 0.019),
//                   child: Icon(
//                     Icons.arrow_back_ios,
//                     size: width * 0.044,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       backgroundColor: Color(0xFF242935),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: width * 0.1,
//               vertical: height * 0.03,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Let's  Start",
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: width * 0.069,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//                 Text(
//                   "Create an Account",
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: width * 0.029,
//                       color: Colors.white),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     width: width,
//                     decoration: BoxDecoration(),
//                     child: Container(
//                       margin: EdgeInsets.only(top: height * 0.032),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Sign Up",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontFamily: 'Poppins',
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: width * 0.059),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: height * 0.032),
//                             child: Form(
//                               key: _formKey,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Full Name",
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                         fontFamily: 'Raleway'),
//                                   ),
//                                   SizedBox(
//                                     width: width * 0.015,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color: Color(0xFF2C313F),
//                                             borderRadius: BorderRadius.circular(
//                                                 width * 0.025),
//                                           ),
//                                           child:
//                                           TextFormField(
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontFamily: 'Raleway'),
//                                             controller: _firstnameController,
//                                             validator: (val) {
//                                               if (val == null || val.isEmpty) {
//                                                 return 'Enter First Name';
//                                               }
//                                               return null;
//                                             },
//                                             decoration: InputDecoration(
//                                               labelText: 'Name',
//                                               labelStyle: TextStyle(
//                                                   color: Colors.white,
//                                                   fontFamily: 'Raleway'),
//                                               border: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: Colors.grey.shade400,
//                                                 ),
//                                               ),
//                                               // errorBorder: OutlineInputBorder(
//                                               //     borderSide: BorderSide(
//                                               //         color: Colors.red)),
//                                               suffixIcon: _firstnameController
//                                                       .text.isEmpty
//                                                   ? Icon(
//                                                       Icons.error,
//                                                       color: Color(0xFF995BF8),
//                                                     )
//                                                   : null,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: width * 0.025,
//                                       ),
//                                       Expanded(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color: Color(0xFF2C313F),
//                                             borderRadius: BorderRadius.circular(
//                                                 width * 0.032),
//                                           ),
//                                           child: TextFormField(
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontFamily: 'Raleway'),
//                                             controller: _lastnameController,
//                                             validator: (val) {
//                                               if (val == null || val.isEmpty) {
//                                                 return 'Enter First Name';
//                                               }
//                                               return null;
//                                             },
//                                             decoration: InputDecoration(
//                                               labelText: 'Surname',
//                                               labelStyle: TextStyle(
//                                                   color: Colors.white,
//                                                   fontFamily: 'Raleway'),
//                                               border: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                   color: Colors.grey.shade400,
//                                                 ),
//                                               ),
//                                               suffixIcon: _firstnameController
//                                                       .text.isEmpty
//                                                   ? Icon(
//                                                       Icons.error,
//                                                       color: Color(0xFF995BF8),
//                                                     )
//                                                   : null,
//                                               // errorBorder: OutlineInputBorder(
//                                               //     borderSide: BorderSide(
//                                               //         color: Colors.red)),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: height * 0.014,
//                                   ),
//                                   // Row(
//                                   //   children: [
//                                   //     Text(
//                                   //       "Birthday",
//                                   //       style:
//                                   //           TextStyle(fontSize: width * 0.035),
//                                   //     ),
//                                   //     SizedBox(
//                                   //       width: width * 0.015,
//                                   //     ),
//                                   //     Container(
//                                   //       height: height * 0.016,
//                                   //       width: width * 0.072,
//                                   //       decoration: BoxDecoration(
//                                   //           shape: BoxShape.circle,
//                                   //           color: Colors.grey.shade400),
//                                   //       child: Center(
//                                   //           child: Icon(
//                                   //         Icons.question_mark_outlined,
//                                   //         size: width * 0.032,
//                                   //         color: Colors.white,
//                                   //       )),
//                                   //     )
//                                   //   ],
//                                   // ),
//                                   // SizedBox(
//                                   //   height: height * 0.005,
//                                   // ),
//                                   // Row(
//                                   //   children: [
//                                   //     Expanded(
//                                   //         child: DropdownButtonFormField(
//                                   //       dropdownColor: Colors.grey.shade100,
//                                   //       decoration: InputDecoration(
//                                   //         border: OutlineInputBorder(
//                                   //           borderSide: BorderSide(
//                                   //             color: Colors.grey.shade400,
//                                   //             width: 1.5,
//                                   //           ),
//                                   //         ),
//                                   //         enabledBorder: OutlineInputBorder(
//                                   //           borderSide: BorderSide(
//                                   //             color: Colors.grey.shade400,
//                                   //             width: 1.5,
//                                   //           ),
//                                   //         ),
//                                   //       ),
//                                   //       icon: Icon(Icons.expand_more),
//                                   //       value: date,
//                                   //       items: List.generate(31, (index) {
//                                   //         return DropdownMenuItem(
//                                   //             value: (index + 1),
//                                   //             child:
//                                   //                 Text((index + 1).toString()));
//                                   //       }),
//                                   //       onChanged: (val) {
//                                   //         setState(() {
//                                   //           date = val!;
//                                   //         });
//                                   //       },
//                                   //     )),
//                                   //     SizedBox(
//                                   //       width: width * 0.035,
//                                   //     ),
//                                   //     Expanded(
//                                   //         child: DropdownButtonFormField(
//                                   //       decoration: InputDecoration(
//                                   //         border: OutlineInputBorder(
//                                   //           borderSide: BorderSide(
//                                   //             color: Colors.grey.shade400,
//                                   //             width: 1.5,
//                                   //           ),
//                                   //         ),
//                                   //         enabledBorder: OutlineInputBorder(
//                                   //           borderSide: BorderSide(
//                                   //             color: Colors.grey.shade400,
//                                   //             width: 1.5,
//                                   //           ),
//                                   //         ),
//                                   //       ),
//                                   //       borderRadius:
//                                   //           BorderRadius.circular(width * 0.01),
//                                   //       icon: Icon(Icons.expand_more),
//                                   //       value: month,
//                                   //       items: months.map((x) {
//                                   //         return DropdownMenuItem(
//                                   //           child: Text(x),
//                                   //           value: x,
//                                   //         );
//                                   //       }).toList(),
//                                   //       onChanged: (val) {
//                                   //         setState(() {
//                                   //           month = val!;
//                                   //         });
//                                   //       },
//                                   //       dropdownColor: Colors.grey.shade100,
//                                   //     )),
//                                   //     SizedBox(
//                                   //       width: width * 0.035,
//                                   //     ),
//                                   //     Expanded(
//                                   //         child: DropdownButtonFormField(
//                                   //       decoration: InputDecoration(
//                                   //         border: OutlineInputBorder(
//                                   //           borderSide: BorderSide(
//                                   //             color: Colors.grey.shade400,
//                                   //             width: 1.5,
//                                   //           ),
//                                   //         ),
//                                   //         enabledBorder: OutlineInputBorder(
//                                   //           borderSide: BorderSide(
//                                   //             color: Colors.grey.shade400,
//                                   //             width: 1.5,
//                                   //           ),
//                                   //         ),
//                                   //       ),
//                                   //       dropdownColor: Colors.grey.shade100,
//                                   //       icon: Icon(Icons.expand_more),
//                                   //       value: year,
//                                   //       items: years.map((x) {
//                                   //         return DropdownMenuItem(
//                                   //           child: Text(x.toString()),
//                                   //           value: x,
//                                   //         );
//                                   //       }).toList(),
//                                   //       onChanged: (val) {
//                                   //         setState(() {
//                                   //           year = val!;
//                                   //         });
//                                   //       },
//                                   //     ))
//                                   //   ],
//                                   // ),
//                                   SizedBox(
//                                     height: height * 0.012,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         "Gender",
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: width * 0.035,
//                                             fontFamily: 'Raleway'),
//                                       ),
//                                       SizedBox(
//                                         width: width * 0.015,
//                                       ),
//                                       Container(
//                                         height: height * 0.016,
//                                         width: width * 0.072,
//                                         decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.grey.shade400),
//                                         child: Center(
//                                             child: Icon(
//                                           Icons.question_mark_outlined,
//                                           size: width * 0.032,
//                                           color: Colors.white,
//                                         )),
//                                       )
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: height * 0.009,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Container(
//                                         width: width * 0.29,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xFF2C313F),
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.012),
//                                           border: Border.all(
//                                             color: Colors.grey.shade400,
//                                             width: 0.3,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Padding(
//                                               padding: EdgeInsets.only(
//                                                   left: width * 0.03),
//                                               child: Text(
//                                                 "Woman",
//                                                 style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: width * 0.035,
//                                                     fontFamily: 'Raleway'),
//                                               ),
//                                             ),
//                                             Transform.scale(
//                                               scale: 0.8,
//                                               child: Radio(
//                                                   value: 'Woman',
//                                                   groupValue: groupValue,
//                                                   onChanged: (val) {
//                                                     setState(() {
//                                                       groupValue = 'Woman';
//                                                     });
//                                                   }),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: width * 0.012,
//                                       ),
//                                       Container(
//                                         width: width * 0.25,
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: Colors.grey.shade400,
//                                             width: 0.4,
//                                           ),
//                                           color: Color(0xFF2C313F),
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.012),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Padding(
//                                               padding: EdgeInsets.only(
//                                                   left: width * 0.037),
//                                               child: Text("Male",
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontFamily: 'Raleway')),
//                                             ),
//                                             Transform.scale(
//                                               scale: 0.8,
//                                               child: Radio(
//                                                   value: 'Male',
//                                                   groupValue: groupValue,
//                                                   onChanged: (val) {
//                                                     setState(() {
//                                                       groupValue = 'Male';
//                                                     });
//                                                   }),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: width * 0.012,
//                                       ),
//                                       Expanded(
//                                         child: Container(
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                 color: Colors.grey.shade400,
//                                                 width: 0.4,
//                                               ),
//                                               color: Color(0xFF2C313F),
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       width * 0.012),
//                                             ),
//                                             child: Row(
//
//                                               children: [
//                                                 Padding(
//                                                   padding: EdgeInsets.only(
//                                                       left: width * 0.012),
//                                                   child: Text("Other",
//                                                       style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontFamily: 'Raleway')),
//                                                 ),
//                                                 Transform.scale(
//                                                   scale: 0.8,
//                                                   child: Radio(
//                                                       value: 'Other',
//                                                       groupValue: groupValue,
//                                                       onChanged: (val) {
//                                                         setState(() {
//                                                           groupValue = 'Other';
//                                                         });
//                                                       }),
//                                                 ),
//                                               ],
//                                             )),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: height * 0.015),
//                                   Text(
//                                     "Email",
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                         fontFamily: 'Raleway'),
//                                   ),
//                                   SizedBox(
//                                     height: height * 0.007,
//                                   ),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFF2C313F),
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.032),
//                                     ),
//                                     child:
//                                     TextFormField(
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontFamily: 'Raleway'),
//                                       controller: _emailController,
//                                       validator: (val) {
//                                         if (val == null ||
//                                             !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
//                                                 .hasMatch(val)) {
//                                           return 'Enter a valid email';
//                                         }
//                                         return null;
//                                       },
//                                       decoration: InputDecoration(
//                                         labelText: 'Email',
//                                         labelStyle: TextStyle(
//                                             color: Colors.white,
//                                             fontFamily: 'Raleway'),
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Colors.grey.shade400,
//                                             width: 1.5,
//                                           ),
//                                         ),
//
//                                         // errorBorder: OutlineInputBorder(
//                                         //     borderSide:
//                                         //     BorderSide(color: Colors.red)),
//                                         suffixIcon: _emailController
//                                                     .text.isEmpty ||
//                                                 ((_emailController
//                                                         .text.isNotEmpty) &&
//                                                     !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
//                                                         .hasMatch(
//                                                             _emailController
//                                                                 .text))
//                                             ? Icon(
//                                                 Icons.error,
//                                                 color: Color(0xFF995BF8),
//                                               )
//                                             : null,
//                                       ),
//                                       keyboardType: TextInputType.emailAddress,
//                                     ),),
//                                   SizedBox(height: height * 0.015),
//                                   Text(
//                                     "Password",
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                         fontFamily: 'Raleway'),
//                                   ),
//                                   SizedBox(
//                                     height: height * 0.007,
//                                   ),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFF2C313F),
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.032),
//                                     ),
//                                     child:
//                                     TextFormField(
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontFamily: 'Raleway'),
//                                       controller: _passwordController,
//                                       validator: (val) {
//                                         if (val!.isEmpty) {
//                                           return 'Enter a password';
//                                         }
//                                         return null;
//                                       },
//                                       decoration: InputDecoration(
//                                           labelText: 'New Password',
//                                           labelStyle: TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: 'Raleway'),
//                                           border: OutlineInputBorder(
//                                             borderSide: BorderSide(
//                                               color: Colors.grey.shade400,
//                                               width: 1.5,
//                                             ),
//                                           ),
//
//                                           // errorBorder: OutlineInputBorder(
//                                           //     borderSide: BorderSide(
//                                           //         color: Colors.red)),
//                                           suffixIcon: showPass
//                                               ? IconButton(
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       showPass = !showPass;
//                                                     });
//                                                   },
//                                                   icon: Icon(
//                                                       color: Colors.white,
//                                                       Icons
//                                                           .visibility_outlined))
//                                               : IconButton(
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       showPass = !showPass;
//                                                     });
//                                                   },
//                                                   icon: Icon(
//                                                       color: Colors.white,
//                                                       Icons
//                                                           .visibility_off_outlined))),
//                                       obscureText: !showPass,
//                                     ),
//                                   ),
//                                   SizedBox(height: height * 0.020),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Checkbox(
//                                           value: check,
//                                           onChanged: (val) {
//                                             setState(() {
//                                               check = !check;
//                                             });
//                                           }),
//                                       Container(
//                                         width: width * 0.66,
//                                         child: Text(
//                                           "I agree to the Terms & conditions and Privacy Policy ",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: 'Raleway',
//                                               fontSize: width * 0.032),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                   SizedBox(height: height * 0.034),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                           child: GestureDetector(
//                                         onTap: () {
//                                           _signup();
//                                         },
//                                         child: Container(
//                                           height: height * 0.062,
//                                           width: width,
//                                           decoration: BoxDecoration(
//                                               color: Color(0xFF995BF8),
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       width * 0.05)),
//                                           child: Center(
//                                             child: Text('Create an Account',
//                                                 style: TextStyle(
//                                                     fontFamily: 'Poppins',
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: width * 0.045)),
//                                           ),
//                                         ),
//                                       )),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: height * 0.034,
//                                   ),
//                                   Container(
//                                     height: height * 0.062,
//                                     width: width,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Colors.grey.shade200),
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(
//                                             width * 0.05)),
//                                     child: ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.white),
//                                         onPressed: () async {
//                                           CustomClass? user =
//                                               await signInWithGoogle();
//
//                                           if (user != null) {
//                                             Navigator.of(context).pushReplacement(
//                                               MaterialPageRoute(
//                                                   builder: (context) => MainNavigationPage(currentUser: user)),
//                                             );
//                                           } else {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(SnackBar(
//                                                     content: Text(
//                                                         "No user recieved")));
//                                           }
//                                         },
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             Image.asset(
//                                               'assets/images/Google.jpg',
//                                               height: height * 0.054,
//                                               width: width * 0.054,
//                                             ),
//                                             Text(
//                                               "Sign up with google  ",
//                                               style: TextStyle(
//                                                   fontFamily: 'Poppins',
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                   fontSize: width * 0.045),
//                                             )
//                                           ],
//                                         )),
//                                   ),
//                                   Align(
//                                     alignment: Alignment.center,
//                                     child: TextButton(
//                                       onPressed: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   SigninPage()),
//                                         );
//                                       },
//                                       child: Text.rich(TextSpan(
//                                           text: 'Already have an account?',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: 'Raleway',
//                                               fontSize: width * 0.032),
//                                           children: <InlineSpan>[
//                                             TextSpan(
//                                                 text: 'Sign in ',
//                                                 style: TextStyle(
//                                                     color: Color(0xFF995BF8),
//                                                     fontFamily: 'Raleway',
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: width * 0.032))
//                                           ])),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool check = true;
  bool showPass = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  int date = 1;
  List<String> months = ['Jan', 'Feb', 'March', 'April', 'May'];
  List<int> years = [2000, 2001, 2002, 2003, 2004, 2005];
  int year = 2000;
  String month = 'Jan';

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final firstName = _firstnameController.text.trim();
      final lastName = _lastnameController.text.trim();
      final confirmpassword = _confirmpasswordController.text.trim();
      print("$email");
      try {
        CustomClass? user = await signUpUser(firstName, email, password);
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => MainNavigationPage(currentUser: user)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w400),
          ),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60),
          child: Column(
            children: [
              /*Container(
                  height: height * 0.5,
                  width: width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0XFF5098FA),
                        Color(0XFF526CF7),
                        Color(0XFF533BF1),
                        Color(0XFF5327EE),
                        Color(0XFF5317EB),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.065),
                          ClipOval(
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(50),
                              child: Image.asset(
                                'assets/images/Icon_homepage.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),*/
              /*Image.asset(
                'assets/images/main3.png',
                height: 200,
                fit: BoxFit.cover,
              ),*/
              Text(
                'Sign Up For Free.',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'poppins',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                child: const Text(
                  "join us for less than 1 minutes, with no cost.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Name',
                        style: TextStyle(
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.010,
                    ),
                    /*Text(
                      'NAME',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * 0.03,
                          color: Colors.blue[600],
                          fontFamily: 'poppins'),
                    ),*/
                    TextFormField(
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _firstnameController,
                      decoration: InputDecoration(
                          hintText: 'your name',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.person_2_outlined),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter Name';
                        }
                        return null;
                      },

                      /*decoration: InputDecoration(

                          // errorBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: Colors.red)),

                          ),*/
                    ),
                    SizedBox(
                      height: height * 0.030,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email Address',
                        style: TextStyle(
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.010,
                    ),
                    TextFormField(
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _emailController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(val.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        // label: Text('Email'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: height * 0.030),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: height * 0.010),
                    TextFormField(
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _passwordController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter a password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.white38,
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(),
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                          // helperText: "Password must contain special character",
                          helperStyle: TextStyle(color: Colors.green),

                          // errorBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: Colors.red)),
                          suffixIcon: showPass
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPass = !showPass;
                                    });
                                  },
                                  icon: Icon(
                                      color: Colors.black,
                                      Icons.visibility_outlined))
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPass = !showPass;
                                    });
                                  },
                                  icon: Icon(
                                      color: Colors.grey,
                                      Icons.visibility_off_outlined))),
                      obscureText: !showPass,
                    ),
                    SizedBox(height: height * 0.030),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Re-Type Password',
                        style: TextStyle(
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'poppins'),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    /*Text(
                      'RE-TYPE PASSWORD',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * 0.03,
                          color: Colors.blue[600],
                          fontFamily: 'poppins'),
                    ),*/
                    SizedBox(height: height * 0.010),
                    TextFormField(
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Raleway'),
                      controller: _confirmpasswordController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter a password';
                        } else if (val != _passwordController.text)
                          return 'no match';
                        return null;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.white38,
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(),
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                          // helperText: "Password must contain special character",
                          helperStyle: TextStyle(color: Colors.green),

                          // errorBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: Colors.red)),
                          suffixIcon: showPass
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPass = !showPass;
                                    });
                                  },
                                  icon: Icon(
                                      color: Colors.black,
                                      Icons.visibility_outlined))
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPass = !showPass;
                                    });
                                  },
                                  icon: Icon(
                                      color: Colors.grey,
                                      Icons.visibility_off_outlined))),
                      obscureText: !showPass,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: height * 0.07,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    _signup();
                  },
                  style: ElevatedButton.styleFrom(
                      // Color(0XFF185FED)
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: width * 0.045, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.015,
              ),
              SizedBox(
                height: height * 0.060,
                width: width * 0.9,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.black,
                          width: 2
                        ))),
                    onPressed: () async {
                      CustomClass? user = await signInWithGoogle();

                      if (user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>
                                  MainNavigationPage(currentUser: user)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No user recieved")));
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/images/Google.jpg',
                          height: height * 0.054,
                          width: width * 0.054,
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        Text(
                          "Sign up with google  ",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: width * 0.040),
                        ),
                      ],
                    )),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SigninPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.040,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 80,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
