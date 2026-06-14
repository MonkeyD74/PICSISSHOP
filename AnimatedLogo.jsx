"use client";
import { useRef, useEffect } from "react";
import "./AnimatedLogo.css";

export default function AnimatedLogo() {
  const videoRef = useRef(null);

  useEffect(() => {
    // Autoplay con fallback silencioso (política de navegadores)
    videoRef.current?.play().catch(() => {});
  }, []);

  return (
    <section className="logoHero">
      <video
        ref={videoRef}
        src="/logopicsisshop.mp4"
        autoPlay
        muted
        loop
        playsInline
        className="mainLogo"
      />
    </section>
  );
}
