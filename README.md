## Yubikey validation server

Runs yubikey-val in yubikey-ksm in docker using mariadb and apache server.

# To run

```
# 1. prepare .env
cp .env.teplate .env
# modify .env

# 2. setup mysql data directory, or modify docker-compose.yml
mkdir ./data
mkdir ./data/mysql

# 3. run
docker-compose up 

# 4. initialize database if running for rist time
docker-compose exec yubikey-val bash
/root/init_db.sh
exit

docker-compose exec yubikey-ksm bash
/root/init_db.sh
exit
```

Current implementation uses same database instance for storing yubikey-val and yubikey-ksm values, but you can specify different databases for each container such that decryption is done from totally different database.


## Generate clients in yubikey-val
```
docker-compose exec yubikey-val bash
ykval-gen-clients --urandom --notes "Client server"
> 1,u0FELVEmjquPq3d8dMQl6MW/crI=
```

Test using `ykclient`
```
ykclient --debug --url "http://127.0.0.1:5004/wsapi/2.0/verify" --apikey u0FELVEmjquPq3d8dMQl6MW/crI= 1 <Yubikey OTP, click to get one>
```