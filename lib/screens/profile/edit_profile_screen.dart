import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/auth_validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String? _bloodGroup;
  String? _city;
  DateTime? _lastDonated;

  @override
  void initState() {
    super.initState();
    // Fill the form with the current values
    final u = context.read<AuthViewModel>().currentUser;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
    // A dropdown crashes if its value is not in its list, so check first
    _bloodGroup = bloodGroups.contains(u?.bloodGroup) ? u?.bloodGroup : null;
    _city = cities.contains(u?.city) ? u?.city : null;
    _lastDonated = u?.lastDonated;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().clearError();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonated ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _lastDonated = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final user = auth.currentUser;
    if (user == null) return;

    // copyWith builds a new UserModel with only the changed fields
    final updated = user.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      city: _city,
      lastDonated: _lastDonated,
    );
    final ok = await auth.updateProfile(updated);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    const gap = SizedBox(height: AppSizes.padding);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  icon: Icons.person_outline,
                  validator: (v) => validateRequired(v, 'Name'),
                ),
                gap,
                AppTextField(
                  controller: _phoneCtrl,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: validatePhone,
                ),
                gap,
                AppDropdown(
                  label: 'Blood group',
                  value: _bloodGroup,
                  items: bloodGroups,
                  onChanged: (v) => setState(() => _bloodGroup = v),
                  validator: (v) => v == null ? 'Select your blood group' : null,
                ),
                gap,
                AppDropdown(
                  label: 'City',
                  value: _city,
                  items: cities,
                  onChanged: (v) => setState(() => _city = v),
                  validator: (v) => v == null ? 'Select your city' : null,
                ),
                gap,
                InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Last donated',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(
                      _lastDonated == null
                          ? 'Not set'
                          : DateFormat('dd MMM yyyy').format(_lastDonated!),
                    ),
                  ),
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: AppSizes.gap),
                  Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: AppColors.urgentCritical),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save changes',
                  isLoading: auth.isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
