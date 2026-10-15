// Observe a JSON request body on unencrypted HTTP.
const http=require('node:http');
const HOST='127.0.0.1',PORT=4103;
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const server=http.createServer((req,res)=>{
 let body='';req.setEncoding('utf8');req.on('data',b=>body+=b);
 req.on('end',()=>{
  try{const order=JSON.parse(body);res.writeHead(201,{'Content-Type':'application/json','Connection':'close'});
   res.end(JSON.stringify({accepted:true,product:order.product,quantity:order.quantity}));}
  catch{res.writeHead(400,{'Connection':'close'});res.end('Invalid JSON');}
  server.close();
 });
});
server.listen(PORT,HOST,async()=>{
 await wait(Number(process.env.LAB_DELAY_MS||3000));
 const body=JSON.stringify({product:'notebook',quantity:2,classroom:true});
 const req=http.request({host:HOST,port:PORT,path:'/orders',method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(body),'Connection':'close'}},res=>{
  console.log('[client] HTTP',res.statusCode);res.setEncoding('utf8');res.on('data',b=>console.log('[client]',b));
 });
 req.on('error',e=>{console.error(e);process.exitCode=1;server.close();});req.end(body);
});
