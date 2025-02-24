import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../services/tts_service.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final _record = Record();
  bool _isRecording = false;
  String? _currentRecordingPath;
  final TextEditingController _voiceNameController = TextEditingController();
  final Map<String, Map<String, dynamic>> _customVoices = {};
  String _selectedVoice = 'default';
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadCustomVoices();
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

  Future<void> _startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final voicesDir = Directory('${directory.path}/custom_voices');
        if (!await voicesDir.exists()) {
          await voicesDir.create(recursive: true);
        }
        
        _currentRecordingPath = '${voicesDir.path}/temp_recording.wav';
        
        await _record.start(
          path: _currentRecordingPath,
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          samplingRate: 44100,
        );

        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _record.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        _showSaveVoiceDialog();
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _showSaveVoiceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Custom Voice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _voiceNameController,
              decoration: const InputDecoration(
                labelText: 'Voice Name',
                hintText: 'Enter a name for this voice',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Record a sample phrase to help identify this voice later.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _discardRecording();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveVoice();
              Navigator.pop(context);
            },
            child: const Text('Save Voice'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVoice() async {
    if (_currentRecordingPath != null && _voiceNameController.text.isNotEmpty) {
      final voiceName = _voiceNameController.text;
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/custom_voices/$voiceName.wav';
      
      await File(_currentRecordingPath!).copy(newPath);
      await File(_currentRecordingPath!).delete();

      setState(() {
        _customVoices[voiceName] = {
          'path': newPath,
          'name': voiceName,
          'type': 'custom',
        };
        _voiceNameController.clear();
        _currentRecordingPath = null;
      });

      // Update TTS service with new voice
      final tts = TTSService();
      await tts.addCustomVoice(voiceName, newPath);
    }
  }

  Future<void> _discardRecording() async {
    if (_currentRecordingPath != null) {
      await File(_currentRecordingPath!).delete();
      setState(() {
        _currentRecordingPath = null;
        _voiceNameController.clear();
      });
    }
  }

  Future<void> _deleteVoice(String voiceName) async {
    try {
      final voiceData = _customVoices[voiceName];
      if (voiceData != null) {
        await File(voiceData['path']).delete();
        setState(() {
          _customVoices.remove(voiceName);
        });

        // Remove voice from TTS service
        final tts = TTSService();
        await tts.removeCustomVoice(voiceName);
      }
    } catch (e) {
      debugPrint('Error deleting voice: $e');
    }
  }

  Future<void> _previewVoice(String voiceName) async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    final tts = TTSService();
    await tts.speak(
      'Hello, I am your AI teacher!',
      context: voiceName,
    );

    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDefaultVoices(),
          const Divider(height: 32),
          _buildCustomVoices(),
          const SizedBox(height: 16),
          _buildRecordingSection(),
        ],
      ),
    );
  }

  Widget _buildDefaultVoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Default Voices',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildVoiceOption(
                'Cheerful Teacher',
                'default',
                'A friendly and encouraging voice',
                Icons.face_retouching_natural,
              ),
              _buildVoiceOption(
                'Math Expert',
                'math',
                'Clear and precise mathematical explanations',
                Icons.functions,
              ),
              _buildVoiceOption(
                'Language Guide',
                'language',
                'Patient and articulate pronunciation',
                Icons.language,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomVoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Voices',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_customVoices.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No custom voices added yet. Record your own voice using the button below.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: _customVoices.entries.map((entry) {
                return _buildVoiceOption(
                  entry.value['name'],
                  entry.key,
                  'Custom recorded voice',
                  Icons.record_voice_over,
                  isCustom: true,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceOption(
    String title,
    String value,
    String description,
    IconData icon, {
    bool isCustom = false,
  }) {
    final isSelected = _selectedVoice == value;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.2),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.stop : Icons.play_arrow,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => _previewVoice(value),
          ),
          if (isCustom)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteVoice(value),
            ),
          Radio<String>(
            value: value,
            groupValue: _selectedVoice,
            onChanged: (value) async {
              if (value != null) {
                setState(() {
                  _selectedVoice = value;
                });
                final tts = TTSService();
                await tts.setVoice(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record New Voice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Record your own voice to personalize the learning experience.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _stopRecording(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRecording ? 'Recording...' : 'Hold to Record',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _record.dispose();
    _voiceNameController.dispose();
    super.dispose();
  }
} 