# That warning usually means the databases were deleted from MySQL/MariaDB, but Plesk still has stale references to them in its internal configuration or backup metadata.

# The backup process is trying to back up databases that no longer exist, so MySQL returns:

# * `1049 Unknown database 'fcz_db'`
# * `1049 Unknown database 'fcz_pantheon'`

# Most commonly this happens when:

# * a domain/subscription was deleted incompletely,
# * databases were removed manually or out of order,
# * or a previous backup task still references old objects.

# Try these steps in order.

# ---

# ## 1. Resync Plesk database registry

# SSH into the server as root and run:

# ```bash
plesk repair db -n
# ```

# Then:

# ```bash
plesk repair fs -n
# ```

# If the preview looks fine, run the actual repair:

# ```bash
plesk repair db
plesk repair fs
# ```

# This often removes orphaned database references.

# ---

# ## 2. Check whether Plesk still thinks the DBs exist

# Run:

# ```bash
# plesk db "select name from data_bases where name in ('fcz_db','fcz_pantheon');"
# ```

# If rows are returned, Plesk still has them registered internally.

# ---

# ## 3. Remove orphaned entries manually (safe method)

# First list the database IDs:

# ```bash
plesk db "select id,name from data_bases where name in ('fcz_db','fcz_pantheon');"
# ```

# Then remove them using Plesk utilities if available:

# ```bash
plesk bin database --remove fcz_db
plesk bin database --remove fcz_pantheon
# ```

# If Plesk says they do not exist but backup still complains, the issue is usually stale backup task metadata.

# ---

# ## 4. Clear old backup session metadata

# Delete failed incremental backup references:

# ```bash
rm -rf /var/lib/psa/dumps/*
# ```

# Or only remove problematic temporary sessions:

# ```bash
find /var/lib/psa/dumps/ -type d -mtime +7
# ```

# Be careful not to delete backups you still need.

# ---

# ## 5. Rebuild backup configuration

# Restart Plesk services:

# ```bash
systemctl restart psa
systemctl restart sw-cp-server
# ```

# Then run a new manual backup.

# ---

# ## 6. Also check scheduled backup targets

# Sometimes the scheduled backup is attached to a removed subscription.

# List subscriptions:

# ```bash
plesk bin subscription -l
# ```

# And inspect scheduled tasks in:

# * Plesk → Tools & Settings → Backup Manager
# * Scheduled Backups

# Look for references to old domains/subscriptions.

# ---

# ## 7. Verify directly in MySQL

# You can confirm the databases are truly gone:

# ```bash
mysql -e "SHOW DATABASES LIKE 'fcz_%';"
# ```

# If nothing appears, the issue is definitely stale Plesk metadata rather than actual databases.

# ---

# The most likely fix is:

# ```bash
plesk repair db
# ```

# followed by removing stale entries from the `data_bases` table references.
