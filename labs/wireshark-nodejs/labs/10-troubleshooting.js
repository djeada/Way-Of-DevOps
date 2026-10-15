// Connection refused, slow response/client timeout and success.
const net=require('node:net'),http=require('node:http');
const HOST='127.0.0.1',PORT=4110,CLOSED_PORT=4199,wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=http.createServer((req,res)=>{
 if(req.url==='/slow')setTimeout(()=>{if(!res.destroyed){res.writeHead(200,{'Connection':'close'});res.end('slow done');}},650);
 else{res.writeHead(200,{'Connection':'close'});res.end('fast done');}
});
function refused(){return new Promise(done=>{
 const c=net.connect({host:HOST,port:CLOSED_PORT});
 c.on('connect',()=>{c.end();done();});
 c.on('error',e=>{console.log('Closed port:',e.code);done();});
});}
function request(path,timeout){return new Promise(done=>{
 let settled=false;const finish=()=>{if(!settled){settled=true;done();}};
 const req=http.get({host:HOST,port:PORT,path,agent:false,headers:{Connection:'close'}},res=>{
  console.log(path,res.statusCode);res.resume();res.on('end',finish);res.on('error',finish);
 });
 req.setTimeout(timeout,()=>{console.log(path,'timed out');req.destroy(new Error('CLIENT_TIMEOUT'));});
 req.on('error',e=>{console.log(path,e.message);finish();});
});}
server.listen(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 await refused();await request('/slow',150);await request('/fast',1500);server.close();
});
