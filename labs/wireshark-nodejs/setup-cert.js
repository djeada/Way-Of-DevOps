// Creates short-lived local HTTPS demo credentials for Lab 9.
const fs=require('node:fs');
const path=require('node:path');
const {spawnSync}=require('node:child_process');
const dir=path.join(__dirname,'certs');
fs.mkdirSync(dir,{recursive:true});
const key=path.join(dir,'key.pem'), cert=path.join(dir,'cert.pem');
if (fs.existsSync(key) && fs.existsSync(cert)) { console.log('Certificate exists. Delete certs/*.pem to renew.'); process.exit(0); }
const args=['req','-x509','-newkey','rsa:2048','-sha256','-nodes','-keyout',key,'-out',cert,'-days','3','-subj','/CN=localhost','-addext','subjectAltName=DNS:localhost,IP:127.0.0.1'];
const result=spawnSync('openssl',args,{stdio:'inherit'});
if (result.error || result.status!==0){console.error('OpenSSL failed. Install OpenSSL.'); process.exit(1);}
console.log('Generated 3-day classroom certificate in certs/.');
