import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import 'package:jobhud/services/culture_preference_service.dart';
import 'package:jobhud/screens/dashboard/culture_quiz_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final CulturePreferenceService _cultureService = CulturePreferenceService();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _headlineController;
  late TextEditingController _bioController;
  
  // Professional info controllers
  late TextEditingController _currentPositionController;
  late TextEditingController _companyController;
  late TextEditingController _industryController;
  late TextEditingController _skillsController;
  late TextEditingController _educationController;
  late TextEditingController _experienceController;
  
  // State variables
  bool _isEditing = false;
  bool _isLoading = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  // User data
  String _name = 'Loading...';
  String _email = 'Loading...';
  String _phone = '';
  String _location = '';
  String _headline = 'Professional';
  String _bio = 'Tell us about yourself...';
  
  // Professional data
  String _currentPosition = '';
  String _company = '';
  String _industry = '';
  String _skills = '';
  String _education = '';
  String _experience = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeCultureService();
    
    // Load from local storage first
    _loadFromLocalStorage().then((_) {
      // Then try to load from server
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.isAuthenticated) {
          if (authProvider.user != null) {
            _updateUIWithUserData(authProvider.user!);
          }
          _loadProfile();
        } else {
          // If not authenticated but have local data, use it
          if (_name != 'Loading...' && _name.isNotEmpty) {
            setState(() => _isLoading = false);
          } else if (mounted) {
            context.go('/login');
          }
        }
      });
    });
  }
  
  Future<void> _initializeCultureService() async {
    await _cultureService.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload if we're mounted and the widget is still in the tree
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        _loadProfile();
      }
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _name);
    _emailController = TextEditingController(text: _email);
    _phoneController = TextEditingController(text: _phone);
    _locationController = TextEditingController(text: _location);
    _headlineController = TextEditingController(text: _headline);
    _bioController = TextEditingController(text: _bio);
    
    // Initialize professional info controllers
    _currentPositionController = TextEditingController(text: _currentPosition);
    _companyController = TextEditingController(text: _company);
    _industryController = TextEditingController(text: _industry);
    _skillsController = TextEditingController(text: _skills);
    _educationController = TextEditingController(text: _education);
    _experienceController = TextEditingController(text: _experience);
  }

  void _updateUIWithUserData(Map<String, dynamic> userData) {
    _name = userData['name'] ?? _name;
    _email = userData['email'] ?? _email;
    _phone = userData['phone'] ?? _phone;
    _location = userData['location'] ?? _location;
    _headline = userData['headline'] ?? _headline;
    _bio = userData['bio'] ?? _bio;
    _currentPosition = userData['currentPosition'] ?? _currentPosition;
    _company = userData['company'] ?? _company;
    _industry = userData['industry'] ?? _industry;
    _skills = userData['skills'] ?? _skills;
    _education = userData['education'] ?? _education;
    _experience = userData['experience'] ?? _experience;
    
    // Load profile image if exists
    if (userData['profileImagePath'] != null && userData['profileImagePath'].isNotEmpty) {
      _profileImage = File(userData['profileImagePath']);
    }

    _updateControllers();
  }

  void _updateControllers() {
    _nameController.text = _name;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _locationController.text = _location;
    _headlineController.text = _headline;
    _bioController.text = _bio;
    _currentPositionController.text = _currentPosition;
    _companyController.text = _company;
    _industryController.text = _industry;
    _skillsController.text = _skills;
    _educationController.text = _education;
    _experienceController.text = _experience;
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load name
      final nameData = prefs.getString('profile_name');
      if (nameData != null && nameData.isNotEmpty) {
        _name = nameData;
      }
      
      // Load email
      final emailData = prefs.getString('profile_email');
      if (emailData != null && emailData.isNotEmpty) {
        _email = emailData;
      }
      
      // Load phone
      final phoneData = prefs.getString('profile_phone');
      if (phoneData != null && phoneData.isNotEmpty) {
        _phone = phoneData;
      }
      
      // Load location
      final locationData = prefs.getString('profile_location');
      if (locationData != null && locationData.isNotEmpty) {
        _location = locationData;
      }
      
      // Load headline
      final headlineData = prefs.getString('profile_headline');
      if (headlineData != null && headlineData.isNotEmpty) {
        _headline = headlineData;
      }
      
      // Load bio
      final bioData = prefs.getString('profile_bio');
      if (bioData != null && bioData.isNotEmpty) {
        _bio = bioData;
      }
      
      // Load position
      final positionData = prefs.getString('profile_position');
      if (positionData != null && positionData.isNotEmpty) {
        _currentPosition = positionData;
      }
      
      // Load company
      final companyData = prefs.getString('profile_company');
      if (companyData != null && companyData.isNotEmpty) {
        _company = companyData;
      }
      
      // Load industry
      final industryData = prefs.getString('profile_industry');
      if (industryData != null && industryData.isNotEmpty) {
        _industry = industryData;
      }
      
      // Load skills
      final skillsData = prefs.getString('profile_skills');
      if (skillsData != null && skillsData.isNotEmpty) {
        _skills = skillsData;
      }
      
      // Load education
      final educationData = prefs.getString('profile_education');
      if (educationData != null && educationData.isNotEmpty) {
        _education = educationData;
      }
      
      // Load experience
      final experienceData = prefs.getString('profile_experience');
      if (experienceData != null && experienceData.isNotEmpty) {
        _experience = experienceData;
      }
      
      // Load profile image path
      final imagePathData = prefs.getString('profile_image_path');
      if (imagePathData != null && imagePathData.isNotEmpty) {
        _profileImage = File(imagePathData);
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
    }
  }

  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _name);
    await prefs.setString('profile_email', _email);
    await prefs.setString('profile_phone', _phone);
    await prefs.setString('profile_location', _location);
    await prefs.setString('profile_headline', _headline);
    await prefs.setString('profile_bio', _bio);
    await prefs.setString('profile_position', _currentPosition);
    await prefs.setString('profile_company', _company);
    await prefs.setString('profile_industry', _industry);
    await prefs.setString('profile_skills', _skills);
    await prefs.setString('profile_education', _education);
    await prefs.setString('profile_experience', _experience);
    
    if (_profileImage != null) {
      await prefs.setString('profile_image_path', _profileImage!.path);
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        // Don't redirect if we have local data
        if (_name == 'Loading...' && mounted) {
          context.go('/login');
        }
        return;
      }
      
      final userData = await authProvider.getProfile();
      
      if (mounted) {
        setState(() {
          _updateUIWithUserData(userData);
          _isLoading = false;
        });
        // Save to local storage after successful load
        await _saveToLocalStorage();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Don't show error if user is not authenticated (might be logging out)
        if (e.toString().contains('Not authenticated') || 
            e.toString().contains('token') ||
            e.toString().contains('401')) {
          // Only redirect if we don't have local data
          if (_name == 'Loading...' && mounted) {
            context.go('/login');
          }
          return;
        }
        
        // Show warning but don't prevent using the app
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Using local profile data. Could not refresh from server.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    // Update local state first for immediate feedback
    setState(() {
      _name = _nameController.text.trim();
      _email = _emailController.text.trim();
      _phone = _phoneController.text.trim();
      _location = _locationController.text.trim();
      _headline = _headlineController.text.trim();
      _bio = _bioController.text.trim();
      _currentPosition = _currentPositionController.text.trim();
      _company = _companyController.text.trim();
      _industry = _industryController.text.trim();
      _skills = _skillsController.text.trim();
      _education = _educationController.text.trim();
      _experience = _experienceController.text.trim();
    });
    
    // Save to local storage immediately
    await _saveToLocalStorage();
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final updatedData = {
        'name': _name,
        'email': _email,
        'phone': _phone,
        'location': _location,
        'headline': _headline,
        'bio': _bio,
        'currentPosition': _currentPosition,
        'company': _company,
        'industry': _industry,
        'skills': _skills,
        'education': _education,
        'experience': _experience,
      };
      
      // Try to update on server if authenticated
      if (authProvider.isAuthenticated) {
        try {
          final updatedUser = await authProvider.updateProfile(updatedData);
          _updateUIWithUserData(updatedUser);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // Silently fail and use local data
          debugPrint('Failed to update profile on server: $e');
        }
      } else {
        // Not authenticated but we've already saved locally
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved locally. Sign in to sync across devices.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      
      if (mounted) {
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        // Show error message but keep changes since they're saved locally
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Changes saved locally. ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Stay in edit mode if update fails
        setState(() => _isEditing = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); 
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        // Save to local storage when image is picked
        await _saveToLocalStorage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _profileImage = null;
                    });
                    // Remove from local storage
                    final prefs = SharedPreferences.getInstance().then((prefs) {
                      prefs.remove('profile_image_path');
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    
    // Dispose professional info controllers
    _currentPositionController.dispose();
    _companyController.dispose();
    _industryController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    setState(() => _isEditing = !_isEditing);
  }
  
  Future<void> _saveProfile() async {
    await _updateProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Redirect to login if not authenticated
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing) ...[
            // Save button in edit mode
            TextButton.icon(
              icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: _isLoading ? null : _saveProfile,
            ),
            // Cancel button in edit mode
            TextButton(
              onPressed: _isLoading ? null : _toggleEdit,
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
          ] else ...[
            // Edit button in view mode
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: _isLoading ? null : _toggleEdit,
              tooltip: 'Edit Profile',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _showImageSourceActionSheet : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _profileImage != null 
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing) ...[
                      Text(
                        _name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _headline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(_location),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Form
              if (_isEditing) ..._buildEditableFields(),
              if (!_isEditing) ..._buildReadOnlyFields(),

              const SizedBox(height: 32),
              
              // Sign Out Button
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEditableFields() {
    return [
      // Basic Info Section
      const Text(
        'Basic Information',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _locationController,
        decoration: const InputDecoration(
          labelText: 'Location',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _headlineController,
        decoration: const InputDecoration(
          labelText: 'Headline',
          prefixIcon: Icon(Icons.work_outline),
          hintText: 'E.g. Senior Flutter Developer',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _bioController,
        decoration: const InputDecoration(
          labelText: 'Bio',
          prefixIcon: Icon(Icons.info_outline),
          alignLabelWithHint: true,
        ),
        maxLines: 4,
        textAlignVertical: TextAlignVertical.top,
      ),
      
      // Professional Information Section
      const SizedBox(height: 24),
      const Text(
        'Professional Information',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _currentPositionController,
        decoration: const InputDecoration(
          labelText: 'Current Position',
          prefixIcon: Icon(Icons.work_outline),
          hintText: 'E.g. Senior Flutter Developer',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _companyController,
        decoration: const InputDecoration(
          labelText: 'Company',
          prefixIcon: Icon(Icons.business_outlined),
          hintText: 'E.g. Tech Solutions Inc.',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _industryController,
        decoration: const InputDecoration(
          labelText: 'Industry',
          prefixIcon: Icon(Icons.category_outlined),
          hintText: 'E.g. Information Technology',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _skillsController,
        decoration: const InputDecoration(
          labelText: 'Skills',
          prefixIcon: Icon(Icons.star_outline),
          hintText: 'E.g. Flutter, Dart, UI/UX, Agile',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _educationController,
        decoration: const InputDecoration(
          labelText: 'Education',
          prefixIcon: Icon(Icons.school_outlined),
          hintText: 'E.g. BSc in Computer Science, University of XYZ',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _experienceController,
        decoration: const InputDecoration(
          labelText: 'Work Experience',
          prefixIcon: Icon(Icons.history_edu_outlined),
          hintText: 'Briefly describe your work experience',
          alignLabelWithHint: true,
        ),
        maxLines: 3,
        textAlignVertical: TextAlignVertical.top,
      ),
    ];
  }

  List<Widget> _buildReadOnlyFields() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.email_outlined, _email),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone_outlined, _phone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, _location),
            const SizedBox(height: 24),
            const Text(
              'Job Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cultureService.hasCompletedQuiz
                    ? Colors.green[50]
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _cultureService.hasCompletedQuiz
                      ? Colors.green[200]!
                      : Colors.blue[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _cultureService.hasCompletedQuiz
                        ? Icons.check_circle
                        : Icons.quiz,
                    color: _cultureService.hasCompletedQuiz
                        ? Colors.green
                        : Colors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cultureService.hasCompletedQuiz
                              ? 'Culture Preferences Set'
                              : 'Set Your Culture Preferences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _cultureService.hasCompletedQuiz
                                ? Colors.green[800]
                                : Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cultureService.hasCompletedQuiz
                              ? 'Your preferences help us find better job matches'
                              : 'Take 2 minutes to help us find jobs that match your work style',
                          style: TextStyle(
                            fontSize: 14,
                            color: _cultureService.hasCompletedQuiz
                                ? Colors.green[600]
                                : Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CultureQuizScreen(
                            isOnboarding: false,
                          ),
                        ),
                      );
                      if (result == true) {
                        await _initializeCultureService();
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cultureService.hasCompletedQuiz
                          ? Colors.green
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      _cultureService.hasCompletedQuiz
                          ? 'Update'
                          : 'Take Quiz',
                    ),
                  ),
                ],
              ),
            ),
            // Professional Summary
            const SizedBox(height: 24),
            const Text(
              'Professional Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_currentPosition.isNotEmpty || _company.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.work_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '$_currentPosition${_company.isNotEmpty ? ' at $_company' : ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_industry.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(_industry, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_skills.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Skills: $_skills',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_education.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Education: $_education',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (_experience.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Work Experience:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                _experience,
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
            ],
            
            // About Me Section
            const SizedBox(height: 24),
            const Text(
              'About Me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _bio.isNotEmpty ? _bio : 'No bio provided',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text.isNotEmpty ? text : 'Not provided',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      // Navigate to login screen after sign out
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error signing out')),
        );
      }
    }
  }
}
