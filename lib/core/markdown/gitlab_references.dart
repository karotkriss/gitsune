import 'package:markdown/markdown.dart' as md;

/// The kinds of GitLab references Gitsune resolves in markdown text.
enum GitLabReferenceType { issue, mergeRequest, user, label }

const _sigils = {
  GitLabReferenceType.issue: '#',
  GitLabReferenceType.mergeRequest: '!',
  GitLabReferenceType.user: '@',
  GitLabReferenceType.label: '~',
};

/// Inline syntaxes required to resolve GitLab references without creating
/// nested links inside authored markdown links.
List<md.InlineSyntax> gitLabReferenceSyntaxes() => [
  GitLabReferenceSyntax(),
  _GitLabLinkSyntax(),
];

/// A resolved GitLab text reference: `#123`, `!456`, `@user`, or `~label`.
///
/// Text-level resolution only; looking the target up against an instance is
/// the repository layer's job later.
class GitLabReference {
  const GitLabReference(this.type, this.target);

  /// The target without its sigil: the issue/MR iid, username, or label name.
  final String target;
  final GitLabReferenceType type;

  /// The literal reference text, e.g. `#123`.
  String get text => '${_sigils[type]}$target';

  /// The internal href this reference is encoded as inside rendered markdown,
  /// so tap handling can round-trip it back to a typed reference.
  String get href => '$_scheme:${type.name}/${Uri.encodeComponent(target)}';

  static const _scheme = 'gitsune-ref';

  /// Decodes an [href] produced by [GitLabReference.href]; null for any other
  /// link.
  static GitLabReference? fromHref(String? href) {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || uri.scheme != _scheme) return null;
    final segments = uri.pathSegments;
    if (segments.length != 2) return null;
    for (final type in GitLabReferenceType.values) {
      if (type.name == segments.first) {
        return GitLabReference(type, segments.last);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is GitLabReference && other.type == type && other.target == target;

  @override
  int get hashCode => Object.hash(type, target);

  @override
  String toString() => 'GitLabReference(${type.name}, $target)';
}

/// Inline markdown syntax that turns GitLab references into links carrying a
/// [GitLabReference.href].
///
/// Running as an inline syntax means code spans and code blocks are excluded
/// for free: block-level code is never inline-parsed, and the code-span
/// syntax consumes backtick spans before this syntax sees their contents.
/// Backslash escapes (`\#123`) likewise stay literal because the escape
/// syntax consumes the sigil.
class GitLabReferenceSyntax extends md.InlineSyntax {
  GitLabReferenceSyntax() : super(_pattern);

  // A reference must not touch a word character on its left (so `abc#123` and
  // `a@b.com` stay plain text). Issue/MR iids are digits not followed by more
  // word characters; usernames and labels are word characters with interior
  // `.` `-` allowed but not trailing (so `thanks @user.` drops the period).
  // ponytail: no quoted (`~"multi word"`) or scoped (`~a::b`) labels yet; add
  // alternates here when a real project's labels need them.
  static const _name = '[A-Za-z0-9_](?:[A-Za-z0-9_.-]*[A-Za-z0-9_])?';
  static const _pattern =
      '(?<![A-Za-z0-9_])'
      '(?!~$_name::)'
      '(?:[#!](\\d+)(?![A-Za-z0-9_])|[@~]($_name))';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final sigil = match[0]![0];
    final type = _sigils.entries.firstWhere((e) => e.value == sigil).key;
    final ref = GitLabReference(type, match[1] ?? match[2]!);
    parser.addNode(
      md.Element.text('a', ref.text)..attributes['href'] = ref.href,
    );
    return true;
  }
}

class _GitLabLinkSyntax extends md.LinkSyntax {
  @override
  md.Node createNode(
    String destination,
    String? title, {
    required List<md.Node> Function() getChildren,
  }) => super.createNode(
    destination,
    title,
    getChildren: () {
      final children = getChildren();
      _replaceReferencesWithText(children);
      return children;
    },
  );
}

void _replaceReferencesWithText(List<md.Node> nodes) {
  for (var index = 0; index < nodes.length; index++) {
    final node = nodes[index];
    if (node is! md.Element) continue;
    if (GitLabReference.fromHref(node.attributes['href']) != null) {
      nodes[index] = md.Text(node.textContent);
    } else if (node.children != null) {
      _replaceReferencesWithText(node.children!);
    }
  }
}
