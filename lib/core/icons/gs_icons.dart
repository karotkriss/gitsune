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
  issueOpen(
    'M8 14.5a6.5 6.5 0 1 0 0-13 6.5 6.5 0 0 0 0 13zM8 16A8 8 0 1 0 8 0a8 8 '
    '0 0 0 0 16z',
  ),
  issueClosed(
    'M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 '
    '0 0 1 16 0zM3.75 7.25a.75.75 0 0 0 0 1.5h8.5a.75.75 0 0 0 0-1.5h-8.5z',
  ),
  milestone(
    'M8.354 2.664a.5.5 0 0 0-.708 0L2.664 7.646a.5.5 0 0 0 0 .708l4.982 4.982a.5.'
    '5 0 0 0 .708 0l4.982-4.982a.5.5 0 0 0 0-.708L8.354 2.664zm-1.768-1.06a2 2 0 0 '
    '1 2.828 0l4.982 4.982a2 2 0 0 1 0 2.828l-4.982 4.982a2 2 0 0 1-2.828 0L1.604 '
    '9.414a2 2 0 0 1 0-2.828l4.982-4.982z',
  ),
  assignee(
    'M4 6.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM7 5a2.99 2.99 0 0 1-.87 2.113A3.'
    '997 3.997 0 0 1 8 10.5V12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-1.5c0-1.427.747-2.'
    '679 1.87-3.387A3 3 0 1 1 7 5zm-5.5 5.5a2.5 2.5 0 0 1 5 0V12a.5.5 0 0 1-.5.5H2a.'
    '5.5 0 0 1-.5-.5v-1.5zM13 10a.75.75 0 0 1-.75-.75v-1.5h-1.5a.75.75 0 0 1 0-1.5h1.'
    '5v-1.5a.75.75 0 0 1 1.5 0v1.5h1.5a.75.75 0 0 1 0 1.5h-1.5v1.5A.75.75 0 0 1 13 '
    '10z',
  ),
  comments(
    'M2 0a2 2 0 0 0-2 2v10.06l1.28-1.28 1.53-1.53H4V11a2 2 0 0 0 2 2h7l1.5 1.5L16 '
    '16V6a2 2 0 0 0-2-2h-2V2a2 2 0 0 0-2-2H2zm8.5 4V2a.5.5 0 0 0-.5-.5H2a.5.5 0 0 '
    '0-.5.5v6.44l.47-.47.22-.22H4V6a2 2 0 0 1 2-2h4.5zm3.56 7.94l.44.439V6a.5.5 0 0 '
    '0-.5-.5H6a.5.5 0 0 0-.5.5v5a.5.5 0 0 0 .5.5h7.621l.44.44z',
  ),
  chevronLeft(
    'M10.78 2.22a.75.75 0 0 0-1.06 0L4.468 7.472a.75.75 0 0 0 0 1.06l5.252 5.252a.75.'
    '75 0 1 0 1.06-1.06L6.06 8.001l4.72-4.721a.75.75 0 0 0 0-1.06z',
  ),
  chevronRight(
    'M5.22 2.22a.75.75 0 0 1 1.06 0l5.252 5.252a.75.75 0 0 1 0 1.06L6.28 13.784a.75.'
    '75 0 1 1-1.06-1.06l4.72-4.723L5.22 3.28a.75.75 0 0 1 0-1.06z',
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
