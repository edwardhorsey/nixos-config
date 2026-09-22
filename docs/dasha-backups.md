# Dasha Backups

Dasha creates a daily Restic backup of its mutable application state. Services
are stopped one at a time while their state is copied to local staging, then
restarted before Restic writes the snapshot to the NAS.

## Schedule

| Task | Schedule |
| --- | --- |
| Backup and prune | Daily at 02:00, with up to 15 minutes random delay |
| Repository check | Sunday at 04:00, with up to 30 minutes random delay |
| Full restore test | First day of each month at 05:00, with up to 30 minutes random delay |

Restic keeps 14 daily, 8 weekly, and 12 monthly snapshots. TrueNAS snapshots
and the existing off-site replication protect the repository independently.
The restore test fails if the newest tagged Dasha snapshot is over 48 hours
old, so a valid but stale repository cannot report as healthy indefinitely.

The backup includes:

- Syncthing identity, configuration, and index
- Uptime Kuma state
- Beszel hub state
- FreshRSS state and user databases
- Baikal configuration and data
- Gitea configuration, repositories, attachments, and database

## Operations

Inspect the timers and latest service logs:

```bash
systemctl list-timers 'restic-*' 'dasha-backup-*'
journalctl -u restic-backups-dasha.service
journalctl -u restic-backups-dasha-check.service
journalctl -u dasha-backup-restore-test.service
```

Run each operation manually:

```bash
sudo systemctl start restic-backups-dasha.service
sudo systemctl start restic-backups-dasha-check.service
sudo systemctl start dasha-backup-restore-test.service
```

List available snapshots:

```bash
sudo restic-dasha snapshots
```

Restore a snapshot to an empty temporary directory:

```bash
sudo mkdir -p /var/lib/dasha-manual-restore
sudo restic-dasha restore latest --target /var/lib/dasha-manual-restore
```

Do not restore files over live application state. Stop the affected service,
restore into a separate directory, verify the data and ownership, and only then
replace the live state. Keep the restored application isolated from public
network access until its integrity has been checked.

## Rollout

Keep the existing Baikal ZIP backup until all of these have succeeded:

1. The first Restic backup.
2. The weekly repository check run manually.
3. The monthly restore-test service run manually.
4. A TrueNAS snapshot and off-site copy containing the Restic repository.

Afterward, remove the old Baikal backup service and timer in a separate change.
