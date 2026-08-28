# Usually yes — rsync is designed to resume efficiently.

# If you press `Ctrl+C` during an `rsync` transfer and run the same command again:

# * Files that already finished copying are skipped
# * Partially transferred files are usually resumed or re-sent depending on your options
# * `rsync` compares file size/timestamps (or checksums if requested) and only transfers what’s needed

# For best resume behavior, use:

# ```bash
rsync --partial --progress source/ dest/
# ```

# or the common archive form:

# ```bash
rsync -av --partial --progress source/ dest/
# ```

# Key flags:

# * `--partial` → keeps partially transferred files instead of deleting them on interruption
# * `--progress` → shows transfer progress
# * `-a` → archive mode (preserves permissions, timestamps, etc.)
# * `-v` → verbose

# If you were already using `--partial`, restarting is very efficient because incomplete files continue from the saved partial data.

# Without `--partial`, interrupted files may get deleted and restarted from scratch, though completed files are still skipped.

# For very large files, you can also add:

# ```bash
--append-verify
# ```

# which resumes appending to partially copied files and verifies correctness afterward. Example:

# ```bash
rsync -av --partial --append-verify source/ dest/
# ```

# That’s especially useful for huge backups, VM images, datasets, or media files over unstable connections.

rsync -avz --progress --rsync-path="runuser -u user -- rsync" source/ dest:dest/
