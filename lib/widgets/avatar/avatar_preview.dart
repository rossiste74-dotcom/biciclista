import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/user_avatar_config.dart';

class AvatarPreview extends StatelessWidget {
  final UserAvatarConfig config;
  final double size;

  const AvatarPreview({
    super.key,
    required this.config,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (config.customImageUrl != null && config.customImageUrl!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Image.network(
            config.customImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image, size: size * 0.5, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base (Body)
          SvgPicture.asset(
            'assets/avatar/base/male.svg',
            colorFilter: ColorFilter.mode(config.skinTone, BlendMode.srcIn),
          ),



          
          // 2. Jersey Layers (Stack of 3)
          // Layer 1: Base Body
          SvgPicture.asset(
            'assets/avatar/jerseys/jersey_layer_1.svg',
            colorFilter: ColorFilter.mode(config.jerseyColor, BlendMode.srcIn),
          ),
          // Layer 2: Main Pattern
          SvgPicture.asset(
            'assets/avatar/jerseys/jersey_layer_2.svg',
            colorFilter: ColorFilter.mode(config.jerseyColor2, BlendMode.srcIn),
          ),
          // Layer 3: Secondary Details
          SvgPicture.asset(
            'assets/avatar/jerseys/jersey_layer_3.svg',
            colorFilter: ColorFilter.mode(config.jerseyColor3, BlendMode.srcIn),
          ),



          
          // 3. Hair (if not bald)
          if (config.hairStyle != HairStyle.bald)
            SvgPicture.asset(
              'assets/avatar/hair/${config.hairStyle.name}.svg',
              colorFilter: ColorFilter.mode(config.hairColor, BlendMode.srcIn),
            ),
            
          // 4. Beard (if applicable)
          if (config.hasBeard)
             SvgPicture.asset(
              'assets/avatar/hair/beard.svg',
              colorFilter: ColorFilter.mode(config.hairColor, BlendMode.srcIn),
            ),

          // 5. Glasses (if applicable)
          if (config.hasGlasses)
            SvgPicture.asset(
              'assets/avatar/glasses/sunglasses.svg',
              // No color filter for glasses usually, or maybe black/tinted. 
              // The SVG itself is black filled, so let's leave it as is or tint it if needed.
              // For now, let's keep it simple as per original SVG color (black).
            ),

          
          // 5. Helmet
          SvgPicture.asset(
            'assets/avatar/helmets/road.svg',
            colorFilter: ColorFilter.mode(config.helmetColor, BlendMode.srcIn),
          ),

          // 1.5. Face Features (Nose/Mouth - Always Visible)
          // Moved here to be ON TOP of everything (including Helmet)
          SvgPicture.asset(
            'assets/avatar/base/face_features.svg',
          ),



        ],
      ),
    );
  }
}
