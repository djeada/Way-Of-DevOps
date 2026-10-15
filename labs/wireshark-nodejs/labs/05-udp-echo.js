// UDP echo: no TCP handshake or reliable delivery guarantee.
const dgram=require('node:dgram');
const HOST='127.0.0.1',PORT=4105;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=dgram.createSocket('udp4'),client=dgram.createSocket('udp4');
let replies=0;
server.on('message',(b,peer)=>{console.log('[server]',b.toString());server.send(Buffer.from('echo:'+b),peer.port,peer.address);});
client.on('message',b=>{console.log('[client]',b.toString());if(++replies===3){client.close();server.close();}});
for(const s of [server,client])s.on('error',e=>{console.error(e);process.exitCode=1;s.close();});
server.bind(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 for(const m of ['one','two','three']){client.send(Buffer.from(m),PORT,HOST);await wait(150);}
});
