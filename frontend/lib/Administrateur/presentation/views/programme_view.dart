import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ProgrammeView extends StatefulWidget {
  const ProgrammeView({Key? key}) : super(key: key);

  @override
  State<ProgrammeView> createState() => _ProgrammeViewState();
}

class _ProgrammeViewState extends State<ProgrammeView> {
  // Variables d'état
  File? _selectedFile;
  bool _isUploading = false;
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  Timer? _generationTimer;

  // Données simulées
  final List<GeneratedProgram> _generatedPrograms = [];
  final Map<String, File> _uploadedFiles = {};

  // Monitoring
  bool _monitoringActive = false;

  @override
  void initState() {
    super.initState();
    _startMonitoringSimulation();
  }

  @override
  void dispose() {
    _monitoringActive = false;
    _generationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUploadSection(),
          const SizedBox(height: 20),

          if (_isGenerating) _buildGenerationProgress(),
          const SizedBox(height: 20),

          if (_isGenerating || _generatedPrograms.isNotEmpty)
            _buildGeneratedProgramsSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne gauche : Contenu principal
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildUploadSection(),
                const SizedBox(height: 20),

                if (_isGenerating) _buildGenerationProgress(),
                const SizedBox(height: 20),

                if (_isGenerating || _generatedPrograms.isNotEmpty)
                  _buildGeneratedProgramsSection(),
              ],
            ),
          ),

          // Colonne droite : Panel d'information
          Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildInfoPanel(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION UPLOAD - DESIGN AMÉLIORÉ
  // ============================================

  Widget _buildUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload, color: const Color(0xFF6BA5BD), size: 24),
                const SizedBox(width: 12),
                const Text(
                  "Upload du Programme",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Sélectionnez un fichier PDF contenant les informations du cours.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            if (_isUploading) ...[
              LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6BA5BD)),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Upload en cours...",
                  style: TextStyle(color: Color(0xFF6BA5BD), fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildFileDropZone(),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedFile != null && !_isUploading
                    ? _simulateUploadProcess
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BA5BD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        "ENVOYER À L'IA",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),

            if (_selectedFile != null && !_isUploading) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "ANNULER LA SÉLECTION",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileDropZone() {
  final borderColor =
      _selectedFile != null ? const Color(0xFF6BA5BD) : Colors.grey[300]!;
  final backgroundColor = _selectedFile != null
      ? const Color(0xFF6BA5BD).withOpacity(0.05)
      : Colors.grey[50];

  return GestureDetector(
    onTap: _isUploading ? null : _pickPDFFile,
    child: Container(
      height: 180,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: _selectedFile != null ? 2 : 1,
        ),
      ),
      child: Center(
        child: _selectedFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IMAGE UPLOAD (au lieu de l’icône)
                  Image.asset(
                    'lib/assets/images/upload.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Upload pdf program",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Format accepté : .pdf",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 56,
                    color: const Color(0xFF6BA5BD),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Prêt à être envoyé à l'IA",
                    style: TextStyle(
                      color: Color(0xFF6BA5BD),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}


  // ============================================
  // PROGRESSION DE GÉNÉRATION
  // ============================================

  Widget _buildGenerationProgress() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: const Color(0xFF6BA5BD), size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "IA en action...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${(_generationProgress * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6BA5BD),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _generationProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6BA5BD)),
              borderRadius: BorderRadius.circular(8),
              minHeight: 10,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getGenerationStep(_generationProgress),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  _getEstimatedTime(_generationProgress),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // LISTE DES PROGRAMMES GÉNÉRÉS
  // ============================================

  Widget _buildGeneratedProgramsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, color: const Color(0xFF6BA5BD), size: 24),
                const SizedBox(width: 12),
                const Text(
                  "Programme",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_generatedPrograms.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: _generatedPrograms.map(_buildProgramCard).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(GeneratedProgram program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6BA5BD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: const Color(0xFF6BA5BD),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Généré le ${_formatDateTime(program.generatedAt)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _viewProgramDetails(program),
                icon: Icon(Icons.visibility, color: const Color(0xFF6BA5BD), size: 20),
                tooltip: "Voir les détails",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucun programme généré",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Les programmes générés par l'IA apparaîtront ici",
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
  return Container(
    width: 260,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6BA5BD),
          Color(0xFF8EC3D6),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // IMAGE IA
        Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.15),
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'lib/assets/images/robot.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 20),

        // TEXTE EN BAS (optionnel mais joli)
        const Text(
          "IA EDUFLOW",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Génération intelligente\nde programmes scolaires",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    ),
  );
}


  // ============================================
  // LOGIQUE MÉTIER (inchangée)
  // ============================================

  Future<void> _pickPDFFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          setState(() {
            _selectedFile = File(filePath);
          });
        }
      }
    } catch (e) {
      _showMessage("Erreur de sélection: $e", isError: true);
    }
  }

  Future<void> _simulateUploadProcess() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    await Future.delayed(const Duration(seconds: 2));

    final fileName = _selectedFile!.path.split('/').last;
    _uploadedFiles[fileName] = _selectedFile!;

    _startGenerationProcess(fileName);

    setState(() {
      _isUploading = false;
      _selectedFile = null;
    });

    _showMessage("PDF envoyé à l'IA avec succès !");
  }

  void _startGenerationProcess(String fileName) {
    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    _generationTimer?.cancel();

    const totalSteps = 100;
    int currentStep = 0;

    _generationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      currentStep++;
      setState(() {
        _generationProgress = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        _completeGeneration(fileName);
      }
    });
  }

  void _completeGeneration(String originalFileName) {
    final baseName = originalFileName.replaceAll('.pdf', '');
    final generatedName = 'programme_${baseName}_generated_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final newProgram = GeneratedProgram(
      fileName: generatedName,
      generatedAt: DateTime.now(),
      description: "Programme généré par IA",
    );

    setState(() {
      _generatedPrograms.insert(0, newProgram);
      _isGenerating = false;
      _generationProgress = 0.0;
    });

    _showMessage("✅ Programme généré avec succès !");
  }

  void _startMonitoringSimulation() {
    _monitoringActive = true;

    Future.delayed(const Duration(seconds: 30), () {
      if (_monitoringActive && mounted) {
        _startMonitoringSimulation();
      }
    });
  }

  void _viewProgramDetails(GeneratedProgram program) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Détails du Programme",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Fichier:", program.fileName),
              _buildDetailRow("Date:", _formatDateTime(program.generatedAt)),
              _buildDetailRow("Statut:", "Complété"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showMessage("Téléchargement simulé");
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BA5BD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("TÉLÉCHARGER"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF6BA5BD),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  String _getGenerationStep(double progress) {
    if (progress < 0.3) return "📖 Analyse du PDF...";
    if (progress < 0.6) return "🤖 Traitement par l'IA...";
    if (progress < 0.9) return "✏️ Génération du programme...";
    return "✅ Finalisation...";
  }

  String _getEstimatedTime(double progress) {
    final remaining = ((1 - progress) * 30).toInt();
    return "Environ $remaining secondes";
  }
}

class GeneratedProgram {
  final String fileName;
  final DateTime generatedAt;
  final String? description;

  GeneratedProgram({
    required this.fileName,
    required this.generatedAt,
    this.description,
  });
}