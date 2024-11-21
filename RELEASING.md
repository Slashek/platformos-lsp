## Releasing platformOS Check

Follow these steps to release a new version of platformOS Check:

1. **Versioning**: Refer to the [Semantic Versioning page](http://semver.org) to determine the appropriate version number for the new release based on the changes made.

2. **Update Version**: Update the version number in the `lib/platformos_check/version.rb` file. Also, replace the `PLATFORMOS_CHECK_VERSION` placeholder in the documentation for any new rules.
Use the following command to automate these updates:

   ```bash
   VERSION="X.X.X"
   rake prerelease[$VERSION]
   ```

3. **Update Changelog**: Use the [`git changelog` command](https://github.com/tj/git-extras) to automatically update the `CHANGELOG.md` with the latest commit descriptions.
   ```bash
   git changelog
   ```

4. **Commit and Prepare PR**: Commit the changes and prepare a pull request for review.

   ```bash
   git checkout -b "bump/platformos-check-$VERSION"
   git add docs/checks CHANGELOG.md lib/platformos_check/version.rb
   git commit -m "Bump platformos-check version to $VERSION"
   hub compare "main:bump/platformos-check-$VERSION"
   ```

5. **Merge PR**: After review, merge your pull request into the main branch.

6. **Create GitHub Release**: [Create a GitHub release](https://github.com/Platform-OS/platformos-lsp/releases/new) for the change using the updated version tag.


   ```
   VERSION=v1.X.Y
   git fetch origin
   git fetch origin --tags
   git reset origin $VERSION
   gh release create -t $VERSION
   ```

⚠️ **Note:** Incorporate relevant parts of the CHANGELOG into the release notes to provide context on the changes.
