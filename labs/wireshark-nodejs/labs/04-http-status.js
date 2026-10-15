// HTTP status codes from three separate client requests.
const http=require('node:http');
const HOST='127.0.0.1',PORT=4104;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=http.createServer((req,res)=>{
 const status=req.url==='/ok'?200:req.url==='/missing'?404:500;
 res.writeHead(status,{'Content-Type':'text/plain','Connection':'close'});res.end('Status '+status+'\n');
});
const request=path=>new Promise(resolve=>{
 http.get({host:HOST,port:PORT,path,agent:false,headers:{Connection:'close'}},res=>{
  console.log('[client]',path,res.statusCode);res.resume();res.on('end',resolve);
 }).on('error',e=>{console.error(e);process.exitCode=1;resolve();});
});
server.listen(PORT,HOST,async()=>{await wait(Number(process.env.LAB_DELAY_MS||3000));
 for(const path of ['/ok','/missing','/error'])await request(path);server.close();
});
