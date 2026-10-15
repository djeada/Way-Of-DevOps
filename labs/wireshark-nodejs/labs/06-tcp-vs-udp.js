// Compare message transfer over TCP and UDP, same numbered port.
const net=require('node:net'),dgram=require('node:dgram');
const HOST='127.0.0.1',PORT=4106,wait=ms=>new Promise(r=>setTimeout(r,ms));
const payload='COMPARE-'+'A'.repeat(100);
let tcpDone=false,udpDone=false;
const tcpServer=net.createServer(s=>s.on('data',b=>{console.log('[TCP]',b.length);s.end('TCP-ACK');}));
const udpServer=dgram.createSocket('udp4');
udpServer.on('message',(b,p)=>{console.log('[UDP]',b.length);udpServer.send('UDP-ACK',p.port,p.address);});
function stop(){if(tcpDone&&udpDone){tcpServer.close();udpServer.close();}}
udpServer.bind(PORT,HOST,()=>tcpServer.listen(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 const c=net.connect(PORT,HOST,()=>c.write(payload));
 c.on('data',b=>console.log('[TCP reply]',b.toString()));
 c.on('close',()=>{tcpDone=true;stop();});
 c.on('error',e=>{console.error(e);process.exitCode=1;tcpDone=true;stop();});
 await wait(250);
 const u=dgram.createSocket('udp4');
 u.on('message',b=>{console.log('[UDP reply]',b.toString());u.close();udpDone=true;stop();});
 u.send(payload,PORT,HOST);
}));
