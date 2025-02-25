import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../theme/app_colors.dart';
import '../services/tts_service.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final _audioRecorder = AudioRecorder();
  final TextEditingController _voiceNameController = TextEditingController();
  final Map<String, Map<String, dynamic>> _customVoices = {};
  final TTSService _ttsService = TTSService();
  
  bool _isRecording = false;
  String _recordingPath = '';
  String _selectedVoiceProfile = 'default';
  double _pitchValue = 1.0;
  double _speedValue = 1.0;
  final Map<String, String> _voiceProfileNames = {
    'default': 'Default Voice',
    'math': 'Math Teacher',
    'language': 'Language Tutor',
    'memory': 'Memory Coach',
    'life_skills': 'Life Skills Guide',
  };

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _loadCustomVoices();
    _loadVoiceProfileSettings();
  }

  Future<void> _loadVoiceProfileSettings() async {
    // Load the current voice profile settings
    setState(() {
      _selectedVoiceProfile = 'default';
      _updateSliderValues();
    });
  }

  void _updateSliderValues() {
    // Get the current voice profile's pitch and speed values
    final voiceProfiles = _ttsService.voiceProfiles;
    if (voiceProfiles.containsKey(_selectedVoiceProfile)) {
      setState(() {
        _pitchValue = voiceProfiles[_selectedVoiceProfile]!['pitch'] ?? 1.0;
        _speedValue = voiceProfiles[_selectedVoiceProfile]!['speed'] ?? 1.0;
      });
    }
  }

  void _onVoiceProfileChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedVoiceProfile = value;
        _updateSliderValues();
      });
    }
  }

  Future<void> _updateVoiceProfile() async {
    await _ttsService.updateVoiceProfile(
      _selectedVoiceProfile,
      pitch: _pitchValue,
      speed: _speedValue,
    );
    
    // Play a sample to demonstrate the changes
    _ttsService.speak(
      'This is how I sound with the new settings.',
      context: _selectedVoiceProfile,
    );
  }

  Future<void> _initializeRecorder() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        // Recorder is ready
      }
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording.m4a';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _loadCustomVoices() async {
    final directory = await getApplicationDocumentsDirectory();
    final voicesDir = Directory('${directory.path}/custom_voices');
    if (!await voicesDir.exists()) {
      await voicesDir.create(recursive: true);
    }

    final voiceFiles = await voicesDir.list().toList();
    setState(() {
      for (var file in voiceFiles) {
        if (file is File && file.path.endsWith('.wav')) {
          final name = file.path.split('/').last.replaceAll('.wav', '');
          _customVoices[name] = {
            'path': file.path,
            'name': name,
            'type': 'custom',
          };
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voice Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBg,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildVoiceProfileSection(),
            const SizedBox(height: 24),
            _buildVoiceTypeSection(),
            const SizedBox(height: 24),
            _buildRecordingSection(),
            const SizedBox(height: 24),
            _buildCustomVoicesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Profile Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customize the pitch and speed for each voice profile',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Voice profile dropdown
            DropdownButtonFormField<String>(
              value: _selectedVoiceProfile,
              decoration: InputDecoration(
                labelText: 'Voice Profile',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.lightBg,
              ),
              items: _voiceProfileNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: _onVoiceProfileChanged,
            ),
            
            const SizedBox(height: 24),
            
            // Pitch slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pitch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    Text(
                      _pitchValue.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _pitchValue,
                  min: 0.5,
                  max: 2.0,
                  divisions: 30,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary.withAlpha(50),
                  onChanged: (value) {
                    setState(() {
                      _pitchValue = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Lower', style: TextStyle(fontSize: 12)),
                    Text('Higher', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Speed slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Speed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    Text(
                      _speedValue.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _speedValue,
                  min: 0.5,
                  max: 2.0,
                  divisions: 30,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary.withAlpha(50),
                  onChanged: (value) {
                    setState(() {
                      _speedValue = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Slower', style: TextStyle(fontSize: 12)),
                    Text('Faster', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Test and save buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _ttsService.speak(
                        'This is a test of the current voice settings.',
                        context: _selectedVoiceProfile,
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Voice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withAlpha(50),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateVoiceProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Streaming demo
            const Text(
              'Audio Streaming Demo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test the streaming functionality with a longer text',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _demonstrateStreaming,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Play Long Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _demonstrateStreaming() {
    final longText = '''
    Welcome to the audio streaming demonstration. This feature allows the app to process and play longer texts by breaking them into smaller chunks and streaming them sequentially. This approach ensures that even lengthy explanations can be delivered smoothly without delays.
    
    The streaming functionality is particularly useful for educational content, where detailed explanations might be necessary. For example, when explaining mathematical concepts, historical events, or scientific processes, the app can now provide comprehensive information without being limited by text length.
    
    Each voice profile can be customized with different pitch and speed settings, allowing you to create the perfect voice for different subjects. The math teacher voice might speak more slowly and clearly, while the memory coach might be more energetic and engaging.
    
    Thank you for testing this feature. We hope it enhances your learning experience with our application.
    ''';
    
    _ttsService.speak(longText, context: _selectedVoiceProfile);
  }

  Widget _buildVoiceTypeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose the type of voice you want to use for the app',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            _buildVoiceOption(
              'Default Voice',
              'Standard voice provided by the system',
              Icons.record_voice_over,
              true,
            ),
            _buildVoiceOption(
              'Custom Voice',
              'Use your own recorded voice',
              Icons.mic,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceOption(
    String title,
    String description,
    IconData icon,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withAlpha(20)
            : AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withAlpha(30)
                : Colors.grey.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Radio<bool>(
          value: true,
          groupValue: isSelected,
          onChanged: (value) {
            // Handle voice selection
          },
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Your Voice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Record your own voice to be used as the teacher\'s voice',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: _isRecording
                  ? _buildRecordingIndicator()
                  : _buildStartRecordingButton(),
            ),
            if (_recordingPath.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildRecordingPreview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartRecordingButton() {
    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(30),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(40),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start Recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(100),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.mic,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Recording...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _stopRecording,
          icon: const Icon(Icons.stop),
          label: const Text('Stop Recording'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recording Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.audio_file,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voice Recording',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _recordingPath.split('/').last,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: AppColors.primary,
                  size: 36,
                ),
                onPressed: () {
                  // Implement audio playback
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _voiceNameController,
            decoration: InputDecoration(
              hintText: 'Enter a name for this voice',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Save voice recording
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Voice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomVoicesSection() {
    if (_customVoices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Custom Voices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 16),
            ..._customVoices.entries.map((entry) {
              final voice = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.record_voice_over,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          Text(
                            'Custom Voice',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        // Play voice
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // Delete voice
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _voiceNameController.dispose();
    super.dispose();
  }
} 