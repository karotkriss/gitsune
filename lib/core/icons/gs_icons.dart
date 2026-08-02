import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pajamas glyphs from GitLab's icon set.
///
/// Path data is copied verbatim from the vendored sprite
/// `design/assets/icons/gitlab-icons.svg` (npm `@gitlab/svgs`, MIT; license
/// text in `design/assets/LICENSE-gitlab-svgs.txt`). To add a glyph, copy the
/// `<path d="...">` of the matching `<symbol>` from that sprite; every glyph
/// draws on a 16x16 grid.
enum GsIconGlyph {
  home(
    'M8.38 1.353L8 1.131l-.38.222-7.25 4.25a.75.75 0 0 0 .76 1.294l.87-.51V14h12'
    'V6.387l.87.51a.75.75 0 1 0 .76-1.294l-7.25-4.25zm4.12 4.154L8 2.87 3.5 5.50'
    '7V12.5H6V8h4v4.5h2.5V5.507zM8.5 9.5v3h-1v-3h1z',
  ),
  todoDone(
    'M3 13.5a.5.5 0 0 1-.5-.5V3a.5.5 0 0 1 .5-.5h9.25a.75.75 0 0 0 0-1.5H3a2 2 '
    '0 0 0-2 2v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V9.75a.75.75 0 0 0-1.5 0V13a.5.'
    '5 0 0 1-.5.5H3zm12.78-8.82a.75.75 0 0 0-1.06-1.06L9.162 9.177 7.289 7.241a'
    '.75.75 0 1 0-1.078 1.043l2.403 2.484a.75.75 0 0 0 1.07.01L15.78 4.68z',
  ),
  compass(
    'M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 '
    '1 16 0zM7.186 5.605L12 4l-1.605 4.814a2.5 2.5 0 0 1-1.58 1.581L4 12l1.605-'
    '4.814a2.5 2.5 0 0 1 1.58-1.581zM9 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0z',
  ),
  user(
    'M10.5 5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zm.514 2.63a4 4 0 1 0-6.028 0A4'
    '.002 4.002 0 0 0 2 11.5V13a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-1.5a4.002 4.002 '
    '0 0 0-2.986-3.87zM8 9H6a2.5 2.5 0 0 0-2.5 2.5V13a.5.5 0 0 0 .5.5h8a.5.5 0 '
    '0 0 .5-.5v-1.5A2.5 2.5 0 0 0 10 9H8z',
  );

  const GsIconGlyph(this.path);

  /// SVG path data on the sprite's 16x16 grid.
  final String path;
}

/// Renders a Pajamas [GsIconGlyph] at [size], tinted [color].
///
/// Defaults to the ambient [IconTheme] color, so it picks up
/// selected/unselected tinting inside Material components (for example
/// [NavigationBar] destinations) exactly like a font [Icon] would.
class GsIcon extends StatelessWidget {
  const GsIcon(this.glyph, {super.key, this.size = 24, this.color});

  final GsIconGlyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">'
      '<path fill-rule="evenodd" clip-rule="evenodd" d="${glyph.path}"/>'
      '</svg>',
      width: size,
      height: size,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
