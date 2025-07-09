import 'package:flutter/material.dart';

class FilterModal extends StatelessWidget {
  final double maxBudget;
  final String selectedRoomType;
  final bool selfContained;
  final bool furnished;
  final bool fenced;
  final void Function({
    double? maxBudget,
    String? roomType,
    bool? selfContained,
    bool? furnished,
    bool? fenced,
  }) onApply;

  const FilterModal({
    super.key,
    required this.maxBudget,
    required this.selectedRoomType,
    required this.selfContained,
    required this.furnished,
    required this.fenced,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    double _tempBudget = maxBudget;
    String _tempRoomType = selectedRoomType;
    bool _tempSelf = selfContained;
    bool _tempFurn = furnished;
    bool _tempFence = fenced;

    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text('Budget: UGX'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 2000000,
                    divisions: 20,
                    value: _tempBudget,
                    label: _tempBudget.round().toString(),
                    onChanged: (value) => setState(() => _tempBudget = value),
                  ),
                ),
              ],
            ),

            DropdownButtonFormField<String>(
              value: _tempRoomType,
              items: ['Any', 'Bedsitter', '1 Bedroom', '2 Bedroom']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _tempRoomType = value!),
              decoration: const InputDecoration(labelText: 'Room Type'),
            ),

            CheckboxListTile(
              title: const Text('Self-contained'),
              value: _tempSelf,
              onChanged: (value) => setState(() => _tempSelf = value!),
            ),
            CheckboxListTile(
              title: const Text('Furnished'),
              value: _tempFurn,
              onChanged: (value) => setState(() => _tempFurn = value!),
            ),
            CheckboxListTile(
              title: const Text('Fenced'),
              value: _tempFence,
              onChanged: (value) => setState(() => _tempFence = value!),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                onApply(
                  maxBudget: _tempBudget,
                  roomType: _tempRoomType,
                  selfContained: _tempSelf,
                  furnished: _tempFurn,
                  fenced: _tempFence,
                );
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
