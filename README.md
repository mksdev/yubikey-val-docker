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

### Add keys, example gpg

```
docker-compose exec yubikey-ksm bash
cd /root
./generate_gpg.sh
gpg --list-secret-keys
```

Generate new YubikeyOTP
```
offset=1
keycount=1
ykksm-gen-keys --urandom $offset $key_count > /root/keys.txt
> # ykksm 1
> # serialnr,identity,internaluid,aeskey,lockpw,created,accessed[,progflags]
> 1,cccccccccccb,cf46705d9473,66acacc07fceac543ded99699ab9e881,4897018f8753,2021-05-07T17:03:27,
> # the end
```

Encrypt it using gpg
```
# key-id pick from gpg --list-secret-keys

export GPG_TTY=$(tty) # fix bug https://github.com/keybase/keybase-issues/issues/2798
gpg -a --sign --encrypt -r <GPG selected KEY id> < keys.txt > encrypted_keys.txt
```

Import keys
```
ykksm-import < /root/encrypted_keys.txt
```

Print key info that must be flashed to the yubikey
```
echo "######### KEYS ###########" && \
echo "---" && \
for i in `grep -v ^# /root/keys.txt`; do echo "key`echo $i | cut -d',' -f1`:"; echo "  public_id: `echo $i | cut -d',' -f2`"; echo "  private_id: `echo $i | cut -d',' -f3`";  echo "  secret_key: `echo $i | cut -d',' -f4`"; done;
```

Dont forget to cleanup
```
rm /root/keys.txt
rm /root/encrypted_keys.txt
```