// Classroom-only minimal DNS server: UDP 4108, synthetic name.
const dgram=require('node:dgram');
const {Resolver}=require('node:dns').promises;
const HOST='127.0.0.1',PORT=4108,wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=dgram.createSocket('udp4');
server.on('message',(q,peer)=>{
 try{
  let off=12;
  while(off<q.length){const len=q[off++];if(len===0)break;if(len>63||off+len>q.length)throw Error('Invalid DNS name');off+=len;}
  if(off+4>q.length)throw Error('Short DNS question');
  const header=Buffer.alloc(12);q.copy(header,0,0,2);
  header.writeUInt16BE(0x8180,2);header.writeUInt16BE(1,4);header.writeUInt16BE(1,6);
  const answer=Buffer.from([0xc0,0x0c,0,1,0,1,0,0,0,30,0,4,10,20,30,40]);
  server.send(Buffer.concat([header,q.subarray(12,off+4),answer]),peer.port,peer.address);
 }catch(e){console.error('[DNS]',e.message);process.exitCode=1;}
});
server.bind(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 const r=new Resolver();r.setServers([HOST+':'+PORT]);
 try{console.log('[DNS]',await r.resolve4('course.test'));}
 catch(e){console.error(e);process.exitCode=1;}
 finally{server.close();}
});
