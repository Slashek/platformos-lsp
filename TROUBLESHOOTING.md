# Troubleshooting

## Issues with Language Server

### Language Server Crashing on Startup

The following error can cause Language Server to crash:

**Error Message:**
```bash
Calling `DidYouMean::SPELL_CHECKERS.merge!(error_name => spell_checker)` has been deprecated. Please call `DidYouMean.correct_error(error_name, spell_checker)` instead.
/Users/johndoe/.gem/ruby/3.1.2/gems/bundler-2.2.22/lib/bundler/spec_set.rb:91:in `block in materialize`: Could not find ruby-prof-0.18.0 in any of the sources (Bundler::GemNotFound)
```

**Solution:**
Ensure the `platformos-check` version in the wrapper in `~/bin/platformos-check-language-server` matches the expected Ruby version. If it doesn't match the Ruby version, run the following command from the platformos-check directory:

```bash
chruby 3.1.2  #your `~/bin/platformos-check-language-server` ruby version
bundle install
```

If discrepancies are found, update your environment with the correct version of Ruby and re-install the necessary gems:

### Language Server Initialization Issue

**Symptom:**

The language server sends an `initialize()` request to the client but then stops responding.

**Debugging Steps:**

1. Ensure your local language server startup script includes these steps:
```bash
export PLATFORMOS_CHECK_DEBUG=true
export PLATFORMOS_CHECK_DEBUG_LOG_FILE="/tmp/platformos-check-debug.log"
touch "$PLATFORMOS_CHECK_DEBUG_LOG_FILE"
```

An example script can be found [in the Contributing Guide](/CONTRIBUTING.md#run-language-server).

2. Open the debug log located at `/tmp/platformos-check-debug.log` in your IDE. Check if there are any exceptions being raised by the language server.

3. If no exceptions are found, verify that all logs are properly formatted in JSON-RPC. The language server and client communicate using JSON-RPC over `stdin` and `stdout`. Debugging statements that aren't in a JSON-RPC format might trigger unexpected behavior. This includes any logs from the language server or echo statements in your language server script.
