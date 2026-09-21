import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showReportDialog(BuildContext context, {required String targetType, required dynamic targetId}) {
  const Color neonGreen = Color(0xFF00FF00); 
  const Color darkOliveBg = Color(0xFF162016); 
  const Color whiteTextColor = Colors.white;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: darkOliveBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: neonGreen,
          onPrimary: Colors.black,
          surface: darkOliveBg,
          onSurface: whiteTextColor,
        ),
        scaffoldBackgroundColor: darkOliveBg,
        dialogTheme: const DialogThemeData(backgroundColor: darkOliveBg),
      ),
      child: ReportFormWidget(targetType: targetType, targetId: targetId),
    ),
  );
}

class ReportFormWidget extends StatefulWidget {
  final String targetType;
  final dynamic targetId;

  const ReportFormWidget({super.key, required this.targetType, required this.targetId});

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  final _supabase = Supabase.instance.client;
  final _textController = TextEditingController();
  
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase
          .from('report_categories')
          .select()
          .eq('is_active', true)
          .or('target_type.eq.${widget.targetType},target_type.eq.general');
      
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for reporting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      final String? formattedTargetId = widget.targetId?.toString();
      
      await _supabase.from('reports').insert({
        'reporter_id': userId,
        'category_id': _selectedCategoryId,
        'target_type': widget.targetType,
        'target_id': formattedTargetId,
        'description': _textController.text.trim().isEmpty ? null : _textController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully. Thank you!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFF00FF00);
    const Color mutedLabelColor = Color(0xFF8F9E8F);

    final Map<String, List<Map<String, dynamic>>> groupedCategories = {};
    for (var cat in _categories) {
      final group = cat['group_name'] as String;
      groupedCategories.putIfAbsent(group, () => []).add(cat);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Submit a Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: neonGreen)))
            else ...[
              const Text('Select a reason:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
              const SizedBox(height: 8),
              
              // Single RadioGroup wrapping the single loop
              RadioGroup<String>(
                groupValue: _selectedCategoryId,
                onChanged: (value) => setState(() => _selectedCategoryId = value),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groupedCategories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedLabelColor),
                          ),
                        ),
                        ...entry.value.map((cat) {
                          return RadioListTile<String>(
                            title: Text(cat['title'], style: const TextStyle(fontSize: 14, color: Colors.white)),
                            value: cat['id'],
                            activeColor: neonGreen,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Additional details (optional)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  hintText: 'Provide any extra context...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: neonGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isSubmitting ? null : _submitReport,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}