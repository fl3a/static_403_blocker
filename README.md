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

Place it within your `$PATH` or call it directly with `WEBROOT` as parameter.\
Where `WEBROOT` is the absolute path to your website root.\

E.g.:
    
    static_403_blocker.sh $HOME/florian.latzel.io

Adjust `BLOCKLIST` variables inside the script as needed.\
Where `BLOCKLIST` is the file containing the list of paths to block

## Example integration

Example execution in a [Jekyll deployment](
https://github.com/fl3a/jekyll_deployment) via [post_exec task](
https://github.com/fl3a/florian.latzel.io/blob/e766c92f939a1ce7106af8fe8481ba9a476857d6/deploy.conf#L51) 
for [florian.latzel.io](https://florian.latzel.io/).

    post_exec="/home/kdoz/bin/static_403_blocker.sh $www"

## Contribute

**Want to help make the blocklist better?**

Follow these steps to identify unwanted traffic, clean up your data, and submit your changes via pull request.

**1. Check your webserver logs for 404s (Not Found).**\
The command expects Apache logs in Combined Log Format (or vCombined). Update paths and parsing if necessary.\
It will output the number of hits per URL:

```
grep ' 404 ' /`path/to/apache-logs \
  | cut -d'"' -f2 \
  | awk '{print $2}' \
  | sort \
  | uniq -c \
  | sort -nr \
  > /path/to/404-count.txt
```


**2. Review your 404s *carefully* and remove URLs that actually exist on your website.**\
(You may add them to your .htaccess instead.)\
This ensures that only scanning attempts remain.

**3. Remove the hit counts and leading `/`.**

Vim:

    :%s/^\s*\d\+\s\+\/\+\(.*\)$/\1/

Shell:

    sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+\/+(.+)$/\1/' /path/to/404-count.txt

**4. Add new scans to `blocklist.txt`:**
  
```
cat /path/to/404-count.txt >> /path/to/blocklist.txt
```
   
**5. Sort and remove duplicates:**

Vim:

```   
vi /path/to/blocklist.txt
```

```
:sort u
```

Shell:

    sort -u /path/to/blocklist.txt -o /path/to/blocklist.txt

**6. Add and commit `blocklist.txt`**    

**7. Create a pull request to share your updates.**

## Notes

- Requires standard Unix tools: `stat`, `mkdir`, `touch` and `chmod`.
- Safe to run multiple times – it skips existing files and directories
- Adds no .htaccess or rewrite complexity

## Tip

To unblock a file or directory, simply delete it from the webroot.
