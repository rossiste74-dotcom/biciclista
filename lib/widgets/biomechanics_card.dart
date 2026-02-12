import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/biomechanics_screen.dart';

class BiomechanicsCard extends StatelessWidget {
  const BiomechanicsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFF212121), // Dark grey
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BiomechanicsScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.accessibility_new, size: 28, color: Colors.orangeAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ANALISI BIOMECCANICA",
                      style: GoogleFonts.bebasNeue(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Analisi posturale professionale con AI.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
