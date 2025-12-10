import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/database/database.dart';
import "package:geohetra/data/colors.dart" as color;
import "package:geohetra/components/components.dart";
import 'package:geohetra/components/button.dart';
import 'package:geohetra/models/ifpb.dart';

class FormIfpb extends StatefulWidget {
  final Ifpb? ifpb;
  final Function setter;
  final String? numcons;
  
  const FormIfpb({
    Key? key,
    this.ifpb,
    required this.setter,
    this.numcons,
  }) : super(key: key);

  @override
  State<FormIfpb> createState() => _FormIfpbState();
}

class _FormIfpbState extends State<FormIfpb> {
  Ifpb? ifpb;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  // Couleurs cohérentes
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  late String exon;
  late TextEditingController cause;
  late TextEditingController dernanne;
  late TextEditingController montantins;
  late TextEditingController montantpay;
  late TextEditingController article;
  late TextEditingController role;

  late FocusNode deranneFocus;
  late FocusNode montantinsFocus;
  late FocusNode montantpayFocus;
  late FocusNode articleFocus;
  late FocusNode roleFocus;

  @override
  void initState() {
    super.initState();
    ifpb = widget.ifpb;
    
    exon = ifpb?.exon ?? "oui";
    cause = TextEditingController(text: ifpb?.cause ?? "");
    dernanne = TextEditingController(text: ifpb?.dernanne ?? "");
    montantins = TextEditingController(text: ifpb?.montantins.toString() ?? "0");
    montantpay = TextEditingController(text: ifpb?.montantpay.toString() ?? "0");
    article = TextEditingController(text: ifpb?.article?.toString() ?? "");
    role = TextEditingController(text: ifpb?.role?.toString() ?? "");

    deranneFocus = FocusNode();
    montantinsFocus = FocusNode();
    montantpayFocus = FocusNode();
    articleFocus = FocusNode();
    roleFocus = FocusNode();
  }

  @override
  void dispose() {
    cause.dispose();
    dernanne.dispose();
    montantins.dispose();
    montantpay.dispose();
    article.dispose();
    role.dispose();
    deranneFocus.dispose();
    montantinsFocus.dispose();
    montantpayFocus.dispose();
    articleFocus.dispose();
    roleFocus.dispose();
    super.dispose();
  }

  Ifpb getIfpb() {
    return Ifpb(
      exon: exon,
      dernanne: dernanne.text.trim(),
      montantins: int.tryParse(montantins.text) ?? 0,
      montantpay: int.tryParse(montantpay.text) ?? 0,
      cause: cause.text.trim(),
      article: int.tryParse(article.text),
      role: int.tryParse(role.text),
    );
  }

  Future<void> handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.numcons == null || widget.numcons!.isEmpty) {
      _showSnackBar("Erreur : aucun numéro de construction fourni", isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      Ifpb ifpb = getIfpb();
      ifpb.datetimes = now();
      ifpb.numif = await identity();

      await DB.instance.insertIfpb(ifpb, widget.numcons!);
      widget.setter(ifpb);

      if (mounted) {
        _showSnackBar('Enregistré avec succès', isError: false);
        Timer(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      Ifpb ifpb = getIfpb();
      ifpb.numif = widget.ifpb!.numif;
      ifpb.datetimes = widget.ifpb!.datetimes;

      await DB.instance.updateIfpb(ifpb);
      widget.setter(ifpb);

      if (mounted) {
        _showSnackBar('Mis à jour avec succès', isError: false);
        Timer(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType ?? TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: errorColor),
          ),
          errorStyle: const TextStyle(fontSize: 10),
        ),
        validator: validator,
        textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        },
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContribuableSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contribuable",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          RadioListTile<String>(
            value: "oui",
            groupValue: exon,
            title: const Text("Oui", style: TextStyle(fontSize: 13)),
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onChanged: (value) {
              setState(() => exon = value!);
            },
          ),
          RadioListTile<String>(
            value: "non",
            groupValue: exon,
            title: const Text("Non", style: TextStyle(fontSize: 13)),
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onChanged: (value) {
              setState(() => exon = value!);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          ifpb == null ? "Nouveau IFPB" : "Modifier IFPB",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildHeader("Informations fiscales", Icons.receipt_long_outlined),

                    _buildContribuableSelector(),

                    if (exon == "oui") ...[
                      _buildTextField(
                        controller: dernanne,
                        label: "Dernière année de l'avis",
                        focusNode: deranneFocus,
                        nextFocus: montantinsFocus,
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (exon == "oui" && (v == null || v.trim().isEmpty)) {
                            return "Obligatoire pour les contribuables";
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: montantins,
                        label: "Montant inscrit (Ar)",
                        focusNode: montantinsFocus,
                        nextFocus: montantpayFocus,
                        icon: Icons.attach_money,
                        validator: (v) {
                          if (exon == "oui" && v != null && v.isNotEmpty && int.tryParse(v) == null) {
                            return "Montant invalide";
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: montantpay,
                        label: "Montant payé (Ar)",
                        focusNode: montantpayFocus,
                        nextFocus: articleFocus,
                        icon: Icons.payment_outlined,
                        validator: (v) {
                          if (exon == "oui" && v != null && v.isNotEmpty && int.tryParse(v) == null) {
                            return "Montant invalide";
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: article,
                        label: "Article",
                        focusNode: articleFocus,
                        nextFocus: roleFocus,
                        icon: Icons.description_outlined,
                        validator: (v) => null,
                      ),

                      _buildTextField(
                        controller: role,
                        label: "Rôle",
                        focusNode: roleFocus,
                        icon: Icons.assignment_outlined,
                        validator: (v) => null,
                      ),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : (ifpb == null ? handleSave : handleUpdate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: textSecondaryColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          ifpb == null ? "Enregistrer" : "Mettre à jour",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}