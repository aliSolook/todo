import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/utils/functions.dart';
import 'package:shimmer/shimmer.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    this.category,
    this.width = 130,
    this.height = 163,
    this.onTap,
    this.isSelected,
    this.notSelectedScale = .95,
    this.normalScale = 1,
    this.selectedScale = 1.1,
    this.maxDim = .2,
    this.minDim = 0,
    this.opacityMultiplier = 2,
    this.selectedOffset = const Offset(0, -10),
  });

  final double opacityMultiplier;
  final Category? category;
  final double width;
  final double height;
  final void Function()? onTap;
  final bool? isSelected;
  final double notSelectedScale;
  final double normalScale;
  final double selectedScale;
  final double maxDim;
  final double minDim;
  final Offset selectedOffset;

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      return AnimatedScale(
        duration: animationDuration,
        alignment: Alignment.bottomCenter,
        scale: isSelected == null
            ? normalScale
            : isSelected!
            ? selectedScale
            : notSelectedScale,
        child: TweenAnimationBuilder(
          builder: (_, value, child) =>
              Transform.translate(offset: value, child: child),
          duration: animationDuration,
          tween: Tween<Offset>(
            end: isSelected == true ? selectedOffset : Offset.zero,
          ),
          child: TweenAnimationBuilder(
            builder: (_, value, child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).surface,
                  borderRadius: const BorderRadiusGeometry.all(
                    Radius.circular(20),
                  ),
                  image: category!.image == null
                      ? null
                      : DecorationImage(
                          image: CustomImageProvider(
                            imageId: category!.image,
                            repository: RepositoryProvider.of(context),
                          ),
                          fit: BoxFit.cover,
                        ),
                  boxShadow: categoryShadowBuilder(
                    category!.color < 0
                        ? ColorScheme.of(context).shadow
                        : Color(category!.color),
                    strength: isSelected == null || isSelected! ? 1 : 0,
                    opacityMultiplier: opacityMultiplier,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(
                      255 * value ~/ 1,
                    ),
                    borderRadius: const BorderRadiusGeometry.all(
                      Radius.circular(20),
                    ),
                  ),
                  position: DecorationPosition.foreground,
                  child: child,
                ),
              );
            },
            duration: animationDuration,
            tween: Tween<double>(end: isSelected == false ? maxDim : minDim),
            child: SizedBox(
              width: width,
              height: height,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  backgroundBuilder: category!.image != null
                      ? null
                      : (context, states, child) => Stack(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/image_icon.svg',
                              colorFilter: ColorFilter.mode(
                                ColorScheme.of(context).onSurfaceVariant,
                                BlendMode.srcIn,
                              ),
                              width: double.infinity,
                            ),
                            if (child != null) child,
                          ],
                        ),
                  disabledBackgroundColor: Colors.transparent,
                  overlayColor: Color(category!.color).computeLuminance() < 0.5
                      ? Colors.white
                      : Colors.black,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 15,
                      start: 15,
                      bottom: 15,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surfaceContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(9999),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 2,
                          ),
                          child: Text(
                            category!.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorScheme.of(context).onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: const BorderRadiusGeometry.all(Radius.circular(20)),
          child: ColoredBox(
            color: ColorScheme.of(context).surfaceContainer,
            child: Shimmer.fromColors(
              baseColor: ColorScheme.of(context).onSurfaceVariant,
              highlightColor: ColorScheme.of(context).surfaceContainer,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadiusGeometry.all(
                    Radius.circular(20),
                  ),
                  border: BoxBorder.all(
                    width: 2,
                    color: ColorScheme.of(context).surface,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(horizontalPadding),
                        child: SvgPicture.asset(
                          'assets/icons/image_icon.svg',
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: 15,
                        start: 15,
                        bottom: 15,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ColorScheme.of(context).surfaceContainer,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(9999),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 7),
                            child: Text(
                              'placeholder',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
