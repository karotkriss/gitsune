import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gitlab_references.dart';
import 'package:markdown/markdown.dart' as md;

/// Parses [markdown] the way GsMarkdown does (GFM plus the reference syntax)
/// and returns every GitLab reference that resolved, in document order.
List<GitLabReference> refsIn(String markdown) {
  final doc = md.Document(
    inlineSyntaxes: [GitLabReferenceSyntax()],
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );
  final refs = <GitLabReference>[];
  void walk(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Element) {
        final ref = GitLabReference.fromHref(node.attributes['href']);
        if (ref != null) refs.add(ref);
        walk(node.children ?? const []);
      }
    }
  }

  walk(doc.parse(markdown));
  return refs;
}

const issue123 = GitLabReference(GitLabReferenceType.issue, '123');

void main() {
  test('resolves all four reference types with type and target', () {
    expect(refsIn('Fixes #123 via !456, thanks @dev.user, tagged ~backend'), [
      issue123,
      const GitLabReference(GitLabReferenceType.mergeRequest, '456'),
      const GitLabReference(GitLabReferenceType.user, 'dev.user'),
      const GitLabReference(GitLabReferenceType.label, 'backend'),
    ]);
  });

  test('resolves at start of text and inside brackets', () {
    expect(refsIn('#123'), [issue123]);
    expect(refsIn('(#123)'), [issue123]);
  });

  test('does not resolve when adjacent to word characters', () {
    expect(refsIn('abc#123'), isEmpty);
    expect(refsIn('1#2'), isEmpty);
    expect(refsIn('a_#123'), isEmpty);
    expect(refsIn('#123abc'), isEmpty);
    expect(refsIn('mail a@b.com today'), isEmpty);
  });

  test('stops at punctuation boundaries', () {
    expect(refsIn('see #123.'), [issue123]);
    expect(refsIn('really, #123!'), [issue123]);
    expect(refsIn('ping @user.'), [
      const GitLabReference(GitLabReferenceType.user, 'user'),
    ]);
    expect(refsIn('~bug, and more'), [
      const GitLabReference(GitLabReferenceType.label, 'bug'),
    ]);
  });

  test('does not resolve inside code spans', () {
    expect(refsIn('run `#123` now'), isEmpty);
    expect(refsIn('`@user and !456`'), isEmpty);
  });

  test('does not resolve inside code blocks', () {
    expect(refsIn('```\n#123 @user\n```'), isEmpty);
    expect(refsIn('    #123 in indented code'), isEmpty);
  });

  test('does not resolve backslash-escaped references', () {
    expect(refsIn(r'\#123'), isEmpty);
    expect(refsIn(r'\@user'), isEmpty);
    expect(refsIn(r'\!456 and \~label'), isEmpty);
  });

  test('resolves references outside a code span alongside one inside', () {
    expect(refsIn('#123 but not `#456`'), [issue123]);
  });

  test('reference text and href round-trip', () {
    expect(issue123.text, '#123');
    expect(GitLabReference.fromHref(issue123.href), issue123);
    expect(GitLabReference.fromHref('https://example.com'), isNull);
    expect(GitLabReference.fromHref(null), isNull);
    expect(GitLabReference.fromHref('gitsune-ref:bogus/1'), isNull);
  });
}
