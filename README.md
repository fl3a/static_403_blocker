# static_403_blocker

Block unwanted scanner and crawler traffic on static websites 
by pre-creating forbidden files and directories with restrictive permissions.

This script helps reduce 404 log noise 
and proactively denies access to known attack vectors 
such as `.env`, `/wp-login.php`, or `/vendor/` — without relying on `.htaccess` 
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

## Example `blocklist.txt`

```
# Common scan targets
.env
wp-login.php
composer.lock
license.txt

# Directories
vendor/
wp-admin/
wp-content/
.git/
```

## Usage

Make sure the script is executable and your environment is set:

  chmod +x static_403_blocker.sh
  ./static_403_blocker.sh

Adjust variables inside the script as needed:

- `WEBROOT` – the absolute path to your website root
- `BLOCKLIST` – the file containing the list of paths to block

## Example integration

Example execution in a [Jekyll deployment](
https://github.com/fl3a/jekyll_deployment) via [post_exec task](
https://github.com/fl3a/florian.latzel.io/blob/a05e016e82dd336e1c7fc2ea6b63a9e1d4e4e45b/deploy.conf#L51) 

    post_exec="/home/kdoz/bin/static_403_blocker.sh"

## Notes

- Requires standard Unix tools: `stat`, `mkdir`, `touch` and `chmod`.
- Safe to run multiple times – it skips existing files and directories
- Adds no .htaccess or rewrite complexity

## Tip

To unblock a file or directory, simply delete it from the webroot.
