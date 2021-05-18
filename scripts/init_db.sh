ms="mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST"

RESULT=`$ms --skip-column-names -e "SHOW DATABASES LIKE '${YKVAL_DB_NAME}'"`
if [ "$RESULT" == "${YKVAL_DB_NAME}" ]; then
    echo "Database ${YKVAL_DB_NAME} exist skipping"
else
	echo "Generating ${YKVAL_DB_NAME} database"
    echo "create database ${YKVAL_DB_NAME}" | $ms
	$ms ${YKVAL_DB_NAME} < /usr/share/doc/yubikey-val/ykval-db.sql

	echo "Granting ykval access from localhost"
	{
	    echo "CREATE USER '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT,INSERT,UPDATE(modified, yk_counter, yk_low, yk_high, yk_use, nonce) ON ${YKVAL_DB_NAME}.yubikeys TO '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT,INSERT,UPDATE(id, secret, active) ON ${YKVAL_DB_NAME}.clients TO '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "GRANT SELECT,INSERT,UPDATE,DELETE ON ${YKVAL_DB_NAME}.queue TO '${YKVAL_VERIFIER_DB_NAME}'@'localhost';"
	    echo "SET PASSWORD FOR '${YKVAL_VERIFIER_DB_NAME}'@'localhost' = PASSWORD('${YKVAL_VERIFIER_DB_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms

	echo "Granting ykval access from %"
	{
	    echo "CREATE USER '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "GRANT SELECT,INSERT,UPDATE(modified, yk_counter, yk_low, yk_high, yk_use, nonce) ON ${YKVAL_DB_NAME}.yubikeys TO '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "GRANT SELECT,INSERT,UPDATE(id, secret, active) ON ${YKVAL_DB_NAME}.clients TO '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "GRANT SELECT,INSERT,UPDATE,DELETE ON ${YKVAL_DB_NAME}.queue TO '${YKVAL_VERIFIER_DB_NAME}'@'%';"
	    echo "SET PASSWORD FOR '${YKVAL_VERIFIER_DB_NAME}'@'%' = PASSWORD('${YKVAL_VERIFIER_DB_PASSWORD}');"
	    echo "FLUSH PRIVILEGES;"
	} | $ms
fi

