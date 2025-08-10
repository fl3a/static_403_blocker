# static_403_blocker

Block unwanted scanner and crawler traffic on static websites 
by pre-creating forbidden files and directories with restrictive permissions.

The `blocklist.txt` is a living document: it grows continuously 
as recurring unwanted requests are identified in server logs.  
The version included in this repository is kept up to date, 
reflecting the current protection rules in active use.

This script helps reduce 404 log noise 
and proactively denies access to known attack vectors 
such as `.env`, `/wp-login.php`, or `/vendor/` without relying on `.htaccess` 
or runtime processing.

## Motivation

On static web hosts like Uberspace or minimal Nginx setups, 
handling scan attempts via `.htaccess` 
or server configuration may not be viable. 

This script offers a robust alternative:

- Stop noisy or malicious requests from filling up your 404 logs
- Use the filesystem itself to return `403 Forbidden` on access attempts
- Avoid duplicate configuration in `.htaccess` or webserver rules
- Rerunnable: safe to use on every deployment

## How it works

- Reads paths from a `blocklist.txt` file
- For each listed file or directory:
  - Creates it in the `$WEBROOT`
  - Applies `000` permissions to prevent access
- As a result, the server returns HTTP `403 Forbidden` for each path

Directories can be marked with a trailing `/`, e.g. `vendor/`, 
and the script automatically distinguishes them from files.

## `blocklist.txt`

Below are example entries from the current `blocklist.txt`.  
This list keeps expanding over time, as new patterns are detected and added during routine log analysis.

### Example `blocklist.txt`

```
# Common probe targets
.env
wp-login.php
composer.lock
license.txt

# Directories often scanned
vendor/
wp-admin/
wp-content/
.git/

# Legacy or historical paths
old/
backup/
backup.zip
index.old.html

# Custom crawler traps
secret-panel/
admin-console/
login.php
```

## Usage

Make the script is executable:

    chmod +x static_403_blocker.sh

Place it within your `$PATH` or call it directly:
    
    ./static_403_blocker.sh

Adjust variables inside the script as needed:

- `WEBROOT` – the absolute path to your website root
- `BLOCKLIST` – the file containing the list of paths to block

## Example integration

Example execution in a [Jekyll deployment](
https://github.com/fl3a/jekyll_deployment) via [post_exec task](
https://github.com/fl3a/florian.latzel.io/blob/e766c92f939a1ce7106af8fe8481ba9a476857d6/deploy.conf#L51) 
for [florian.latzel.io](https://florian.latzel.io/).

    post_exec="/home/kdoz/bin/static_403_blocker.sh"

## Notes

- Requires standard Unix tools: `stat`, `mkdir`, `touch` and `chmod`.
- Safe to run multiple times – it skips existing files and directories
- Adds no .htaccess or rewrite complexity

## Tip

To unblock a file or directory, simply delete it from the webroot.
