Hi collaborator!

If you have a fix or a new feature, please start by checking in the
[issues](https://github.com/pixelastic/html-hierarchy-extractor/issues) if it is
already referenced. If not, feel free to open one.

We use [pull requests](https://github.com/pixelastic/html-hierarchy-extractor/pulls)
for collaboration. The workflow is as follow:

- Create a local branch, starting from `develop`
- Submit the PR on `develop`
- Wait for review
- Do the changes requested (if any)
- We may ask you to rebase the branch to latest `develop` if it gets out of sync
- Get praise for your awesome contribution

# Development workflow

Run `bundle install` to get all dependencies up to date.

You can then launch:

- `./scripts/test` to launch tests
- `./scripts/watch` to start a test watcher (for TDD) using Guard

If you plan on submitting a PR, I suggest you install the git hooks. This will
run pre-commit and pre-push checks. Those checks will also be run by TravisCI,
but running them locally gives faster feedback.

If you want to a local version of the gem in your local project, I suggest
updating your project `Gemfile` to point to the correct local directory

```ruby
gem "html-hierarchy-extractor", :path => "/path/to/local/gem/folder"
```

You should also run `rake gemspec` from the `html-hierarchy-extractor`
repository the first time and if you added/deleted any file or dependency.

# Tagging and releasing

This part is for main contributors:

```
# Bump the version (in develop)
./scripts/bump_version minor

# Update master and release
./scripts/release

# Install the gem locally (optional)
rake install
```
