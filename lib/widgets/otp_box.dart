import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final double boxSize;
  final ValueChanged<String> onCompleted;

  const OtpInput({
    super.key,
    this.length = 4,
    this.boxSize = 50,
    required this.onCompleted,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> with CodeAutoFill {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length >= widget.length) {
      for (int i = 0; i < widget.length; i++) {
        controllers[i].text = code![i];
      }
      widget.onCompleted(code!.substring(0, widget.length));
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }

    final otp = controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = (widget.length - 1) * Dimensions.width10;
        final maxBoxWidth =
            (constraints.maxWidth - totalSpacing) / widget.length;
        final boxExtent =
            maxBoxWidth.isFinite
                ? maxBoxWidth.clamp(44.0, widget.boxSize).toDouble()
                : widget.boxSize;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: boxExtent,
              height: boxExtent,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                maxLength: 1,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                cursorColor: AppColors.primary5,
                style: TextStyle(
                  fontSize: boxExtent * 0.36,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black1,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(
                      color: AppColors.primary5.withValues(alpha: 0.10),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(
                      color: AppColors.primary5.withValues(alpha: 0.14),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.primary5,
                      width: 1.6,
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                ),
                onChanged: (value) => _onChanged(value, index),
              ),
            );
          }),
        );
      },
    );
  }
}
