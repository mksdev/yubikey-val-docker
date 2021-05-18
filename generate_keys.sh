ykksm-gen-keys --urandom 1 $1 > /root/keys.txt
gpg --no-tty --trust-model always -a -s --encrypt -r `gpg --no-tty --list-keys | head -n 3 | tail -1 | awk '{print $2}' | cut -d '/' -f2` < /root/keys.txt > /root/encrypted_keys.txt
ykksm-import < /root/encrypted_keys.txt

echo "######### KEYS ###########" && \
echo "---" && \
for i in `grep -v ^# /root/keys.txt`; do echo "key`echo $i | cut -d',' -f1`:"; echo "  public_id: `echo $i | cut -d',' -f2`"; echo "  private_id: `echo $i | cut -d',' -f3`";  echo "  secret_key: `echo $i | cut -d',' -f4`"; done; \
rm -f /root/keys.txt && \
echo "######## CLIENT ##########" && \
echo "---\nclient:" && \
echo "  id:  `ykval-export-clients | cut -d',' -f1`" && \
echo "  key: `ykval-export-clients | cut -d',' -f4`"


# GPG keys from gpg --list-secret-keys
# ykksm-gen-keys --urandom 1 10 | gpg -a --sign --encrypt -r <GPG selected KEY id> > encrypted_keys.txt