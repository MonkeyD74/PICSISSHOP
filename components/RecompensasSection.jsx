"use client"
import { useState } from "react"

const WA_NUMBER = "523521444391"
const CAT = "RECOMPENSAS"

function $MX(n){return new Intl.NumberFormat("es-MX",{style:"currency",currency:"MXN"}).format(n)}

function Card({p}){
  const wa="https://wa.me/"+WA_NUMBER+"?text="+encodeURIComponent("Hola, quiero canjear puntos por: "+p.name)
  return(
    <div onMouseEnter={e=>{e.currentTarget.style.transform="translateY(-4px)";e.currentTarget.style.boxShadow="0 8px 32px #7c3aed44"}} onMouseLeave={e=>{e.currentTarget.style.transform="translateY(0)";e.currentTarget.style.boxShadow="none"}} style={{background:"linear-gradient(145deg,#1a1a2e,#16213e)",border:"1px solid #7c3aed40",borderRadius:16,overflow:"hidden",display:"flex",flexDirection:"column",transition:"transform 0.2s,box-shadow 0.2s"}}>
      {p.image?<img src={p.image} alt={p.name} style={{width:"100%",height:180,objectFit:"cover"}}/>:<div style={{width:"100%",height:180,display:"flex",alignItems:"center",justifyContent:"center",fontSize:48,background:"linear-gradient(135deg,#7c3aed22,#4f46e522)"}}>💎</div>}
      <div style={{padding:"14px 16px",flex:1,display:"flex",flexDirection:"column",gap:8}}>
        <p style={{margin:0,color:"#e2e8f0",fontWeight:700,fontSize:15}}>{p.name}</p>
        {p.price>0&&<p style={{margin:0,color:"#a78bfa",fontWeight:800,fontSize:16}}>{(p.price)}</p>}
        <div style={{flex:1}}/>
        <a href={wa} target="_blank" rel="noopener noreferrer" style={{display:"block",textAlign:"center",background:"linear-gradient(135deg,#7c3aed,#4f46e5)",color:"#fff",fontWeight:700,fontSize:13,padding:"10px 0",borderRadius:10,textDecoration:"none"}}>💬 Canjear con puntos</a>
      </div>
    </div>
  )
}
