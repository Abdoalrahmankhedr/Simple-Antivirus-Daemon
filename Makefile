DIR=test_dir
MALICIOUS_DIR=malicious_dir
INTERVAL=5

all: setup

setup:
	mkdir -p $(MALICIOUS_DIR)

antivirus: setup
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

restore: setup
	./restore.sh $(DIR) $(MALICIOUS_DIR)

scheduledAntivirus: setup
	./antivirus-cron.sh $(DIR) $(MALICIOUS_DIR)
