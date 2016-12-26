#!/bin/bash

cat << EOF


██████╗      ██╗ █████╗ ███╗   ██╗ ██████╗ ██████╗ ███████╗██╗███████╗██╗██████╗ 
██╔══██╗     ██║██╔══██╗████╗  ██║██╔════╝ ██╔══██╗██╔════╝██║██╔════╝██║██╔══██╗
██║  ██║     ██║███████║██╔██╗ ██║██║  ███╗██║  ██║█████╗  ██║█████╗  ██║██████╔╝
██║  ██║██   ██║██╔══██║██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██║██╔══╝  ██║██╔══██╗
██████╔╝╚█████╔╝██║  ██║██║ ╚████║╚██████╔╝██████╔╝███████╗██║██║     ██║██║  ██║
╚═════╝  ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝
                                                                                 

   +++  Fast Django Virtual Dev Environment Creation with auto PostgresDB +++

EOF

echo -n "Enter your project name and press [ENTER]: "
read projnm
echo -n "Enter your database name and press [ENTER]: "
read dbname
echo -n "Enter your database user name and press [ENTER]: "
read dbuser
echo -n "Enter your database user password and press [ENTER]: "
read dbpass

#Create project folder and install dependencies
cd ~/
apt-get -y update && apt-get -y upgrade
apt-get -y install python3-pip python3-dev libpq-dev postgresql postgresql-contrib

pip3 install virtualenv 2>/dev/null

mkdir dev_env 2>/dev/null
cd dev_env

virtualenv "virtenv_$projnm"
source "virtenv_$projnm/bin/activate"
pip install django psycopg2 2>/dev/null
django-admin startproject $projnm
deactivate

#Log into Postgre and start setting up database
sudo -u postgres psql -c "CREATE DATABASE $dbname;"
sudo -u postgres psql -c "CREATE USER $dbuser WITH PASSWORD '$dbpass';"
sudo -u postgres psql -c "ALTER ROLE $dbuser SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE $dbuser SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE $dbuser SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $dbname TO $dbuser;"

#Capture secret key so not lost
settingsFile=~/dev_env/$projnm/$projnm/settings.py
secretKey=$(grep SECRET_KEY $settingsFile)

#Overwrite settings.py with db & project settings
read -d '' dbSettings << EOF
\"\"\"
Django settings for $projnm project.

Generated by 'django-admin startproject' using Django 1.10.4.

For more information on this file, see
https://docs.djangoproject.com/en/1.10/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.10/ref/settings/
\"\"\"

import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.10/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
REPLACE_ME

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = \'$projnm.urls\'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = \'$projnm.wsgi.application\'


# Database
# https://docs.djangoproject.com/en/1.10/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': \'$dbname\',
        'USER': \'$dbuser\',
        'PASSWORD': \'$dbpass\',
        'HOST': 'localhost',
        'PORT': '',
    }
}


# Password validation
# https://docs.djangoproject.com/en/1.10/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/1.10/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.10/howto/static-files/

STATIC_URL = '/static/'
EOF

# Restore secret key
echo "${dbSettings}" > $settingsFile
sed -i "/REPLACE_ME/c\\$secretKey" $settingsFile

cat << EOF

+++ $projnm Install Completed +++

- Development directory can be found at ~/dev_env
- The $projnm project can be found at ~/dev_env/$projnm
- The postgres database settings have already been added to $settingsFile

Database Settings
DB_NAME: $dbname
DB_USER: $dbuser
DB_PASS: $dbpass
EOF
