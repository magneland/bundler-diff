# bundler-diff

Examines a GitHub pull request for Gemfile.lock changes.

# Usage

Open a GitHub pull request in your favorite browser:

http://github.com/<org>/<repo>/pull/<pr>.diff

Save diff file locally.

Run bundler-diff on your diff file:

    ruby ./bundler-diff.rb --file <diff-file>

Inject your favorite gem server:

    GEM_COMPARE_SOURCES='<GEM_SERVER_URL>' ruby ./bundler-diff.rb --file <diff-file>

Pass on parameters to gem compare:

    ruby ./bundler-diff.rb --file <diff-file> -- --files
