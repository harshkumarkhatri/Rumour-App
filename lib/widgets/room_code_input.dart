import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class RoomCodeInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  const RoomCodeInput({
    super.key,
    required this.onCompleted,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<RoomCodeInput> createState() => _RoomCodeInputState();
}

class _RoomCodeInputState extends State<RoomCodeInput> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;

  @override
  void dispose() {
    _controller.dispose();
    // Only dispose if created internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't auto-focus
      // FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _handleChanged(String value) {
    widget.onChanged(value);
    if (value.length == 6) {
      widget.onCompleted(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: _handleChanged,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                cursorColor: Colors.transparent,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildSlot(index);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(int index) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final text = value.text;
        final char = index < text.length ? text[index] : "";
        final isFocused = index == text.length;
        
        return Container(
          width: 28,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isFocused && _focusNode.hasFocus
                    ? AppColors.limeAccent
                    : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textMuted2
                    : AppColors.textSecondaryLight,
                width: 6,
              ),
            ),
          ),
          child: Text(
            char,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textMuted2
                  : Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
