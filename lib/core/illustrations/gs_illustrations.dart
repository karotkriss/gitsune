import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pajamas empty-state illustrations from GitLab's open-source set.
///
/// Markup is copied byte-verbatim from `design/assets/illustrations/` (npm
/// `@gitlab/svgs`, MIT; license text in
/// `design/assets/LICENSE-gitlab-svgs.txt`); official assets are never
/// redrawn. The upstream files color themselves with CSS
/// `var(--gl-illustration-*)` tokens, which flutter_svg cannot resolve, so
/// [GsIllustration] substitutes the dark-theme token values at render time.
enum GsIllustrationArt {
  /// `empty-todos-all-done-md.svg` - the To-Do List with every box checked.
  emptyTodosAllDone(
    '<svg width="144" height="144" fill="none" viewBox="0 0 144 144" xmln'
    's="http://www.w3.org/2000/svg"><rect width="144" height="144" rx="72'
    '" fill="var(--gl-illustration-base-fill-color, #e7e4f2ff)"></rect><p'
    'ath d="M85 117a26.998 26.998 0 0027-27" stroke="var(--gl-illustratio'
    'n-stroke-color-default, #171321ff)" stroke-width="var(--gl-illustrat'
    'ion-stroke-width-default, 2)" stroke-linecap="square"></path><path d'
    '="M53 46.08h-9V107h42l9-9H53V46.08z" fill="var(--gl-illustration-acc'
    'ent-fill-color-subtle, #d0c5e2ff)"></path><path d="M53 46h-9v61h39.4'
    '86a6 6 0 004.277-1.793L89 103.95" stroke="var(--gl-illustration-stro'
    'ke-color-default, #171321ff)" stroke-width="var(--gl-illustration-st'
    'roke-width-default, 2)" stroke-linecap="square"></path><path d="M53 '
    '37h35l12 11v42a8 8 0 01-8 8H53V37z" fill="var(--gl-illustration-fill'
    '-color-default, #ffffff)"></path><path d="M88 37H53v61h39a8 8 0 008-'
    '8V55.5M88 37v11h12v-.5L88 37z" stroke="var(--gl-illustration-stroke-'
    'color-default, #171321ff)" stroke-width="var(--gl-illustration-strok'
    'e-width-default, 2)" stroke-linecap="square"></path><path d="M124.12'
    '3 14.604a1 1 0 011.754 0l2.518 4.604c.092.167.23.305.398.397l4.603 2'
    '.518a1 1 0 010 1.754l-4.603 2.518c-.168.092-.306.23-.398.398l-2.518 '
    '4.603a1 1 0 01-1.754 0l-2.518-4.604a1.001 1.001 0 00-.398-.397l-4.60'
    '3-2.518a1 1 0 010-1.754l4.603-2.518c.168-.092.306-.23.398-.398l2.518'
    '-4.603zm-106 94a1 1 0 011.754 0l3.225 5.896c.092.168.23.306.398.398l'
    '5.896 3.225a1 1 0 010 1.754l-5.896 3.225c-.168.092-.306.23-.398.398l'
    '-3.225 5.896a1 1 0 01-1.754 0l-3.225-5.896a1.001 1.001 0 00-.398-.39'
    '8l-5.896-3.225a1 1 0 010-1.754l5.896-3.225c.168-.092.306-.23.398-.39'
    '8l3.225-5.896zm18.438 20.198a.5.5 0 01.878 0l1.966 3.595a.492.492 0 '
    '00.198.198l3.595 1.966a.5.5 0 010 .878l-3.595 1.966a.492.492 0 00-.1'
    '98.198l-1.966 3.595a.5.5 0 01-.878 0l-1.966-3.595a.492.492 0 00-.198'
    '-.198l-3.595-1.966a.5.5 0 010-.878l3.595-1.966a.492.492 0 00.198-.19'
    '8l1.966-3.595z" fill="var(--gl-illustration-fill-color-default, #fff'
    'fff)" stroke="var(--gl-illustration-stroke-color-default, #171321ff)'
    '" stroke-width="var(--gl-illustration-stroke-width-default, 2)"></pa'
    'th><path d="M75 84h10m-10-4h16M75 70h8m-8-4h16M75 56h15m-15-4h7" str'
    'oke="var(--gl-illustration-stroke-color-default, #171321ff)" stroke-'
    'width="var(--gl-illustration-stroke-width-default, 2)" stroke-lineca'
    'p="square"></path><path d="M61 58v-8h8v8h-8zm0 14v-8h8v8h-8zm0 14v-8'
    'h8v8h-8z" fill="var(--gl-illustration-accent-fill-color-teal, #6fdac'
    '9ff)" stroke="var(--gl-illustration-stroke-color-default, #171321ff)'
    '" stroke-width="var(--gl-illustration-stroke-width-default, 2)" stro'
    'ke-linecap="square"></path></svg>',
  );

  const GsIllustrationArt(this.markup);

  final String markup;
}

/// Dark `--gl-illustration-*` values from
/// `design/vendor/gitlab-tokens.dark.css` (dark-only v1, ADR 0008).
const _darkIllustrationTokens = {
  '--gl-illustration-base-fill-color': '#32303c',
  '--gl-illustration-stroke-color-default': '#e3e3e8',
  '--gl-illustration-stroke-width-default': '1.5',
  '--gl-illustration-fill-color-default': '#423f4f',
  '--gl-illustration-accent-fill-color-subtle': '#5c5371',
  '--gl-illustration-accent-fill-color-teal': '#3b8581',
  '--gl-illustration-accent-stroke-color-strong': '#aea5d6',
};

final _cssVar = RegExp(r'var\((--[\w-]+),[^)]*\)');

/// Renders a [GsIllustrationArt] at its native 144x144 unless [size] is given.
class GsIllustration extends StatelessWidget {
  const GsIllustration(this.art, {super.key, this.size = 144});

  final GsIllustrationArt art;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      art.markup.replaceAllMapped(
        _cssVar,
        (match) => _darkIllustrationTokens[match[1]]!,
      ),
      width: size,
      height: size,
    );
  }
}
