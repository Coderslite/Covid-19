import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_19/pages/certificate.dart';
import 'package:covid_19/pages/register.dart';
import 'package:covid_19/pages/second_dose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:covid_19/pages/login.dart';

class CheckIdentity extends StatefulWidget {
  const CheckIdentity({Key? key}) : super(key: key);

  @override
  State<CheckIdentity> createState() => _CheckIdentityState();
}

class _CheckIdentityState extends State<CheckIdentity> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isValidating = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check User Vacination State"),
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) {
                return const LoginScreen();
              }));
            },
            icon: const Icon(Icons.logout_rounded)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormBuilder(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormBuilderTextField(
                    name: 'email',
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                      FormBuilderValidators.email(context),
                    ]),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.perm_identity_outlined),
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      hintText: "Enter Email Address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  isValidating
                      ? const CircularProgressIndicator()
                      : Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.redAccent,
                          child: MaterialButton(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {
                              handleValidate();
                            },
                            child: const Text(
                              "Validate",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void handleValidate() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      final formData = _formKey.currentState!.value;
      setState(() {
        isValidating = true;
      });
      var getDetails = FirebaseFirestore.instance
          .collection("users").doc(formData['email']);

      getDetails.get().then((value) {
        setState(() {
          isValidating = false;
        });
        if (value['status'] == 'firstDoseDone') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 10),
            content: const Text("First Dose Done !!!"),
            action: SnackBarAction(
                label: "Next Dose",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return SecondDose(
                      email: value['email'],
                    );
                  }));
                }),
          ));
        } else if (value['status'] == 'secondDoseDone') {
          setState(() {
            isValidating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 5),
            content: const Text("Second Dose Done"),
            action: SnackBarAction(
                label: "Print Certificate",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return CertificateScreen(
                      email: value['email'],
                    );
                  }));
                }),
          ));
        }
      }).catchError((e) {
        setState(() {
          isValidating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5),
          content: const Text("User Record Not Found"),
          action: SnackBarAction(
              label: "Register Now",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const RegisterScreen();
                }));
              }),
        ));
      });
    }
  }
}
