// Unencrypted HTTP request and response.
const http=require('node:http');
const HOST='127.0.0.1',PORT=4102;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=http.createServer((req,res)=>{
 console.log('[server]',req.method,req.url);
 res.writeHead(200,{'Content-Type':'text/plain; charset=utf-8','X-Lab':'02','Connection':'close'});
 res.end('Hello from the Node.js lab server!\n');
 server.close();
});
server.listen(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 http.get({hostname:HOST,port:PORT,path:'/hello?student=Alice',headers:{'User-Agent':'NodeLab/1.0','Connection':'close'}},res=>{
  console.log('[client] HTTP',res.statusCode);res.setEncoding('utf8');res.on('data',b=>console.log('[client]',b.trim()));
 }).on('error',e=>{console.error(e);process.exitCode=1;server.close();});
});
