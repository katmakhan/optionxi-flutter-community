// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class Cust_Form_field extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function()? onChangedFnction;
  final String cus_label;
  final String hintText;
  final bool? enabled;

  const Cust_Form_field(
      {super.key,
      required this.cus_label,
      this.controller,
      this.validator,
      this.onChangedFnction,
      this.keyboardType,
      required this.hintText,
      this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      // margin: EdgeInsets.fromLTRB(4, 12, 16, 0),
      // height: 48,
      decoration: ShapeDecoration(
        color: Color.fromARGB(51, 189, 197, 194),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: TextFormField(
          maxLines: 1,
          style: const TextStyle(
              fontFamily: "Kanit",
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Color.fromARGB(255, 255, 255, 255)),
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            hintText: hintText,

            labelStyle: TextStyle(
                fontFamily: "Kanit",
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color:
                    Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.4)),
            labelText: cus_label,
            // prefixIcon: Icon(Icons.email),
          ),
          enabled: enabled,
          keyboardType: keyboardType,
          controller: controller,
          onChanged: (value) {
            if (onChangedFnction != null) {
              onChangedFnction!.call(); // Invoke onSaved if it is not null
            }
          },
          // initialValue: val,
          // validator: (value) {
          //   return "true";
          //   // return addprofiledetailContoller.validateName(value!);
          // },
          validator: validator,
        ),
      ),
    );
  }
}
