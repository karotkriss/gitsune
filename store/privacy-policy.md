# Gitsune privacy policy

Both Google Play and the App Store require a public privacy policy URL; this document is the policy to publish at that URL.

## The short version

Gitsune runs entirely on your device.
It talks only to the GitLab instance you sign into, and it sends nothing to the people who make Gitsune - there is nothing to send it to, because the project operates no servers.

## What Gitsune stores, and where

- **Sign-in tokens.** When you sign in, GitLab issues OAuth tokens (or you provide a Personal Access Token). These are stored in your device's platform secure storage: the Android Keystore on Android, the Keychain on iOS. They are used only to authenticate your requests to that instance.
- **Cached GitLab content.** Issues, merge requests, pipelines, to-dos, and comment drafts you have viewed or written are cached in a local database on your device so they stay readable offline. The cache is scoped per account and is deleted when you remove the account in Gitsune or uninstall the app.
- **Settings.** Preferences such as quiet hours and the biometric app-lock toggle are stored locally.

## Where Gitsune sends data

- **Your GitLab instance.** All app traffic goes to the instance you signed into (gitlab.com or your own self-hosted host), over HTTPS, to do what you asked the app to do.
- **A push relay, only if you set one up.** Notifications work out of the box by checking your instance's to-do list and never involve any third party. If you opt in to faster delivery, you connect a relay you own or choose (your own ntfy server via UnifiedPush on Android, or a service such as ntfy or Pushover). Gitsune generates the GitLab webhook configuration for you; the messages flow from your GitLab instance to your chosen relay to your device, and never through any Gitsune infrastructure.

## What Gitsune does not do

- No analytics, telemetry, usage statistics, or crash reporting.
- No advertising and no tracking of any kind.
- No project-operated servers: nobody involved in making Gitsune can see your GitLab activity, notifications, or tokens.
- No biometric data access: the optional app lock asks the operating system to verify you; Gitsune only learns whether the check passed.

## Deleting your data

Remove an account in Gitsune to delete every token and cached row for it, or uninstall the app to delete everything.
No copy exists anywhere else, so there is nothing further to request deletion of.

## Changes and contact

Changes to this policy are made by updating this document in the Gitsune source repository, where its history is public.
Questions can be raised as issues on the project repository.
