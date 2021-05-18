ms="mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST"

YKVAL_VERIFIER_DB_NAME=ykval_verifier
# YKVAL_VERIFIER_DB_PASSWORD=ykval_verifier_password

RESULT=`$ms --skip-column-names -e "SHOW DATABASES LIKE 'ykval'"`
if [ "$RESULT" == "ykval" ]; then
    echo "Database ykval exist skipping"
else
	echo "Generating ykval database"
    echo 'create database ykval' | $ms
	$ms ykval < /usr/share/doc/yubikey-val/ykval-db.sql

	echo "Granting ykval access from localhost"
	{
	    echo "CREATE USER '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT,INSERT,UPDATE(modified, yk_counter, yk_low, yk_high, yk_use, nonce) ON ykval.yubikeys TO '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT,INSERT,UPDATE(id, secret, active) ON ykval.clients TO '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT,INSERT,UPDATE,DELETE ON ykval.queue TO '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "SET PASSWORD FOR '${YKVAL_VERIFIER_DB_NAME}'@'localhost' = PASSWORD('${YKVAL_VERIFIER_DB_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms

	echo "Granting ykval access from %"
	{
	    echo "CREATE USER '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "GRANT SELECT,INSERT,UPDATE(modified, yk_counter, yk_low, yk_high, yk_use, nonce) ON ykval.yubikeys TO '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "GRANT SELECT,INSERT,UPDATE(id, secret, active) ON ykval.clients TO '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "GRANT SELECT,INSERT,UPDATE,DELETE ON ykval.queue TO '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "SET PASSWORD FOR '${YKVAL_VERIFIER_DB_NAME}'@'%' = PASSWORD('${YKVAL_VERIFIER_DB_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms
fi

