// Tests Node.js traffic generators without exposing the host network.
const {spawnSync}=require('node:child_process');
const path=require('node:path');
const root=path.join(__dirname,'..');
const files=['01-tcp-handshake.js','02-http-get.js','03-http-post-json.js','04-http-status.js','05-udp-echo.js','06-tcp-vs-udp.js','07-tcp-framing.js','08-local-dns.js','09-https-tls.js','10-troubleshooting.js'];
const cert=spawnSync(process.execPath,['setup-cert.js'],{cwd:root,encoding:'utf8',timeout:7000});
if(cert.status!==0){console.error('Certificate setup failed:',cert.stderr);process.exit(1);}
let fails=0;
for(const file of files){const out=spawnSync(process.execPath,[path.join('labs',file)],{cwd:root,encoding:'utf8',timeout:6000,env:{...process.env,LAB_DELAY_MS:'40'}}); console.log((out.status===0?'PASS ':'FAIL ')+file);if(out.status!==0){fails++;console.log(out.stdout,out.stderr,out.error?.message);}}
if(fails)process.exit(1);
