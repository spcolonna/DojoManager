import 'package:flutter/cupertino.dart';

import 'activity_picker_sheet_State.dart';

class ActivityPickerSheet extends StatefulWidget {
  final List<String> currentIds;
  final void Function(List<String>) onConfirm;

  const ActivityPickerSheet({super.key, 
    required this.currentIds,
    required this.onConfirm,
  });

  @override
  State<ActivityPickerSheet> createState() => ActivityPickerSheetState();
}