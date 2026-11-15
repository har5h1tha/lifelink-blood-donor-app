// Blood compatibility lookup (owner: Member 2)
//
// Key   = the group the PATIENT (recipient) needs.
// Value = donor groups that can safely give blood to that patient.
const Map<String, List<String>> _donorsForRecipient = {
  'A+': ['A+', 'A-', 'O+', 'O-'],
  'A-': ['A-', 'O-'],
  'B+': ['B+', 'B-', 'O+', 'O-'],
  'B-': ['B-', 'O-'],
  'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // universal recipient
  'AB-': ['A-', 'B-', 'AB-', 'O-'],
  'O+': ['O+', 'O-'],
  'O-': ['O-'], // can only receive O-
};

/// Returns every donor group that can give to [recipientGroup].
/// Example: compatibleDonors('A+') -> ['A+', 'A-', 'O+', 'O-']
List<String> compatibleDonors(String recipientGroup) {
  // If the group is unknown, fall back to the same group only.
  return _donorsForRecipient[recipientGroup] ?? [recipientGroup];
}
