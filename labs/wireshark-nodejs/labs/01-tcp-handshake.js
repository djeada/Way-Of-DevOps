// TCP handshake, data exchange and graceful close (127.0.0.1 only).
const net=require('node:net');
const HOST='127.0.0.1',PORT=4101;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=net.createServer(s=>{
 console.log('[server] connected');
 s.on('data',b=>{console.log('[server] received',b.toString().trim());s.end('ACK FROM SERVER\n');});
 s.on('close',()=>server.close());
});
server.on('error',e=>{console.error(e);process.exitCode=1;});
server.listen(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 const client=net.createConnection({host:HOST,port:PORT});
 client.on('connect',()=>client.write('HELLO FROM CLIENT\n'));
 client.on('data',b=>console.log('[client]',b.toString().trim()));
 client.on('error',e=>{console.error(e);process.exitCode=1;});
});
