import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';
function App() {
  const [health, setHealth] = useState('Checking API…');
  const [message, setMessage] = useState('Loading database status…');
  useEffect(() => {
    fetch('/api/health').then(r => r.json()).then(d => setHealth(`API ${d.status}`)).catch(() => setHealth('API unavailable'));
    fetch('/api/').then(r => r.json()).then(d => setMessage(d.message)).catch(() => setMessage('Backend connection failed'));
  }, []);
  return <main><nav><span className="logo">☁</span><strong>Cloud Platform</strong><span className="tag">EKS · GitOps Demo</span></nav><section className="hero"><p className="eyebrow">THREE-TIER APPLICATION</p><h1>Ship confidently.<br/><em>Operate visibly.</em></h1><p className="intro">A sample cloud-native application deployed on Amazon EKS with Terraform, GitHub Actions, Argo CD, Prometheus and Grafana.</p><div className="status"><span className="dot"/> {health}</div></section><section className="panel"><h2>Live application response</h2><p>{message}</p><div className="tiers"><article><small>01 / PRESENTATION</small><h3>React + NGINX</h3><p>Static frontend served by a lightweight NGINX container.</p></article><article><small>02 / APPLICATION</small><h3>Node.js API</h3><p>Express API with health and Prometheus metrics endpoints.</p></article><article><small>03 / DATA</small><h3>PostgreSQL</h3><p>Persistent relational data running as a Kubernetes StatefulSet.</p></article></div></section><footer>Built for hands-on DevOps learning · Replace this demo with your own production workload.</footer></main>
}
createRoot(document.getElementById('root')).render(<App />);
