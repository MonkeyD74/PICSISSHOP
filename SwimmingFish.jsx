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

// ── Sonido de gota cayendo en agua ─────────────────────────────────
function playWaterSound(isBlue) {
  try {
    const ac  = new (window.AudioContext || window.webkitAudioContext)();
    const now = ac.currentTime;

    // Tono principal: sinewave con pitch que cae rápido (característica de gota)
    const osc1 = ac.createOscillator();
    osc1.type = "sine";
    osc1.frequency.setValueAtTime(isBlue ? 680 : 920, now);
    osc1.frequency.exponentialRampToValueAtTime(isBlue ? 140 : 200, now + 0.18);

    const g1 = ac.createGain();
    g1.gain.setValueAtTime(0, now);
    g1.gain.linearRampToValueAtTime(0.09, now + 0.004); // ataque muy rápido
    g1.gain.exponentialRampToValueAtTime(0.001, now + 0.28);

    // Resonancia secundaria — "pling" de la superficie del agua
    const osc2 = ac.createOscillator();
    osc2.type = "sine";
    osc2.frequency.setValueAtTime(isBlue ? 320 : 480, now + 0.01);
    osc2.frequency.exponentialRampToValueAtTime(isBlue ? 70 : 110, now + 0.22);

    const g2 = ac.createGain();
    g2.gain.setValueAtTime(0, now + 0.01);
    g2.gain.linearRampToValueAtTime(0.05, now + 0.015);
    g2.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

    // Pequeño ruido suave para el "splash" — muy atenuado
    const bufSize = Math.floor(ac.sampleRate * 0.06);
    const buf = ac.createBuffer(1, bufSize, ac.sampleRate);
    const d   = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) {
      d[i] = (Math.random() * 2 - 1) * (1 - i / bufSize);
    }
    const noise = ac.createBufferSource();
    noise.buffer = buf;
    const bp = ac.createBiquadFilter();
    bp.type = "bandpass"; bp.frequency.value = 2000; bp.Q.value = 2;
    const gn = ac.createGain();
    gn.gain.setValueAtTime(0.018, now);
    gn.gain.exponentialRampToValueAtTime(0.001, now + 0.06);

    osc1.connect(g1); g1.connect(ac.destination);
    osc2.connect(g2); g2.connect(ac.destination);
    noise.connect(bp); bp.connect(gn); gn.connect(ac.destination);

    osc1.start(now);   osc1.stop(now + 0.35);
    osc2.start(now + 0.01); osc2.stop(now + 0.4);
    noise.start(now);

    setTimeout(() => ac.close(), 1200);
  } catch (_) {}
}

// ── Partículas de agua ──────────────────────────────────────────────
class Particle {
  constructor(x, y, color, type) {
    this.x     = x;
    this.y     = y;
    this.color = color;
    this.type  = type; // 'bubble' | 'ripple' | 'splash' | 'drop' | 'wave'
    this.life  = 1;

    if (type === "bubble") {
      this.r     = Math.random() * 10 + 5;          // 5-15px (antes 1.5-5)
      this.vx    = (Math.random() - 0.5) * 2.5;
      this.vy    = -(Math.random() * 2.5 + 1);
      this.decay = 0.4 + Math.random() * 0.25;
    } else if (type === "ripple") {
      this.r     = Math.random() * 10 + 20;         // empieza en 20-30px
      this.grow  = Math.random() * 60 + 70;         // crece 70-130px/s
      this.vx = this.vy = 0;
      this.decay = 0.75;
    } else if (type === "splash") {
      this.r     = Math.random() * 20 + 30;         // empieza 30-50px
      this.grow  = Math.random() * 120 + 130;       // crece 130-250px/s
      this.vx = this.vy = 0;
      this.decay = 0.9;
    } else if (type === "drop") {
      this.r       = Math.random() * 5 + 3;         // 3-8px
      this.vx      = (Math.random() - 0.5) * 8;
      this.vy      = -(Math.random() * 7 + 3);
      this.gravity = 12;
      this.decay   = 0.9;
    } else if (type === "wave") {
      this.r     = Math.random() * 20 + 30;         // 30-50px
      this.grow  = Math.random() * 30 + 20;
      this.skew  = Math.random() * 0.3 + 0.45;      // menos aplastado
      this.vx = this.vy = 0;
      this.decay = 0.6;
    }
  }

  update(dt) {
    this.life -= dt * this.decay;
    this.x += (this.vx || 0) * dt * 60;
    this.y += (this.vy || 0) * dt * 60;
    if (this.gravity) this.vy += this.gravity * dt;
    if (this.grow) this.r += this.grow * dt;
  }

  draw(ctx) {
    if (this.life <= 0) return;
    const a = Math.max(0, this.life);
    ctx.save();
    ctx.shadowColor = this.color;
    ctx.shadowBlur  = 25;                            // glow fuerte

    if (this.type === "bubble") {
      ctx.globalAlpha = a * 0.04;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = this.color;
      ctx.fill();
      ctx.globalAlpha = a * 0.15;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1;
      ctx.stroke();
    } else if (this.type === "ripple") {
      ctx.globalAlpha = a * 0.12;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1;
      ctx.stroke();
    } else if (this.type === "splash") {
      ctx.globalAlpha = a * 0.14;
      ctx.shadowBlur  = 8;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1.5;
      ctx.stroke();
    } else if (this.type === "drop") {
      ctx.globalAlpha = a * 0.18;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = this.color;
      ctx.fill();
    } else if (this.type === "wave") {
      ctx.globalAlpha = a * 0.1;
      ctx.beginPath();
      ctx.ellipse(this.x, this.y, this.r, this.r * this.skew, 0, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1;
      ctx.stroke();
    }
    ctx.restore();
  }
}

// ── Estado y lógica del pez ─────────────────────────────────────────
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
    this.rippleTimer = 0;
    this.bubbleTimer = 0;
    this.waveTimer   = 0;
    this.trail       = [];                       // estela de posiciones
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

  logoX() {
    const hero = document.querySelector(".logoHero");
    const cx   = hero
      ? hero.getBoundingClientRect().left + hero.getBoundingClientRect().width / 2
      : window.innerWidth / 2;
    return cx + (this.index === 0 ? -65 : 65);
  }
  logoY() {
    const hero = document.querySelector(".logoHero");
    if (!hero) return 160;
    const r = hero.getBoundingClientRect();
    return r.top + r.height * 0.52;          // emerge desde el centro del hero
  }

  swimPos(t) {
    const w = window.innerWidth, h = window.innerHeight;
    return {
      x: w / 2 + (this.index === 0 ? -90 : 90) + w * 0.37 * Math.sin(t + this.index * Math.PI),
      y: h / 2 + 80 + h * 0.3 * Math.sin((t + this.index * Math.PI) * 2),
    };
  }

  spawnSplash(particles) {
    // 3 anillos concéntricos
    for (let i = 0; i < 3; i++) {
      setTimeout(() => {
        particles.push(new Particle(this.x, this.y, this.glowColor, "splash"));
      }, i * 80);
    }
    // 8 gotas en arco
    for (let i = 0; i < 8; i++) {
      const p = new Particle(this.x, this.y, this.glowColor, "drop");
      const ang = (i / 8) * Math.PI * 2;
      p.vx = Math.cos(ang) * (Math.random() * 3 + 2);
      p.vy = Math.sin(ang) * (Math.random() * 3 + 2) - 3;
      particles.push(p);
    }
    // 4 burbujas
    for (let i = 0; i < 4; i++) {
      const p = new Particle(
        this.x + (Math.random() - 0.5) * 40,
        this.y + (Math.random() - 0.5) * 40,
        this.glowColor, "bubble"
      );
      p.vy = -(Math.random() * 2 + 1);
      particles.push(p);
    }
    // 1 ola
    particles.push(new Particle(this.x, this.y, this.glowColor, "wave"));
  }

  update(dt, cards, particles) {
    this.stateTimer += dt;
    this.swimT      += dt * this.speed;

    // Ciclar frames a 8fps
    this.frameTimer += dt;
    if (this.frameTimer > 1 / 8) {
      this.frameTimer = 0;
      this.frameIndex = (this.frameIndex + 1) % this.totalFrames;
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
        const sdx = pos.x - this.x, sdy = pos.y - this.y;
        const sd = Math.sqrt(sdx * sdx + sdy * sdy);
        const MAX_SWIM = 55; // px/s — velocidad máxima nadando
        if (sd > 1) {
          const move = Math.min(sd, MAX_SWIM * dt);
          this.x += (sdx / sd) * move;
          this.y += (sdy / sd) * move;
        }
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
          const step = Math.min(50 * dt, td);
          this.x += (tdx / td) * step;
          this.y += (tdy / td) * step;
        }
        if (td < 40) {
          this.spawnSplash(particles);
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

    // Estela (trail) — siempre que el pez sea visible
    if (this.opacity > 0.2) {
      this.trail.push({ x: this.x, y: this.y, life: 1 });
      if (this.trail.length > 22) this.trail.shift();
    }

    // Efectos de agua mientras nada
    const spd = Math.sqrt((this.x - px) ** 2 + (this.y - py) ** 2) / dt;
    if (this.opacity > 0.3 && spd > 8) {

      // Burbujas — pocas, sutiles
      this.bubbleTimer += dt;
      if (this.bubbleTimer > 0.28) {
        this.bubbleTimer = 0;
        particles.push(new Particle(
          this.x + (Math.random() - 0.5) * 20,
          this.y + (Math.random() - 0.5) * 20,
          this.glowColor, "bubble"
        ));
      }

      // Ripple suave — poco frecuente
      this.rippleTimer += dt;
      if (this.rippleTimer > 0.7) {
        this.rippleTimer = 0;
        particles.push(new Particle(this.x, this.y, this.glowColor, "ripple"));
      }

      // Olas — mínimas
      this.waveTimer += dt;
      if (this.waveTimer > 1.4) {
        this.waveTimer = 0;
        particles.push(new Particle(this.x, this.y, this.glowColor, "wave"));
      }
    }

    // Ángulo suavizado
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

    // ── Estela de brillo ───────────────────────────────────────────
    const tLen = this.trail.length;
    if (tLen > 1) {
      for (let i = 1; i < tLen; i++) {
        const t  = i / tLen;                      // 0→1 (más viejo→reciente)
        const pt = this.trail[i];
        const r  = t * 14 + 2;                    // radio 2-16px
        ctx.save();
        ctx.globalAlpha = t * this.opacity * 0.06;
        ctx.shadowColor = this.glowColor;
        ctx.shadowBlur  = 30;
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, r, 0, Math.PI * 2);
        ctx.fillStyle = this.glowColor;
        ctx.fill();
        ctx.restore();
      }
    }

    // ── Dibujo del pez ─────────────────────────────────────────────
    const frame = frames[this.frameIndex];
    if (!frame || !frame.complete || !frame.naturalWidth) return;

    const w = this.size;
    const h = (frame.naturalHeight / frame.naturalWidth) * w;
    const facingLeft   = Math.cos(this.angle) < 0;
    const displayAngle = facingLeft ? Math.PI - this.angle : this.angle;

    ctx.save();
    ctx.globalAlpha = this.opacity * 0.6;
    ctx.translate(this.x, this.y);
    ctx.rotate(displayAngle);
    if (facingLeft) ctx.scale(-1, 1);
    ctx.scale(this.scale, this.scale);
    ctx.shadowColor = this.glowColor;
    ctx.shadowBlur  = 18;
    ctx.drawImage(frame, -w / 2, -h / 2, w, h);
    ctx.restore();
  }
}

// ── Componente principal ────────────────────────────────────────────
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

    // Frames diferidos: se crean vacíos y el src se asigna cuando el navegador
    // está libre, para no competir con las imágenes de productos en la carga inicial.
    // draw() ya valida frame.complete/naturalWidth, así que es seguro.
    const azulFrames = Array.from({ length: 10 }, () => new Image());
    const rosaFrames = Array.from({ length: 10 }, () => new Image());
    const loadFrames = () => {
      azulFrames.forEach((img, i) => { img.src = `/frames-azul/azul_${String(i + 1).padStart(2, "0")}.png`; });
      rosaFrames.forEach((img, i) => { img.src = `/frames-rosa/rosa_${String(i + 1).padStart(2, "0")}.png`; });
    };
    let idleId;
    if ("requestIdleCallback" in window) idleId = requestIdleCallback(loadFrames, { timeout: 2500 });
    else idleId = setTimeout(loadFrames, 1200);

    const fish = [
      new FishState({ speed: 0.06, size: 190, index: 0, splashClass: "fish-splash-blue", glowColor: "#00d4ff", totalFrames: 10 }),
      new FishState({ speed: 0.05, size: 240, index: 1, splashClass: "fish-splash-pink", glowColor: "#ff44ee", totalFrames: 10 }),
    ];

    const particles = [];

    // ── Glow suave del dedo/cursor ────────────────────────────────
    let ptrX = -999, ptrY = -999;
    function onMove(e) {
      const pt = e.touches ? e.touches[0] : e;
      ptrX = pt.clientX; ptrY = pt.clientY;
    }
    window.addEventListener("mousemove", onMove);
    window.addEventListener("touchmove", onMove, { passive: true });

    // ── Toque / click sobre un pez ──────────────────────────────────
    function handleTap(e) {
      const cx = e.touches ? e.touches[0].clientX : e.clientX;
      const cy = e.touches ? e.touches[0].clientY : e.clientY;

      fish.forEach((f, i) => {
        const dx = cx - f.x, dy = cy - f.y;
        if (Math.sqrt(dx * dx + dy * dy) < f.size * 0.75) {
          // Sonido de agua
          playWaterSound(i === 0);
          // Splash en posición actual
          f.spawnSplash(particles);
          // Saltar a posición aleatoria visible
          f.x = window.innerWidth  * (0.15 + Math.random() * 0.7);
          f.y = window.innerHeight * (0.2  + Math.random() * 0.55);
          f.swimT   += Math.PI * (0.5 + Math.random());
          f.state    = "SWIMMING";
          f.stateTimer = 0;
        }
      });
    }

    window.addEventListener("click",      handleTap);
    window.addEventListener("touchstart", handleTap, { passive: true });

    let last = performance.now(), animId;

    // Cache de cards: consultar el DOM 60 veces/seg es carísimo en móvil.
    // Se refresca cada 600ms, suficiente para filtros y scroll infinito.
    let cards = [], lastCardScan = 0;

    function loop(now) {
      const dt    = Math.min((now - last) / 1000, 0.05);
      last        = now;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      if (now - lastCardScan > 600) {
        cards = Array.from(document.querySelectorAll("[data-product-card]"));
        lastCardScan = now;
      }

      // ── Glow del dedo — muy sutil ─────────────────────────────────
      if (ptrX > 0) {
        const color = Math.hypot(fish[0].x - ptrX, fish[0].y - ptrY) <
                      Math.hypot(fish[1].x - ptrX, fish[1].y - ptrY)
          ? "0,212,255" : "255,68,238";
        const grad = ctx.createRadialGradient(ptrX, ptrY, 0, ptrX, ptrY, 130);
        grad.addColorStop(0, `rgba(${color},0.18)`);
        grad.addColorStop(0.5, `rgba(${color},0.06)`);
        grad.addColorStop(1, `rgba(${color},0)`);
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
      }

      // Partículas primero (detrás de los peces)
      for (let i = particles.length - 1; i >= 0; i--) {
        particles[i].update(dt);
        if (particles[i].life <= 0) particles.splice(i, 1);
        else particles[i].draw(ctx);
      }

      // Peces encima
      fish[0].update(dt, cards, particles); fish[0].draw(ctx, azulFrames);
      fish[1].update(dt, cards, particles); fish[1].draw(ctx, rosaFrames);

      animId = requestAnimationFrame(loop);
    }

    animId = requestAnimationFrame(loop);
    return () => {
      if ("requestIdleCallback" in window) cancelIdleCallback(idleId);
      else clearTimeout(idleId);
      cancelAnimationFrame(animId);
      window.removeEventListener("resize",     setSize);
      window.removeEventListener("mousemove",  onMove);
      window.removeEventListener("touchmove",  onMove);
      window.removeEventListener("click",      handleTap);
      window.removeEventListener("touchstart", handleTap);
document.head.removeChild(style);
    };
  }, []);

  return (
    <canvas ref={canvasRef} style={{
      position: "fixed", top: 0, left: 0,
      width: "100vw", height: "100vh",
      pointerEvents: "none", zIndex: 1,   // detrás de todo el contenido
    }} />
  );
}
