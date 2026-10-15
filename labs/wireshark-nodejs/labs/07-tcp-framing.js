// TCP is a byte stream; newline delimiters define logical messages.
const net=require('node:net'),HOST='127.0.0.1',PORT=4107;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=net.createServer(s=>{
 let buffer='';
 s.on('data',b=>{
  console.log('[data event]',JSON.stringify(b.toString()));buffer+=b.toString();let i;
  while((i=buffer.indexOf('\n'))!==-1){console.log('[logical message]',buffer.slice(0,i));buffer=buffer.slice(i+1);}
 });
 s.on('close',()=>server.close());
});
server.listen(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 const c=net.connect(PORT,HOST,async()=>{c.write('red\nblue\npar');await wait(300);c.end('tial\n');});
 c.on('error',e=>{console.error(e);process.exitCode=1;});
});
