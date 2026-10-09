# Simple Antivirus Daemon

## 1. Overview

This project is a simple antivirus system written in Bash for the CC373 Operating Systems lab.

It monitors a directory for changes, scans files for suspicious extensions or keywords, and moves detected files to a quarantine directory. The restore tool allows users to restore false positives, permanently delete files, or leave them in quarantine.

The project also includes a Makefile to simplify running the scripts and a cron-based version for scheduled scanning.

Use this command to install the project local:
```bash
curl -fsSL https://raw.githubusercontent.com/Abdoalrahmankhedr/Simple-Antivirus-Daemon/main/install.sh | bash
```

## 2. Project Structure

### 2.1 Main Files and Directories

```text
project/
├── antivirusd.sh
├── antivirus-cron.sh
├── restore.sh
├── Makefile
└── test_dir/
```

* `antivirusd.sh`: Monitors the source directory and quarantines malicious files.
* `antivirus-cron.sh`: Runs the antivirus scan as a scheduled job.
* `restore.sh`: Allows users to review quarantined files and choose an action.
* `Makefile`: Provides commands to set up directories and run the scripts.
* `test_dir/`: Contains the files monitored by the antivirus.

### 2.2 Files Created During Execution

* `malicious_dir/`: Stores quarantined files. It is created automatically by the Makefile.
* `directory-info.last`: Stores the previous directory listing for comparison.
* `directory-info.new`: Stores the latest directory listing.
* `whitelist.txt`: Created inside `test_dir/` when a file is restored. It stores the paths of files marked as safe.
* `cron.log`: Can be used to save the output of scheduled scans when output redirection is configured.

## 3. Antivirus Daemon

### 3.1 How to Run

First, make the scripts executable:

```bash
chmod +x antivirusd.sh
```

Run the antivirus using:

```bash
./antivirusd.sh test_dir malicious_dir 5
```

Arguments:

* `test_dir`: The directory to monitor.
* `malicious_dir`: The directory where detected files are quarantined.
* `5`: The interval between checks, in seconds.

The script scans the directory on its first run. After that, it compares directory listings and scans again only when a change is detected.

Press `Ctrl + C` to stop the daemon.

### 3.2 Code Structure

**Blocked extensions and keywords**

The arrays `Blocked_Extentions` and `Blocked_Words` contain the required detection lists. They are defined at the beginning of `antivirusd.sh`.

* Extensions: `.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`.
* Keywords: `virus`, `trojan`, `malware`, `worm`, `ransomware`.

**Functions**

* `Check_malicious()`: Checks whether a file matches a blocked extension or contains a blocked keyword.
* `is_in_whitelist()`: Checks whether a file path is listed in `whitelist.txt`.
* `Scan_Directory()`: Scans the directory, skips whitelisted files, and copies detected files to quarantine before removing the originals.

**Main execution**

The script checks its arguments, performs an initial scan if no previous snapshot exists, and creates `directory-info.last`.

It then repeats the following steps:

1. Wait for the specified interval.
2. Save the current directory listing to `directory-info.new`.
3. Compare the two listings using `cmp`.
4. If they differ, scan the directory and update the previous snapshot.

## 4. Restore Tool

### 4.1 How to Run

Make the script executable:

```bash
chmod +x restore.sh
```

Run:

```bash
./restore.sh test_dir malicious_dir
```

Arguments:

* `test_dir`: The destination for restored files.
* `malicious_dir`: The directory containing quarantined files.

The tool displays a numbered list of files. Select a file and choose one of the following options:

1. Restore the file and add its path to the whitelist.
2. Permanently delete the file.
3. Leave the file in quarantine and return to the list.
4. Enter `0` to exit the tool.

### 4.2 Code Structure

* `Show_Options()`: Displays the selected filename and the three available actions.
* `List_files()`: Lists quarantined files, reads the user's choices, and performs the selected action.

The main execution checks the arguments and passes the directories to `List_files()`.

When a file is restored, the script copies it back to `test_dir`, records its path in `whitelist.txt`, removes the quarantined copy, and prints a confirmation message.

If the quarantine directory is empty, the script prints `No malicious files to review.`

## 5. Makefile

### 5.1 Configuration

The Makefile defines these variables:

```make
DIR=test_dir
MALICIOUS_DIR=malicious_dir
INTERVAL=5
```

They specify the monitored directory, quarantine directory, and scanning interval.

### 5.2 Available Targets

Run these commands from the project directory:

* `make setup`: Creates `malicious_dir` if it does not exist.
* `make antivirus`: Starts the antivirus daemon.
* `make restore`: Starts the restore tool.
* `make scheduledAntivirus`: Runs `antivirus-cron.sh`.

The `setup` target is a prerequisite for the other targets, so the quarantine directory is created before they run.

The Makefile simplifies execution by keeping the arguments in one place.

## 6. Antivirus Cron Job

### 6.1 How to Run

Make the script executable:

```bash
chmod +x antivirus-cron.sh
```

Run it manually using the project's Makefile:

```bash
make scheduledAntivirus
```

The cron version is intended for scheduled scanning instead of keeping a monitoring loop running continuously. It should use the same detection rules, quarantine behavior, and whitelist checks as the main antivirus.

### 6.2 Configure the Cron Job

**Prerequisites**

* Ubuntu with `cron` installed.
* The project scripts and directories in place.
* The required permissions to run the script and write to the quarantine directory and log file.

Install and start cron if necessary:

```bash
sudo apt update
sudo apt install cron
sudo systemctl enable --now cron
```

Open the current user's crontab:

```bash
crontab -e
```

To run the script every minute, with a 23-second delay after each scheduled start, add the following line. Replace `/absolute/path/to/project` with the actual project directory.

```cron
* * * * * sleep 23; /absolute/path/to/project/antivirus-cron.sh /absolute/path/to/project/test_dir /absolute/path/to/project/malicious_dir >> /absolute/path/to/project/cron.log 2>&1
```

Save the crontab and check the configured jobs:

```bash
crontab -l
```

The log redirection saves standard output and errors to `cron.log`.

**Note:** Standard cron schedules jobs by minute, not by second. The `sleep 23` command introduces the delay; it is not a seconds field in the cron expression.

### 6.3 Schedule for the Third Friday of Every Month

To run the scan at **12:31 AM on the third Friday of each month**, use this crontab entry:

```cron
31 0 15-21 * * [ "$(date +\%u)" -eq 5 ] && /absolute/path/to/project/antivirus-cron.sh /absolute/path/to/project/test_dir /absolute/path/to/project/malicious_dir >> /absolute/path/to/project/cron.log 2>&1
```

Here:

* `31`: Minute 31.
* `0`: Midnight hour.
* `15-21`: Days 15 through 21 of the month.
* `*`: Every month.
* The date check `date +%u` returns `5` on Friday, so the scan runs only when the date is a Friday within that range.

This avoids running the job on other Fridays.

## 7. Whitelist

The whitelist prevents files restored as false positives from being quarantined again.

When the user selects option `1` in `restore.sh`, the file path is appended to `test_dir/whitelist.txt`.

During scanning, `is_in_whitelist()` checks whether the file path exists in the whitelist. If it does, `Scan_Directory()` skips the file even if its extension or contents match a detection rule.

The whitelist persists between daemon runs because it is stored in a file rather than in memory.

## 8. Testing

You can create test files inside `test_dir`:

```bash
touch test_dir/test.exe
echo "This file contains malware" > test_dir/test.txt
echo "This is a normal file" > test_dir/normal.txt
```

Start the antivirus and wait for the next scan. Files matching the detection rules should be moved to `malicious_dir`.

Use the restore tool to review the quarantined files and test restoring, deleting, and leaving files in quarantine.

**Important:** Run the antivirus daemon and restore tool separately, as they are not designed to run concurrently.
