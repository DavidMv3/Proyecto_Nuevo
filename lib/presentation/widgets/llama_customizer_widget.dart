import 'package:flutter/material.dart';

class LlamaCustomizerWidget extends StatefulWidget {
  const LlamaCustomizerWidget({super.key});

  @override
  State<LlamaCustomizerWidget> createState() => _LlamaCustomizerWidgetState();
}

class _LlamaCustomizerWidgetState extends State<LlamaCustomizerWidget> {
  // Estado de equipamiento para los diferentes objetos
  bool isPonchoEquipped = false;
  bool isGlovesEquipped = false;
  bool isAmuletEquipped = false;
  bool isOshasEquipped = false;

  void togglePoncho() => setState(() => isPonchoEquipped = !isPonchoEquipped);
  void toggleGloves() => setState(() => isGlovesEquipped = !isGlovesEquipped);
  void toggleAmulet() => setState(() => isAmuletEquipped = !isAmuletEquipped);
  void toggleOshas() => setState(() => isOshasEquipped = !isOshasEquipped);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // CONTENEDOR VISUAL - EL STACK MÁGICO
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Capa Base: La Llama al natural (Siempre visible)
                Image.asset(
                  'assets/llama_base.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text('Llama\nBase', textAlign: TextAlign.center),
                      ),
                    );
                  },
                ),

                // Capa 1: Oshas Chaski (Patas traseras)
                _buildAnimatedLayer(
                  isEquipped: isOshasEquipped,
                  assetPath: 'assets/oshas.png', 
                ),

                // Capa 2: Poncho de Lana (Cuerpo)
                _buildAnimatedLayer(
                  isEquipped: isPonchoEquipped,
                  assetPath: 'assets/poncho.png',
                ),

                // Capa 3: Amuleto de Suerte (Cuello)
                _buildAnimatedLayer(
                  isEquipped: isAmuletEquipped,
                  assetPath: 'assets/amuleto.png',
                ),

                // Capa 4: Guantes de Alpaca (Patas delanteras)
                _buildAnimatedLayer(
                  isEquipped: isGlovesEquipped,
                  assetPath: 'assets/guantes.png',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // SECCIÓN INFERIOR - CONTROLES
        Wrap(
          spacing: 12,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildToggleChip("Poncho de Lana", isPonchoEquipped, togglePoncho),
            _buildToggleChip("Guantes de Alpaca", isGlovesEquipped, toggleGloves),
            _buildToggleChip("Amuleto de Suerte", isAmuletEquipped, toggleAmulet),
            _buildToggleChip("Oshas Chaski", isOshasEquipped, toggleOshas),
          ],
        ),
      ],
    );
  }

  // Helper para construir la capa animada con la prenda
  Widget _buildAnimatedLayer({
    required bool isEquipped,
    required String assetPath,
  }) {
    return AnimatedScale(
      // Si no está equipado agigantamos un poco y lo encogemos a escala 1 al equiparlo
      scale: isEquipped ? 1.0 : 1.2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack, // Efecto rebote que da la sensación de "aterrizar"
      child: AnimatedOpacity(
        opacity: isEquipped ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        // La opacidad usa easeInOut porque valores menores a 0 o mayores a 1 (que da easeOutBack) podrían ser problemáticos
        curve: Curves.easeInOut, 
        child: Image.asset(
          assetPath,
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Un placeholder rojo por si falta el asset (útil durante el desarrollo)
            return Container(); 
          },
        ),
      ),
    );
  }

  // Helper para construir los "Chips" interactivos
  Widget _buildToggleChip(String label, bool isEquipped, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isEquipped ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEquipped ? Colors.deepOrange : Colors.grey.shade400,
            width: 1,
          ),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isEquipped
                  ? const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: Icon(Icons.check, color: Colors.white, size: 18),
                    )
                  : const SizedBox(width: 0),
            ),
            Text(
              label,
              style: TextStyle(
                color: isEquipped ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
