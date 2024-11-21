# Contributing to platformOS Check

We appreciate and welcome all contributions!

## Standards

* Checks should do one thing, and do it well.
* PR should explain what the feature does, and why the change exists.
* PR should include any carrier specific documentation explaining how it works.
* Code _must_ be tested.
* Be consistent. Write clean code that follows the [Ruby community standards](https://github.com/bbatsov/ruby-style-guide).
* Code should be generic and reusable.

## How to Contribute

Follow these steps to contribute to the project:

1. **Fork the Repository**: Start by forking the project repository to your GitHub account. Click here to fork: [platformos-check fork](https://github.com/Platform-OS/platformos-check/fork).
2. **Create a Feature Branch**: Create a branch for your new feature:
   ```bash
   git checkout -b my-new-feature
   ```
3. **Commit Changes**: Commit your changes to your branch:
   ```bash
   git commit -am 'Add some feature'
   ```
4. **Push to GitHub**: Push your changes to your GitHub repository:
   ```bash
   git push origin my-new-feature
   ```
5. **Submit a Pull Request**: Go to the original project repository and submit a pull request from your feature branch.

## Run Language Server

If you're making changes to the language server and you want to debug, you can run the repo's version of `platformos-check-language-server`.

### Setup

Before configuring your IDE, run the following commands in a terminal:

  * Make sure you have a `$HOME/bin`
      ```bash
      mkdir -p $HOME/bin
      ```
  * Paste this script to create an executable wrapper in `$HOME/bin/platformos-check-language-server` for language server
      ```bash
      cat <<-'EOF' > $HOME/bin/platformos-check-language-server
      #!/usr/bin/env bash
      cd "$HOME/src/github.com/Platform-OS/platformos-lsp" &> /dev/null
      export PLATFORMOS_CHECK_DEBUG=true
      export PLATFORMOS_CHECK_DEBUG_LOG_FILE="/tmp/platformos-check-debug.log"
      touch "$PLATFORMOS_CHECK_DEBUG_LOG_FILE"
      gem env &>/dev/null
      bundle install &>/dev/null
      bin/platformos-check-language-server
      EOF
      ```
  * Make the script executable
      ```bash
      chmod u+x $HOME/bin/platformos-check-language-server
      ```

#### Configure VS Code

1. Download provided `.vsix` file.
2. Install it manually via View -> Extensions -> ... -> Install from VSIX.
3. Configure `settings.json`:

```
"platformosCheck.checkOnChange": true,
"platformosCheck.onlySingleFileChecks": true,
"platformosLiquid.languageServerPath": "/Users/<your user>/bin/platformos-check-language-server",
"platformosCheck.checkOnOpen": true,
"platformosCheck.checkOnSave": true
```

#### Configure Vim

If you use `coc.nvim` as your completion engine, add this to your CocConfig:

```json
{
  "languageserver": {
    "platformos-check": {
      "command": "/Users/<YOUR_USERNAME>/bin/platformos-check-language-server",
      "trace.server": "verbose",
      "filetypes": ["liquid", "graphql", "yaml", "yml"],
      "rootPatterns": [".platformos-check.yml", ".pos"],
      "settings": {
        "platformosCheck": {
          "checkOnSave": true,
          "checkEnter": true,
          "onlySingleFileChecks": true,
          "checkOnChange": true,
          "checkOnOpen": true
        }
      }
    }
  }
}

```

### Confirm Setup

* From the root of platformos-check, run `tail -f /tmp/platformos-check-debug.log` in another terminal to watch the server logs.
* Restart your IDE, confirm the response for initialization in the logs is pointing to the language server in the `$HOME/bin` directory (the version will be different).

```json
    "serverInfo": {
        "name": "/Users/johndoe/bin/platformos-check-language-server",
        "version": "1.10.3"
    }
```


## Running Tests

```
bundle install
bundle exec rake
```

## Checking a pOS app

```
bin/platformos-check /path/to/your/app
```

## Creating a new "Check"

Run `bundle exec rake "new_check[MyNewCheckName]"` to generate all the files required to create a new check.

Check the [Check API](/docs/api/check.md) for how to implement a check. Also, take a look at other checks in [lib/platformos_check/checks](/lib/platformos_check/checks).

When you're done implementing your check, add it to `config/default.yml` to enable it:

```yaml
MyNewCheckName:
  enabled: true
  ignore: []
```

If the check is configurable, the `initialize` argument names and default values should also be duplicated inside `config/default.yml`. 

For example:

```ruby
class MyCheckName < LiquidCheck
  def initialize(muffin_mode: true)
    @muffin_mode = muffin_mode
  end
  # ...
end
```

```yaml
MyNewCheckName:
  enabled: true
  ignore: []
  muffin_mode: true
```

## Debugging

When the `PLATFORMOS_CHECK_DEBUG` environment variable is set, several features are enabled:

1. The check timeout is disabled. This allows you to use `binding.pry` in tests and debug with `bundle exec rake tests:in_memory`.
2. The `--profile` flag appears. You can now create Flamegraphs to inspect performance.

```
export PLATFORMOS_CHECK_DEBUG=true

# The following will behave slightly differently
bin/platformos-check ../dawn
bundle exec rake tests:in_memory

# The following becomes available
bin/platformos-check --profile ../dawn

# The LanguageServer will log the JSONRPC calls to STDERR
bin/platformos-check-language-server
```

### Profiling

`ruby-prof` and `ruby-prof-flamegraph` are both included as development dependencies.

#### Flamegraph

With the `--profile` flag, you can run platformos-check on your platformOS application and the `ruby-prof-flamegraph` printer will output profiling information in a format [Flamegraph](/brendangregg/FlameGraph) understands.


**Setup:**

```bash
# clone the FlameGraph repo somewhere
git clone https://github.com/brendangregg/FlameGraph.git

# the flamegraph.pl perl script is in that repo
alias flamegraph=/path/to/FlameGraph/flamegraph.pl
```

**Profiling:**

```
# run platformos-check with --profile
# pass the output to flamegraph
# dump the output into an svg file
bin/platformos-check --profile ../dawn \
  | flamegraph --countname=ms --width=1750 \
  > /tmp/fg.svg

# open the svg file in Chrome to look at the flamegraph
chrome /tmp/fg.svg
```

What you'll see is an interactive version of the following image:

![flamegraph](docs/flamegraph.svg)

## Troubleshooting

If you run into issues during development, see the [Troubleshooting Guide](/TROUBLESHOOTING.md).
