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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base (Body)
          SvgPicture.asset(
            'assets/avatar/base/${config.gender.name}.svg',
            colorFilter: ColorFilter.mode(config.skinTone, BlendMode.srcIn),
          ),
          
          // 2. Jersey (T-shirt)
          SvgPicture.asset(
            'assets/avatar/jerseys/basic.svg',
            colorFilter: ColorFilter.mode(config.jerseyColor, BlendMode.srcIn),
          ),
          
          // 3. Hair (if not bald)
          if (config.hairStyle != HairStyle.bald)
            SvgPicture.asset(
              'assets/avatar/hair/${config.hairStyle.name}.svg',
              colorFilter: ColorFilter.mode(config.hairColor, BlendMode.srcIn),
            ),
            
          // 4. Beard (if applicable)
          if (config.hasBeard && config.gender == AvatarGender.male)
             SvgPicture.asset(
              'assets/avatar/hair/beard.svg',
              colorFilter: ColorFilter.mode(config.hairColor, BlendMode.srcIn),
            ),
          
          // 5. Helmet
          SvgPicture.asset(
            'assets/avatar/helmets/road.svg',
            colorFilter: ColorFilter.mode(config.helmetColor, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
