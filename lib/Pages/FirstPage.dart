import 'package:chatapp/Pages/SigninPage.dart';
import 'package:chatapp/Pages/Signup.dart';
import 'package:flutter/material.dart';
class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height;
    final width=MediaQuery.of(context).size.width;
    return Scaffold(
  backgroundColor: Colors.white,
        body:SingleChildScrollView(
          child: Column(
          children: [
            SizedBox(height: height*0.1,),
            Container(
              height: height*0.5,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(width*0.35))
              ),
              child: Center(
                child: Image.asset('assets/images/login.webp',height: height*0.6,width: width*0.75,),
              ),
            ),
            SizedBox(height: height*0.012,),
            Align(
              alignment: Alignment.center,child: Container(
                height: height*0.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(width*0.025)),

                ),child: Container(
                margin: EdgeInsets.symmetric(horizontal: width*0.062,vertical: height*0.012),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center
                ,
                  children: [
                    Align(
                      alignment: Alignment.center,child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.064),
                        child: Text("Login/Register to Get started!",textAlign: TextAlign.center, style: TextStyle(
                            fontFamily: 'Poppins',
          
                            fontSize: width * 0.059,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                      ),
                    ),SizedBox(height: height*0.012,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.06),
                      child: Text("Chat with people around you  easily.", style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: width * 0.029,
                          color: Colors.black)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.06),
                      child: Text("Sign in easily using Google/Facebook  ", style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: width * 0.029,
                          color: Colors.black)),
                    ),SizedBox(height: height*0.012,),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SigninPage()));
                      },
                      child: Container(
                        height: height * 0.06,
                        width: width,
                        decoration: BoxDecoration(
                            color:  Color(0xFF995BF8),
                            borderRadius: BorderRadius.circular(
                                width * 0.05)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sign in",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.05,
                                  color: Color(0xFF242935),
                                ),
                              ),        SizedBox(width: width*0.01,),
                              Icon(Icons.arrow_forward_ios,size: width*0.045,)
                            ],
                          ),
                        ),
                      ),
                    )
              ,SizedBox(height: height*0.012,),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignupPage()));
                      },
                      child: Container(
                        height: height * 0.06,
                        width: width,
                        decoration: BoxDecoration(

                            color: Colors.white,
border: Border.all(color:  Color(0xFFB485FA),width: 2),

                            borderRadius: BorderRadius.circular(

                                width * 0.05)),

                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Register",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.05,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: width*0.01,),
                              Icon(Icons.arrow_forward_ios,size: width*0.045,)
                            ],
                          ),
                        ),
                      ),
                    )

                  ],
                            ),
                ),
              ),
            )
          
          ],
                ),
        )
    );
  }
}
