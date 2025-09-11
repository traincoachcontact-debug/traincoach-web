// lib/screens/profile_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// --- Importaciones de Firebase ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  // Ahora la pantalla puede recibir un userId para ver perfiles de otros
  // o ser null para ver el perfil propio.
  final String? userId;
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isMyProfile = false;

  // Datos del perfil
  String _name = "";
  DateTime? _dateOfBirth;
  int? _age;
  String _preferences = "";
  String? _mainProfileImageUrl; // Puede ser una URL remota o un path local temporal
  List<dynamic> _otherImageSources = []; // Puede contener URLs (String) o XFiles (nuevas imágenes)

  // Controllers para edición
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  late String _profileOwnerId;

  @override
  void initState() {
    super.initState();
    // Determina si estamos viendo nuestro propio perfil o el de otro usuario.
    final currentUserId = _auth.currentUser?.uid;
    _profileOwnerId = widget.userId ?? currentUserId ?? '';
    _isMyProfile = (widget.userId == null || widget.userId == currentUserId);

    if (_profileOwnerId.isNotEmpty) {
      _loadProfileData();
      _registerProfileViewIfNeeded();
    } else {
      // Si no hay ID de perfil ni usuario logueado, no se puede hacer nada.
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }
  
  // --- Lógica de Registro de Visitas ---
  void _registerProfileViewIfNeeded() {
    final currentUser = _auth.currentUser;
    // Solo registra la visita si estamos viendo el perfil de OTRA persona.
    if (currentUser != null && !_isMyProfile) {
      final viewerRef = _firestore
          .collection('users')
          .doc(_profileOwnerId) // Documento del perfil visitado
          .collection('profileViewers')
          .doc(currentUser.uid); // Documento con el ID del visitante

      // Usamos .set() para que cada usuario solo aparezca una vez, 
      // actualizando la hora de la última visita.
      viewerRef.set({
        'viewerId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // --- Lógica de Datos con Firebase ---
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    try {
      final docSnapshot = await _firestore.collection('users').doc(_profileOwnerId).get();
      if (mounted && docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        setState(() {
          _name = data['displayName'] ?? '';
          _dateOfBirth = (data['dateOfBirth'] as Timestamp?)?.toDate();
          _age = _dateOfBirth != null ? _calculateAge(_dateOfBirth!) : null;
          _preferences = data['preferences'] ?? '';
          _mainProfileImageUrl = data['photoURL'];
          _otherImageSources = List.from(data['otherImageUrls'] ?? []);
          
          _nameController.text = _name;
          _preferencesController.text = _preferences;
        });
      }
    } catch (e) {
      print("Error al cargar datos del perfil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar el perfil: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfileData() async {
    if (_isSaving || !_isMyProfile) return;
    setState(() => _isSaving = true);
    
    try {
      String? finalMainImageUrl = _mainProfileImageUrl;
      // Si la URL de la imagen principal no empieza con 'http', es un archivo local y hay que subirlo.
      if (_mainProfileImageUrl != null && !_mainProfileImageUrl!.startsWith('http')) {
        finalMainImageUrl = await _uploadImage(File(_mainProfileImageUrl!));
      }
      
      List<String> finalOtherImageUrls = [];
      for (var source in _otherImageSources) {
        if (source is XFile) { // Si es un XFile, es una imagen nueva para subir.
          String? url = await _uploadImage(File(source.path));
          if (url != null) finalOtherImageUrls.add(url);
        } else if (source is String) { // Si es un String, es una URL existente.
          finalOtherImageUrls.add(source);
        }
      }
      
      // Prepara el mapa de datos para actualizar en Firestore.
      Map<String, dynamic> dataToUpdate = {
        'displayName': _nameController.text,
        'preferences': _preferencesController.text,
        'dateOfBirth': _dateOfBirth != null ? Timestamp.fromDate(_dateOfBirth!) : null,
        'photoURL': finalMainImageUrl,
        'otherImageUrls': finalOtherImageUrls,
      };

      // Usamos .set con merge:true para crear o actualizar el documento de forma segura.
      await _firestore.collection('users').doc(_profileOwnerId).set(dataToUpdate, SetOptions(merge: true));
      
      if (mounted) {
        setState(() {
          // Actualizamos el estado local con los datos guardados.
          _name = _nameController.text;
          _preferences = _preferencesController.text;
          _mainProfileImageUrl = finalMainImageUrl;
          _otherImageSources = finalOtherImageUrls;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado con éxito'), backgroundColor: Colors.green));
      }
    } catch (e) {
      print("Error al guardar el perfil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar el perfil: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    if (!_isMyProfile) return null;
    
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('profile_pictures/$_profileOwnerId/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir la imagen: $e");
      return null;
    }
  }

  // --- El resto de tus funciones de UI y helpers ---

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _age = _calculateAge(picked);
      });
    }
  }

  Future<void> _pickImage(bool isMainImage, {int? indexToReplace}) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        if (isMainImage) {
          _mainProfileImageUrl = pickedFile.path;
        } else {
          if (indexToReplace != null && indexToReplace < _otherImageSources.length) {
            _otherImageSources[indexToReplace] = pickedFile;
          } else {
            _otherImageSources.add(pickedFile);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMyProfile ? (_isEditing ? 'Editar Perfil' : 'Mi Perfil') : _name),
        actions: _isMyProfile ? _buildAppBarActions() : [],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfilePhotoSection(),
                      const SizedBox(height: 24),
                      _buildReadOnlyTextField(label: 'Nombre', value: _name, controller: _nameController, icon: Icons.person),
                      const SizedBox(height: 16),
                      _buildDateOfBirthOrAgeField(),
                      const SizedBox(height: 16),
                      _buildReadOnlyTextField(label: 'Preferencias', value: _preferences, controller: _preferencesController, icon: Icons.favorite_border, maxLines: 3),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (_isSaving) Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
              ],
            ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isEditing) {
      return [
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: _isSaving ? null : () => setState(() { _isEditing = false; _loadProfileData(); }),
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _isSaving ? null : _saveProfileData,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => setState(() { _isEditing = true; }),
        ),
      ];
    }
  }
  
  // Tu UI se mantiene casi igual, solo con pequeños ajustes para _isEditing
  Widget _buildProfilePhotoSection() {
    ImageProvider? mainPhotoImage;
    if (_mainProfileImageUrl != null && _mainProfileImageUrl!.startsWith('http')) {
      mainPhotoImage = NetworkImage(_mainProfileImageUrl!);
    } else if (_mainProfileImageUrl != null) { 
      mainPhotoImage = FileImage(File(_mainProfileImageUrl!));
    }

    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: mainPhotoImage,
                child: (mainPhotoImage == null) ? Icon(Icons.person, size: 60, color: Colors.grey[600]) : null,
              ),
              if (_isEditing)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: IconButton(
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)),
                    onPressed: _isSaving ? null : () => _pickImage(true),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Otras Fotos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _otherImageSources.length + (_isEditing ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isEditing && index == _otherImageSources.length) {
                return _buildAddPhotoButton();
              }
              final imageSource = _otherImageSources[index];
              return _buildOtherPhotoItem(imageSource, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOtherPhotoItem(dynamic imageSource, int index) {
    ImageProvider imageProvider;
    if (imageSource is String && imageSource.startsWith('http')) {
      imageProvider = NetworkImage(imageSource);
    } else if (imageSource is XFile) {
      imageProvider = FileImage(File(imageSource.path));
    } else {
      imageProvider = const AssetImage('assets/images/placeholder_image.png');
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image(image: imageProvider, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                return Container(width: 100, height: 100, color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey));
            }),
          ),
          if (_isEditing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(8.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 20), onPressed: _isSaving ? null : () => _pickImage(false, indexToReplace: index)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: _isSaving ? null : () => setState(() => _otherImageSources.removeAt(index))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: _isSaving ? null : () => _pickImage(false),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid)),
          child: Center(child: Icon(Icons.add_a_photo, color: Colors.grey[600], size: 30)),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthOrAgeField() {
    if (_isEditing) {
      return InkWell(
        onTap: () => _selectDateOfBirth(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Fecha de Nacimiento',
            prefixIcon: const Icon(Icons.cake),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          child: Text(
            _dateOfBirth != null ? DateFormat('dd/MM/yyyy', 'es_ES').format(_dateOfBirth!) : 'Toca para seleccionar',
            style: TextStyle(fontSize: 16, color: _dateOfBirth != null ? Colors.black87 : Colors.grey[700]),
          ),
        ),
      );
    } else {
      return InputDecorator(
        decoration: const InputDecoration(labelText: 'Edad', prefixIcon: Icon(Icons.cake), border: InputBorder.none, contentPadding: EdgeInsets.zero),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
          child: Text(_age != null ? '$_age años' : 'No especificada', style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4)),
        ),
      );
    }
  }

  Widget _buildReadOnlyTextField({required String label, required String value, required TextEditingController controller, required IconData icon, int maxLines = 1}) {
    if (_isEditing) {
      return TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), filled: true, fillColor: Colors.grey[100]),
      );
    } else {
      return InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: InputBorder.none, contentPadding: EdgeInsets.zero),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
          child: Text(
            value.isEmpty ? 'No especificado' : value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4),
            maxLines: maxLines > 1 ? null : 1,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }
  }
}
