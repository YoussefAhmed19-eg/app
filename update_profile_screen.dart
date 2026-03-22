import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  User? get user => FirebaseAuth.instance.currentUser;

  String? _selectedAvatarUrl;

  final List<String> _avatars = [
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140047.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140051.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140039.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140040.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140043.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140044.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140045.png',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
    _selectedAvatarUrl = user?.photoURL ?? _avatars[0];
  }

  Future<void> _updateProfile() async {
    if (user == null) return;
    try {
      await user?.updateDisplayName(_nameController.text);
      await user?.updatePhotoURL(_selectedAvatarUrl);

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'avatar': _selectedAvatarUrl,
      }, SetOptions(merge: true));

      await user?.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("profile_updated".tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Update Error: $e");
    }
  }

  void _showDeleteDialog() {
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282A28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "delete_account".tr(),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "delete_confirm".tr(),
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr(), style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5193E),
            ),
            onPressed: () async {
              if (currentUser == null) {
                print("Error: User is null");
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .delete();

                await currentUser.delete();

                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "relogin_needed".tr(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              } catch (e) {
                print("Delete Error: $e");
              }
            },
            child: Text("delete_account".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = context.locale == const Locale('en');

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        title: Text(
          "pick_avatar".tr(),
          style: const TextStyle(color: Color(0xFFFFBB3B), fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isEn ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            color: const Color(0xFFFFBB3B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 65,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(_selectedAvatarUrl ?? _avatars[0]),
            ),
            const SizedBox(height: 40),
            _buildTextField(_nameController, "full_name".tr(), Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, "phone_number".tr(), Icons.phone),
            const SizedBox(height: 20),
            Align(
              alignment: isEn ? Alignment.centerLeft : Alignment.centerRight,
              child: Text(
                "reset_password".tr(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF282A28),
                borderRadius: BorderRadius.circular(15),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedAvatarUrl == _avatars[index];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedAvatarUrl = _avatars[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFBB3B)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(_avatars[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showDeleteDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5193E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "delete_account".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBB3B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "update_data".tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF282A28),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
