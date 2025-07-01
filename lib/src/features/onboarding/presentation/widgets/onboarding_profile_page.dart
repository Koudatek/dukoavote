import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dukoavote/src/core/theme/app_colors.dart';

class OnboardingProfilePage extends StatefulWidget {
  final void Function(String? gender, DateTime? birthDate) onValidate;
  const OnboardingProfilePage({super.key,required this.onValidate});

  @override
  State<OnboardingProfilePage> createState() => _OnboardingProfilePageState();
}

class _OnboardingProfilePageState extends State<OnboardingProfilePage> {
  String? _selectedGender;
  final List<FocusNode> _focusNodes = List.generate(8, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(8, (_) => TextEditingController());

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  DateTime? get _birthDate {
    try {
      final day = int.parse(_controllers[0].text + _controllers[1].text);
      final month = int.parse(_controllers[2].text + _controllers[3].text);
      final year = int.parse(_controllers[4].text + _controllers[5].text + _controllers[6].text + _controllers[7].text);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  bool get _isValid {
    return _selectedGender != null &&
      _controllers.every((c) => c.text.isNotEmpty) &&
      _birthDate != null;
  }

  void _onFieldChanged(int index, String value) {
    if (value.length == 1 && index < 7) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Widget _buildDateInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Jour (JJ)
        Column(
          children: [
            Row(
              children: List.generate(2, (i) {
                return Container(
                  width: 45,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => _onFieldChanged(i, v),
                  ),
                );
              }),
            ),
            Text("Jour", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
          ],
        ),
        const SizedBox(width: 13),
        // Mois (MM)
        Column(
          children: [
            Row(
              children: List.generate(2, (i) {
                return Container(
                  width: 45,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextField(
                    controller: _controllers[i + 2],
                    focusNode: _focusNodes[i + 2],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => _onFieldChanged(i + 2, v),
                  ),
                );
              }),
            ),
            Text("Mois", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
          ],
        ),
        const SizedBox(width: 13),
        // Année (AAAA)
        Column(
          children: [
            Row(
              children: List.generate(4, (i) {
                return Container(
                  width: 45,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextField(
                    controller: _controllers[i + 4],
                    focusNode: _focusNodes[i + 4],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => _onFieldChanged(i + 4, v),
                  ),
                );
              }),
            ),
            Text("Année", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            Text(
              "Pour mieux comprendre la communauté, peux-tu nous indiquer :",
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Text(
              "Genre",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GenderItem(
                  label: "Homme",
                  icon: Icons.man_outlined,
                  selected: _selectedGender == "Homme",
                  onTap: () => setState(() => _selectedGender = "Homme"),
                ),
                const SizedBox(width: 16),
                _GenderItem(
                  label: "Femme",
                  icon: Icons.woman_outlined,
                  selected: _selectedGender == "Femme",
                  onTap: () => setState(() => _selectedGender = "Femme"),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              "Date de naissance",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildDateInput(),
            const SizedBox(height: 32),
            ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed:_isValid ? () => widget.onValidate(_selectedGender, _birthDate) : null,
                      child: Text( "Valide",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
          ],
        ),
    );
  }
}

class _GenderItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.grey.shade200,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? AppColors.primary : Colors.black54),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}