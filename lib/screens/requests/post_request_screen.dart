import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/request_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/request_viewmodel.dart';
 
class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});
 
  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}
 
class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
 
  String? _bloodGroup;
  String? _city;
  String _urgency = 'Normal';
  bool _submitted = false; // true after the first Submit tap (shows dropdown errors)
  bool _submitting = false; // true while saving
 
  @override
  void initState() {
    super.initState();
    // Default city and phone come from the logged-in user
    final user = context.read<AuthViewModel>().currentUser;
    if (user != null) {
      if (cities.contains(user.city)) _city = user.city;
      _phoneCtrl.text = user.phone;
    }
  }
 
  @override
  void dispose() {
    _patientCtrl.dispose();
    _hospitalCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
 
  // Same colours as UrgencyChip, taken from AppColors
  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'Critical':
        return AppColors.urgentCritical;
      case 'High':
        return AppColors.urgentHigh;
      default:
        return AppColors.urgentNormal;
    }
  }
 
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;
 
  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
      return 'Enter a 10 digit phone number';
    }
    return null;
  }
 
  Future<void> _submit() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _bloodGroup == null || _city == null) return;
 
    final messenger = ScaffoldMessenger.of(context);
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
 
    setState(() => _submitting = true);
    final request = RequestModel(
      id: '', // Firestore creates the real id
      patientName: _patientCtrl.text.trim(),
      bloodGroup: _bloodGroup!,
      hospital: _hospitalCtrl.text.trim(),
      city: _city!,
      urgency: _urgency,
      contactPhone: _phoneCtrl.text.trim(),
      status: statusOpen,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );
 
    final vm = context.read<RequestViewModel>();
    final ok = await vm.addRequest(request);
    if (!mounted) return;
    setState(() => _submitting = false);
 
    if (ok) {
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Request posted')));
    } else {
      messenger.showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Something went wrong')));
    }
  }
 
  // Small red text under a dropdown that is still empty
  Widget _dropdownError(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.gap, left: AppSizes.gap),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12, color: Theme.of(context).colorScheme.error),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _patientCtrl,
                label: 'Patient name',
                icon: Icons.person_outline,
                validator: _required,
              ),
              const SizedBox(height: AppSizes.padding),
              AppDropdown(
                label: 'Blood group',
                value: _bloodGroup,
                items: bloodGroups,
                onChanged: (v) => setState(() => _bloodGroup = v),
              ),
              if (_submitted && _bloodGroup == null)
                _dropdownError('Please select a blood group'),
              const SizedBox(height: AppSizes.padding),
              AppTextField(
                controller: _hospitalCtrl,
                label: 'Hospital',
                icon: Icons.local_hospital_outlined,
                validator: _required,
              ),
              const SizedBox(height: AppSizes.padding),
              AppDropdown(
                label: 'City',
                value: _city,
                items: cities,
                onChanged: (v) => setState(() => _city = v),
              ),
              if (_submitted && _city == null)
                _dropdownError('Please select a city'),
              const SizedBox(height: AppSizes.padding),
              Text('Urgency', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSizes.gap),
              Wrap(
                spacing: AppSizes.gap,
                children: [
                  for (final level in urgencyLevels)
                    ChoiceChip(
                      label: Text(level),
                      showCheckmark: false,
                      selected: _urgency == level,
                      selectedColor: _urgencyColor(level),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _urgency == level ? Colors.white : null,
                      ),
                      onSelected: (_) => setState(() => _urgency = level),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.padding),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Contact phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _phoneValidator,
              ),
              const SizedBox(height: AppSizes.padding * 1.5),
              PrimaryButton(
                label: 'Submit',
                icon: Icons.send,
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}