#!/opt/homebrew/bin/fish

function usage
    echo "Usage: "(status basename)" [--backup] [--delete] [--dry-run] [--verbose]"
    echo "Copies contents of repo .config/nvim to ~/.config/nvim"
end

argparse --name=copy_ghq_to_config 'h/help' 'b/backup' 'D/delete' 'n/dry-run' 'v/verbose' -- $argv
or begin
    usage
    exit 2
end

if set -q _flag_help
    usage
    exit 0
end

set -l dest_dir "$HOME/.config/nvim"
set -l src_dir (realpath (dirname (status -f)))

# 安全チェック
if test ! -d "$src_dir"
    echo "Source dir not found: $src_dir"
    exit 1
end

mkdir -p "$dest_dir"
set -l dest_real (realpath "$dest_dir")
set -l src_real "$src_dir"

if test "$src_real" = "$dest_real"
    echo "Source and destination are the same. Abort."
    exit 1
end

# バックアップ
if set -q _flag_backup
    if test -d "$dest_real"
        set -l ts (date "+%Y%m%d-%H%M%S")
        set -l backup_dir "$HOME/.config/nvim.backups/nvim-$ts"
        mkdir -p "$backup_dir"
        echo "Backing up $dest_real -> $backup_dir"
        rsync -a --exclude ".git/" "$dest_real/" "$backup_dir/"
        or begin
            echo "Backup failed."
            exit 1
        end
    end
end

# rsync オプション
set -l rsync_opts -a
if set -q _flag_verbose
    set rsync_opts $rsync_opts -v
end
if set -q _flag_dry_run
    set rsync_opts $rsync_opts -n
end
if set -q _flag_delete
    set rsync_opts $rsync_opts --delete
end

# コピー（中身のみ: 末尾スラッシュ）
echo "Sync: $src_real/ -> $dest_real/"
rsync $rsync_opts \
    --exclude ".git/" \
    "$src_real/" "$dest_real/"
set -l status_code $status

if test $status_code -eq 0
    echo "Done."
else
    echo "Failed with status $status_code"
end

exit $status_code