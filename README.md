# bundler-diff

Sometimes you have a git pull request that also modifies a bunch of gem versions.
Code reviewing then becomes tricky. Should you code review all the gem changes as well?
How deep should you go?

bundler-diff examines a git diff file for `Gemfile.lock` changes.
It delegates to [gem-compare](https://github.com/fedora-ruby/gem-compare) for a "deeper" diff.

# Usage

If you are making changes in a local git repo, use [git-diff](https://git-scm.com/docs/git-diff):

    git diff > my-local-changes.diff

If you are using GitHub, open a pull request in your favorite browser and save resulting page locally:

    http://github.com/<org>/<repo>/pull/<pr>.diff

Run bundler-diff on your diff file:

    ruby ./bundler-diff.rb --file <diff-file>

Inject your favorite gem server:

    GEM_COMPARE_SOURCES='<GEM_SERVER_URL>' ruby ./bundler-diff.rb --file <diff-file>

Pass on parameters to gem compare:

    ruby ./bundler-diff.rb --file <diff-file> -- --files
