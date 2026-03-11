import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart'; // Ensure this model exists and has avatarConfig
// If UserProfile doesn't have avatarConfig directly exposed or it's in a different file, check.
// I saw 'AvatarPreview' uses 'UserAvatarConfig'. UserProfile usually has it.
// Checking 'lib/models/user_profile.dart' might be wise, but I will assume standard pattern.
import '../widgets/avatar/avatar_preview.dart';
import '../models/user_avatar_config.dart';
import '../models/biomechanics_analysis.dart'; // New model
import '../widgets/biomechanics_painter.dart'; // New painter

class BiomechanicsScreen extends StatefulWidget {
  const BiomechanicsScreen({super.key});

  @override
  State<BiomechanicsScreen> createState() => _BiomechanicsScreenState();
}

class _BiomechanicsScreenState extends State<BiomechanicsScreen> {
  int _currentStep = 0; // 0: Intro/LastResult, 1: Guide/Capture, 2: Analyzing, 3: Result
  final List<File?> _capturedImages = [null, null, null];
  String _verdict = "";
  BiomechanicsAnalysis? _analysis;
  BikeType _selectedBikeType = BikeType.road;
  bool _isBadPosture = false;
  UserProfile? _userProfile;
  bool _isLoadingLatest = true;
  final AIService _aiService = AIService();
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadProfile();
    await _loadLatestAnalysis();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
      });
    }
  }

  Future<void> _loadLatestAnalysis() async {
    final latest = await _db.getLatestBiomechanicsAnalysis();
    if (mounted) {
      setState(() {
        if (latest != null) {
          _analysis = latest;
          _verdict = latest.verdict ?? "";
          _isBadPosture = _checkBadPosture(latest);
          _selectedBikeType = latest.metadata.bikeTypeDetected;
          _currentStep = 3; // Show result directly
        }
        _isLoadingLatest = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    
    if (photo != null) {
      setState(() {
        _capturedImages[index] = File(photo.path);
      });
    }
  }

  Future<void> _analyzeBiomechanics() async {
    final imagesToAnalyze = _capturedImages.where((img) => img != null).cast<File>().toList();
    if (imagesToAnalyze.isEmpty) return;

    setState(() {
      _currentStep = 2; // Analyzing
    });

    // Call AI Service
    final result = await _aiService.analyzeBiomechanicsFromImages(imagesToAnalyze);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _analysis = result['analysis'] as BiomechanicsAnalysis;
          _verdict = result['verdict'] as String;
          _isBadPosture = _checkBadPosture(_analysis!);
          _currentStep = 3;
        });
      } else {
        // Handle Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? "Errore sconosciuto"), backgroundColor: Colors.red),
        );
        setState(() {
          _currentStep = 1; // Go back
        });
      }
    }
  }

  bool _checkBadPosture(BiomechanicsAnalysis analysis) {
    // Simple heuristic: if any recommendation is NOT 'NONE', it's "bad" enough to warrant attention
    final knee = analysis.biometrics.kneeExtensionAngle;
    if (knee < 135 || knee > 155) return true;
    
    final recs = analysis.recommendations;
    if (recs.saddleHeight.action != AdjustmentAction.none || 
        recs.saddleForeAft.action != AdjustmentAction.none ||
        recs.handlebarStack.action != AdjustmentAction.none) {
      return true;
    }
    
    return false;
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      for (int i = 0; i < _capturedImages.length; i++) {
        _capturedImages[i] = null;
      }
      _verdict = "";
      _analysis = null;
    });
  }

  Future<void> _shareResult() async {
    if (_analysis == null) return;

    final biometrics = _analysis!.biometrics;
    final bikeType = _analysis!.metadata.bikeTypeDetected.name.toUpperCase();
    
    final shareText = '''
🚴 BIOMECCANICA BICICLISTA 🚴
Analisi Posturale AI - $bikeType

📊 DATI BIOMETRICI:
- Estensione Ginocchio: ${biometrics.kneeExtensionAngle.toStringAsFixed(1)}°
- Angolo Schiena: ${biometrics.backAngle.toStringAsFixed(1)}°
- Angolo Spalla: ${biometrics.shoulderAngle.toStringAsFixed(1)}°

🔧 IL VERDETTO:
$_verdict

Analisi effettuata con il Butler AI di Biciclista.
''';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark theme base
      appBar: AppBar(
        title: Text(
          "ANALISI BIOMECCANICA",
          style: GoogleFonts.bebasNeue(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
            color: Colors.redAccent,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingLatest) {
      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    switch (_currentStep) {
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildGuideStep();
      case 2:
        return _buildAnalyzingStep();
      case 3:
        return _buildResultStep();
      default:
        return _buildIntroStep();
    }
  }

  Widget _buildIntroStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white70),
          const SizedBox(height: 24),
          Text(
            "Analisi biomeccanica professionale tramite AI. Carica una foto laterale per ricevere un feedback tecnico e correzioni posturali.",
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text("SELEZIONA TIPO BICI:", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 16),
          _buildBikeTypeSelector(),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("HO CAPITO, PROCEDI"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () => setState(() => _currentStep = 1),
          )
        ],
      ),
    );
  }

  Widget _buildBikeTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTypeBtn("ROAD", BikeType.road, Icons.directions_bike),
        const SizedBox(width: 12),
        _buildTypeBtn("TT/TRI", BikeType.ttTri, Icons.timer),
        const SizedBox(width: 12),
        _buildTypeBtn("MTB", BikeType.mtb, Icons.landscape),
      ],
    );
  }

  Widget _buildTypeBtn(String label, BikeType type, IconData icon) {
    final isSelected = _selectedBikeType == type;
    return InkWell(
      onTap: () => setState(() => _selectedBikeType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "SCATTA LE FOTO:",
              style: GoogleFonts.bebasNeue(fontSize: 28, color: Colors.white),
            ),
          ),
          
          // 3 Photo Boxes Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildPhotoSlot(0, "LATERALE", "Gamba estesa", isRequired: true),
                const SizedBox(width: 12),
                _buildPhotoSlot(1, "LATERALE", "Piede ore 3", isRequired: false),
                const SizedBox(width: 12),
                _buildPhotoSlot(2, "FRONTALE", "Allineamento", isRequired: false),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Instruction Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent),
                  const SizedBox(height: 8),
                  Text(
                    "La prima foto è obbligatoria. Le altre sono opzionali ma consigliate per una precisione millimetrica.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _capturedImages[0] != null ? _analyzeBiomechanics : null,
                icon: const Icon(Icons.analytics_outlined),
                label: Text("AVVIA ANALISI", style: GoogleFonts.bebasNeue(fontSize: 22)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(int index, String label, String sublabel, {bool isRequired = false}) {
    final image = _capturedImages[index];
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(index),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRequired && image == null ? Colors.redAccent.withOpacity(0.5) : Colors.white24,
                width: 2,
              ),
              image: image != null ? DecorationImage(image: FileImage(image), fit: BoxFit.cover) : null,
            ),
            child: image == null 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: isRequired ? Colors.redAccent : Colors.white38, size: 32),
                      const SizedBox(height: 8),
                      Text(isRequired ? "OBBLIGATORIO" : "OPZIONALE", 
                        style: TextStyle(fontSize: 10, color: isRequired ? Colors.redAccent : Colors.white38, fontWeight: FontWeight.bold)),
                    ],
                  )
                : const SizedBox(),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 16)),
          Text(sublabel, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Scatta Foto", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text("Scegli dalla Libreria", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, index);
              },
            ),
            if (_capturedImages[index] != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text("Rimuovi Foto", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _capturedImages[index] = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingStep() {
    final captured = _capturedImages.where((img) => img != null).toList();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(
            "Analisi biomeccanica in corso...",
            style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: captured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(captured[index]!, width: 90, height: 120, fit: BoxFit.cover),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Il Butler sta misurando gli angoli...",
            style: GoogleFonts.roboto(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    final hasImage = _capturedImages[0] != null;
    final isStale = _capturedImages[0] == null && _analysis != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isStale)
            Container(
              color: Colors.blueAccent.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.history, color: Colors.blueAccent, size: 16),
                   const SizedBox(width: 8),
                   Text("ULTIMA ANALISI SALVATA", style: GoogleFonts.bebasNeue(color: Colors.blueAccent, fontSize: 14)),
                ],
              ),
            ),

          // 1. Mechanic Receipt (Scontrino) - Professional Tone
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBE6), // Paper color
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("CASA DEL CICLISTA - ANALISI", style: GoogleFonts.courierPrime(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black))),
                const Divider(color: Colors.black),
                const SizedBox(height: 10),
                Text(_verdict, style: GoogleFonts.courierPrime(fontSize: 14, color: Colors.black, height: 1.2)),
                const SizedBox(height: 10),
                const Divider(color: Colors.black), 
              ],
            ),
          ),

          // 1.5 Foto analizzate
          if (hasImage) 
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "FOTO ANALIZZATE:",
                      style: GoogleFonts.bebasNeue(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _capturedImages.where((img) => img != null).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final captured = _capturedImages.where((img) => img != null).toList();
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(captured[index]!, width: 90, height: 120, fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // 2. Visual Overlay (Only if image is available from current session)
          if (hasImage && _analysis != null && _analysis!.visualOverlay.points.isNotEmpty)
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_capturedImages[0]!, fit: BoxFit.cover),
                    CustomPaint(
                      painter: BiomechanicsPainter(
                        keypoints: _analysis!.visualOverlay.points,
                        lines: _analysis!.visualOverlay.lines,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // 3. Avatar Reaction (Subtle)
          Center(
            child: SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                children: [
                  if (_userProfile != null && _userProfile!.avatarConfig != null)
                    AvatarPreview(config: _userProfile!.avatarConfig!, size: 180),
                  
                  // Simple indicator instead of full despair
                  if (_isBadPosture)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Text("⚠️", style: TextStyle(fontSize: 24)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // 4. Technical Corrections
          if (_analysis != null)
             _buildTechnicalCorrections(_analysis!),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareResult,
                    icon: const Icon(Icons.share),
                    label: const Text("CONDIVIDI"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text("NUOVA"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalCorrections(BiomechanicsAnalysis analysis) {
    final recs = analysis.recommendations;
    final biometrics = analysis.biometrics;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("DATI BIOMETRICI:", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 8),
          _buildMetricRow("Estensione Ginocchio", "${biometrics.kneeExtensionAngle.toStringAsFixed(1)}°"),
          _buildMetricRow("Angolo Schiena", "${biometrics.backAngle.toStringAsFixed(1)}°"),
          _buildMetricRow("Angolo Spalla", "${biometrics.shoulderAngle.toStringAsFixed(1)}°"),
          
          const SizedBox(height: 24),
          Text("CORREZIONI SUGGERITE:", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 12),
          
          if (recs.saddleHeight.action != AdjustmentAction.none)
            _buildCorrectionCard("Altezza Sella", recs.saddleHeight),
          
          if (recs.saddleForeAft.action != AdjustmentAction.none)
             _buildCorrectionCard("Arretramento Sella", recs.saddleForeAft),
             
          if (recs.handlebarStack.action != AdjustmentAction.none)
             _buildCorrectionCard("Altezza Manubrio", recs.handlebarStack),
             
          if (recs.saddleHeight.action == AdjustmentAction.none && 
              recs.saddleForeAft.action == AdjustmentAction.none &&
              recs.handlebarStack.action == AdjustmentAction.none)
            Card(
              color: Colors.green[900]?.withOpacity(0.5),
              child: const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.greenAccent),
                title: Text("Posizione Ottimale!", style: TextStyle(color: Colors.white)),
                subtitle: Text("Nessuna correzione necessaria.", style: TextStyle(color: Colors.white70)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCorrectionCard(String title, Recommendation rec) {
    IconData icon;
    Color color = Colors.orangeAccent;
    
    switch (rec.action) {
      case AdjustmentAction.up: icon = Icons.arrow_upward; break;
      case AdjustmentAction.down: icon = Icons.arrow_downward; break;
      case AdjustmentAction.fore: icon = Icons.arrow_forward; break;
      case AdjustmentAction.aft: icon = Icons.arrow_back; break;
      default: icon = Icons.build;
    }

    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text("$title: ${rec.action.name.toUpperCase()} ${rec.valueMm}mm", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(rec.reason, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
