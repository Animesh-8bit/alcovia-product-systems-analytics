// Minimal stand-in for the dashboard runtime, so the page runs offline from a folder.
(function () {
  const DATA = window.AX_DATA || {};
  const calcs = {}, cache = {}, draws = [], onDataFns = [];
  let params = Object.assign({}, window.AX_PARAMS);
  let ready = false, pending = false;
  const ok = (rows) => ({ status: 'ok', data: rows, rows, columns: rows.length ? Object.keys(rows[0]) : [], refreshing: false, meta: [] });
  function data(id) {
    if (DATA[id]) return ok(DATA[id]);
    if (calcs[id]) {
      if (!cache[id]) cache[id] = calcs[id].fn(...calcs[id].inputs.map((i) => data(i).data));
      return ok(cache[id]);
    }
    return { status: 'missing', data: [], rows: [], columns: [], meta: [] };
  }
  const visible = (el) => !el.closest('[hidden]');
  function runDraw(d) {
    document.querySelectorAll('[data-draw="' + d.name + '"]').forEach((el) => {
      if (!visible(el)) return;
      try { d.fn(el); } catch (e) { console.error('draw ' + d.name, e); }
    });
  }
  function runAll() {
    onDataFns.forEach((f) => { try { f(); } catch (e) { console.error(e); } });
    draws.forEach(runDraw);
  }
  function schedule() {
    if (!ready || pending) return;
    pending = true;
    requestAnimationFrame(() => { pending = false; runAll(); });
  }
  window.dash = {
    data,
    calc(id, c) { calcs[id] = c; },
    loader() {},
    draw(name, fn) {
      const f = typeof fn === 'function' ? fn : (el) => fn.update && fn.update(el, fn.mount && fn.mount(el));
      const d = { name, fn: f };
      draws.push(d);
      if (ready) runDraw(d);
    },
    onData(fn) { onDataFns.push(fn); if (ready) fn(); },
    params() { return Object.assign({}, params); },
    setParams(o) {
      Object.entries(o).forEach(([k, v]) => { if (v == null || v === '') delete params[k]; else params[k] = v; });
      schedule();
    },
    resetParams() { params = Object.assign({}, window.AX_PARAMS); schedule(); },
    setLink(name) { try { history.replaceState(null, '', '#' + name); } catch (e) {} schedule(); },
    refresh() {},
    colors: ['#3b7dd8', '#d9822b', '#2e9e74', '#9b59b6', '#e05a7a', '#7f8c3a', '#5b6bbf', '#a0703c'],
  };
  document.addEventListener('DOMContentLoaded', () => { ready = true; runAll(); });
  let w = window.innerWidth;
  window.addEventListener('resize', () => { if (window.innerWidth !== w) { w = window.innerWidth; schedule(); } });
})();
