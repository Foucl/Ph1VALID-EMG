.PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

BUCKET = ph1valid

#################################################################################
# COMMANDS                                                                      #
#################################################################################

requirements:
	pip install -q -r requirements.txt

data: requirements
	python src/data/make_dataset.py

clean:
	find . -name "*.pyc" -exec rm {} \;

lint:
	flake8 --exclude=lib/,bin/ .

sync_data_to_s3:
	aws s3 sync data/ s3://$(BUCKET)/data/ --exclude "raw/EMG_raw/*"

sync_data_from_s3:
	aws s3 sync s3://$(BUCKET)/data/ data/ --exclude "raw/EMG_raw/*"

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################

# load env
# powershell [Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY", (dotenv -q never get AWS_ACCESS_KEY)[0].split("=")[1], "User")
