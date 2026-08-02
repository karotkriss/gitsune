mermaid.initialize({ startOnLoad: false, securityLevel: 'strict' });

async function gsRenderMermaid(source) {
  try {
    const { svg } = await mermaid.render('gs-mermaid-svg', source);
    const target = document.getElementById('diagram');
    target.innerHTML = svg;
    const rect = target.getBoundingClientRect();
    GsMermaid.postMessage(JSON.stringify({ ok: true, height: Math.ceil(rect.height) }));
  } catch (err) {
    GsMermaid.postMessage(JSON.stringify({ ok: false, error: String((err && err.message) || err) }));
  }
}
