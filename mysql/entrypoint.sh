#!/bin/bash

create_data_dir() {

	mkdir -p ${MYSQL_DATA_DIR}
	chmod -R 0700 ${MYSQL_DATA_DIR}
	chown -R mysql:mysql ${MYSQL_DATA_DIR}

}

create_run_dir() {

	mkdir -p ${MYSQL_RUN_DIR}
	chmod -R 0755 ${MYSQL_RUN_DIR}
	chown -R mysql:root ${MYSQL_RUN_DIR}

	# hack: remove any existing lock files
	rm -rf ${MYSQL_RUN_DIR}/mysqld.sock.lock

}

create_log_dir() {

	mkdir -p ${MYSQL_LOG_DIR}
	chmod -R 0755 ${MYSQL_LOG_DIR}
	chown -R mysql:mysql ${MYSQL_LOG_DIR}

}

apply_configuration_fixes() {

	# disable error log
  	sed 's/^log_error/# log_error/' -i /etc/mysql/mysql.conf.d/mysqld.cnf

  	# Fixing StartUp Porblems with some DNS Situations and Speeds up the stuff
	echo "[mysqld]" >> /etc/mysql/conf.d/mysql-skip-name-resolv.cnf
	echo "skip_name_resolve" >> /etc/mysql/conf.d/mysql-skip-name-resolv.cnf

}

remove_debian_system_maint_password() {

  	#
  	# the default password for the debian-sys-maint user is randomly generated
  	# during the installation of the mysql-server package.
  	#
  	# Due to the nature of docker we blank out the password such that the maintenance
  	# user can login without a password.
  	#
  	sed 's/password = .*/password = /g' -i /etc/mysql/debian.cnf

}

initialize_mysql_database() {

  	# initialize MySQL data directory
  	if [ ! -d ${MYSQL_DATA_DIR}/mysql ]; then

    	echo "Installing database..."
    	mysqld --initialize-insecure --user=mysql >/dev/null 2>&1

    	# start mysql server
    	echo "Starting MySQL server..."
    	/usr/bin/mysqld_safe >/dev/null 2>&1 &

    	# wait for mysql server to start
    	echo -n "Waiting for database server to accept connections"
    	while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
    	do
      		timeout=$(($timeout - 1))
      		if [ $timeout -eq 0 ]; then
        		echo -e "\nCould not connect to database server. Aborting..."
        		exit 1
      		fi
      		echo -n "."
      		sleep 1
    	done
    	echo

    	## create a localhost only, debian-sys-maint user
    	## the debian-sys-maint is used while creating users and database
    	## as well as to shut down or starting up the mysql server via mysqladmin
    	echo "Creating debian-sys-maint user..."
    	mysql -uroot -e "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '';"
    	mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '' WITH GRANT OPTION;"

    	/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
		
  	fi

}

main() {

	create_data_dir
	create_run_dir
	create_log_dir

	# allow arguments to be passed to mysqld_safe
	if [[ ${1:0:1} = '-' ]]; then

		EXTRA_ARGS="$@"
		set --

	elif [[ ${1} == mysqld_safe || ${1} == $(which mysqld_safe) ]]; then

		EXTRA_ARGS="${@:2}"
		set --

	fi

	# default behaviour is to launch mysqld_safe
	if [[ -z ${1} ]]; then

		apply_configuration_fixes
		remove_debian_system_maint_password
		initialize_mysql_database

		# change encoding to UTF-8
		echo "[client]" >> /etc/mysql/mysql.conf.d/mysqld.cnf
		echo "default-character-set=utf8" >> /etc/mysql/mysql.conf.d/mysqld.cnf
		echo "[mysqld]" >> /etc/mysql/mysql.conf.d/mysqld.cnf
		echo "init_connect='SET collation_connection = utf8_unicode_ci'" >> /etc/mysql/mysql.conf.d/mysqld.cnf
		echo "init_connect='SET NAMES utf8'" >> /etc/mysql/mysql.conf.d/mysqld.cnf
		echo "character-set-server=utf8" >> /etc/mysql/mysql.conf.d/mysqld.cnf
		echo "collation-server=utf8_unicode_ci" >> /etc/mysql/mysql.conf.d/mysqld.cnf

		service mysql restart

		# enable root access from anywhere
		sed -e "s/^bind-address\(.*\)=.*/bind-address = 0.0.0.0/" -i /etc/mysql/mysql.conf.d/mysqld.cnf
		mysql -e "USE mysql;GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';FLUSH PRIVILEGES;"

		service mysql restart
		service mysql stop

		exec $(which mysqld_safe) $EXTRA_ARGS

	else
		exec "$@"
	
	fi

}

main
