"use client";
import { useEffect, useRef } from "react";

const RIPPLE_CSS = `
  @keyframes fishSplashBlue {
    0%   { box-shadow: 0 0 0 0 rgba(0,183,255,0.9); }
    60%  { box-shadow: 0 0 40px 20px rgba(0,183,255,0.25); }
    100% { box-shadow: 0 0 0 80px transparent; }
  }
  @keyframes fishSplashPink {
    0%   { box-shadow: 0 0 0 0 rgba(255,59,212,0.9); }
    60%  { box-shadow: 0 0 40px 20px rgba(255,59,212,0.25); }
    100% { box-shadow: 0 0 0 80px transparent; }
  }
  .fish-splash-blue { animation: fishSplashBlue 1s ease-out forwards !important; border-radius: 14px; }
  .fish-splash-pink { animation: fishSplashPink 1s ease-out forwards !important; border-radius: 14px; }
`;

function lerp(a, b, t) { return a + (b - a) * t; }

class FishState {
  constructor({ speed, size, index, splashClass, glowColor, totalFrames }) {
    this.speed       = speed;
    this.size        = size;
    this.index       = index;
    this.splashClass = splashClass;
    this.glowColor   = glowColor;
    this.totalFrames = totalFrames;
    this.frameIndex  = 0;
    this.frameTimer  = 0;
    this.x           = window.innerWidth / 2;
    this.y           = 160;
    this.angle       = 0;
    this.opacity     = 0;
    this.scale       = 0;
    this.swimT       = index * Math.PI;
    this.state       = "EMERGING";
    this.stateTimer  = index * 2.5;
    this.targetCard  = null;
    this.targetX     = this.x;
    this.targetY     = this.y;
  }

  logoX() { return window.innerWidth / 2 + (this.index === 0 ? -55 : 55); }
  logoY() { return 160; }

  swimPos(t) {
    const w = window.innerWidth, h = window.innerHeight;
    return {
      x: w / 2 + (this.index === 0 ? -90 : 90) + w * 0.37 * Math.sin(t + this.index * Math.PI),
      y: h / 2 + 80 + h * 0.3 * Math.sin((t + this.index * Math.PI) * 2),
    };
  }

  update(dt, cards) {
    this.stateTimer += dt;
    this.swimT      += dt * this.speed;

    // Ciclar frames a 8fps
    this.frameTimer += dt;
    if (this.frameTimer > 1 / 8) {
      this.frameTimer  = 0;
      this.frameIndex  = (this.frameIndex + 1) % this.totalFrames;
    }

    const px = this.x, py = this.y;

    switch (this.state) {
      case "EMERGING": {
        this.opacity = Math.min(1, this.opacity + dt * 2);
        this.scale   = Math.min(1, this.scale   + dt * 2);
        this.x = lerp(this.x, this.logoX(), dt * 3);
        this.y = lerp(this.y, this.logoY(), dt * 3);
        if (this.stateTimer > 1.8 + this.index * 1.2) this.state = "SWIMMING";
        break;
      }
      case "SWIMMING": {
        const pos = this.swimPos(this.swimT);
        this.x = lerp(this.x, pos.x, dt * 1.8);
        this.y = lerp(this.y, pos.y, dt * 1.8);
        this.opacity = Math.min(1, this.opacity + dt * 2);
        this.scale   = Math.min(1, this.scale   + dt * 2);
        if (this.stateTimer > 7 + this.index * 3 && cards.length > 0) {
          const vis = cards.filter(c => {
            const r = c.getBoundingClientRect();
            return r.top > 50 && r.bottom < window.innerHeight - 50;
          });
          const pool = vis.length > 0 ? vis : cards;
          this.targetCard = pool[Math.floor(Math.random() * pool.length)];
          this.state = "TARGETING";
          this.stateTimer = 0;
        }
        break;
      }
      case "TARGETING": {
        if (this.targetCard) {
          const r = this.targetCard.getBoundingClientRect();
          this.targetX = r.left + r.width  / 2;
          this.targetY = r.top  + r.height / 2;
        }
        const tdx = this.targetX - this.x;
        const tdy = this.targetY - this.y;
        const td  = Math.sqrt(tdx * tdx + tdy * tdy);
        if (td > 0.5) {
          const step = Math.min(300 * dt, td);
          this.x += (tdx / td) * step;
          this.y += (tdy / td) * step;
        }
        if (td < 40) {
          if (this.targetCard) {
            this.targetCard.classList.add(this.splashClass);
            const card = this.targetCard;
            setTimeout(() => card.classList.remove(this.splashClass), 1000);
          }
          this.state = "DIVING";
          this.stateTimer = 0;
        }
        break;
      }
      case "DIVING": {
        this.opacity = Math.max(0, this.opacity - dt * 3.5);
        this.scale   = Math.max(0, this.scale   - dt * 3.5);
        if (this.stateTimer > 1.2) {
          this.x = this.logoX();
          this.y = this.logoY();
          this.state = "RETURNING";
          this.stateTimer = 0;
        }
        break;
      }
      case "RETURNING": {
        this.opacity = Math.min(1, this.opacity + dt * 1.5);
        this.scale   = Math.min(1, this.scale   + dt * 1.5);
        this.x = lerp(this.x, this.logoX(), dt * 2.5);
        this.y = lerp(this.y, this.logoY(), dt * 2.5);
        if (this.stateTimer > 1.5) {
          this.swimT += Math.PI * 0.4;
          this.state = "SWIMMING";
          this.stateTimer = 0;
        }
        break;
      }
    }

    const adx = this.x - px, ady = this.y - py;
    if (Math.abs(adx) + Math.abs(ady) > 0.3) {
      let diff = Math.atan2(ady, adx) - this.angle;
      while (diff >  Math.PI) diff -= 2 * Math.PI;
      while (diff < -Math.PI) diff += 2 * Math.PI;
      this.angle += diff * Math.min(dt * 4, 1);
    }
  }

  draw(ctx, frames) {
    if (this.opacity <= 0 || this.scale <= 0) return;
    const frame = frames[this.frameIndex];
    if (!frame || !frame.complete || !frame.naturalWidth) return;

    const w = this.size;
    const h = (frame.naturalHeight / frame.naturalWidth) * w;

    const facingLeft   = Math.cos(this.angle) < 0;
    const displayAngle = facingLeft ? Math.PI - this.angle : this.angle;

    ctx.save();
    ctx.globalAlpha = this.opacity;
    ctx.translate(this.x, this.y);
    ctx.rotate(displayAngle);
    if (facingLeft) ctx.scale(-1, 1);
    ctx.scale(this.scale, this.scale);
    ctx.shadowColor = this.glowColor;
    ctx.shadowBlur  = 35;
    ctx.drawImage(frame, -w / 2, -h / 2, w, h);
    ctx.restore();
  }
}

export default function SwimmingFish() {
  const canvasRef = useRef(null);

  useEffect(() => {
    const style = document.createElement("style");
    style.textContent = RIPPLE_CSS;
    document.head.appendChild(style);

    const canvas = canvasRef.current;
    const ctx    = canvas.getContext("2d");
    const setSize = () => { canvas.width = window.innerWidth; canvas.height = window.innerHeight; };
    setSize();
    window.addEventListener("resize", setSize);

    // Pez azul — 16 frames PNG transparentes
    const azulFrames = Array.from({ length: 16 }, (_, i) => {
      const img = new Image();
      img.src = `/frames-azul/azul_${String(i + 1).padStart(2, "0")}.png`;
      return img;
    });

    // Pez rosa — 9 frames PNG transparentes
    const rosaFrames = Array.from({ length: 9 }, (_, i) => {
      const img = new Image();
      img.src = `/frames-rosa/rosa_${String(i + 1).padStart(2, "0")}.png`;
      return img;
    });

    const fish = [
      new FishState({ speed: 0.28, size: 185, index: 0, splashClass: "fish-splash-blue", glowColor: "#00d4ff", totalFrames: 10 }),
      new FishState({ speed: 0.23, size: 165, index: 1, splashClass: "fish-splash-pink", glowColor: "#ff44ee", totalFrames: 10 }),
    ];

    let last = performance.now(), animId;

    function loop(now) {
      const dt    = Math.min((now - last) / 1000, 0.05);
      last        = now;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const cards = Array.from(document.querySelectorAll("[data-product-card]"));
      fish[0].update(dt, cards); fish[0].draw(ctx, azulFrames);
      fish[1].update(dt, cards); fish[1].draw(ctx, rosaFrames);
      animId = requestAnimationFrame(loop);
    }

    animId = requestAnimationFrame(loop);
    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener("resize", setSize);
      document.head.removeChild(style);
    };
  }, []);

  return (
    <canvas ref={canvasRef} style={{
      position: "fixed", top: 0, left: 0,
      width: "100vw", height: "100vh",
      pointerEvents: "none", zIndex: 50,
    }} />
  );
}
