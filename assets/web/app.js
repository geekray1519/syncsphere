// DOM Elements
const DOM = {
  connect: document.getElementById('connect'),
  dashboard: document.getElementById('dashboard'),
  unsupported: document.getElementById('unsupported'),
  statusText: document.getElementById('status-text'),
  statusDot: document.getElementById('status-dot'),
  tabs: document.querySelectorAll('.tab'),
  tabContents: document.querySelectorAll('.tab-content'),
  btnPickFolder: document.getElementById('btn-pick-folder'),
  btnSyncNow: document.getElementById('btn-sync-now'),
  syncStatus: document.getElementById('sync-status'),
  fileList: document.getElementById('file-list'),
  syncCount: document.getElementById('sync-count'),
  syncSize: document.getElementById('sync-size'),
  dropZone: document.getElementById('drop-zone'),
  fileInput: document.getElementById('file-input'),
  transferList: document.getElementById('transfer-list'),
  btnForceTransfer: document.getElementById('btn-force-transfer'),
  deviceName: document.getElementById('device-name')
};

// State
let ws = null;
let currentDirHandle = null;
let isSyncing = false;
let db = null;
let currentDownload = null;

// Utils
function formatSize(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024, sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function formatDate(ts) {
  return new Date(ts).toLocaleString('ja-JP');
}

function showToast(message, type = 'success') {
  const t = document.createElement('div');
  t.className = `toast ${type}`;
  t.textContent = message;
  document.getElementById('toast-container').appendChild(t);
  setTimeout(() => {
    t.style.opacity = '0';
    t.style.transform = 'translateY(20px)';
    setTimeout(() => t.remove(), 300);
  }, 3000);
}

function updateProgress(current, total, text) {
  document.getElementById('sync-current-file').textContent = text;
  const pct = total === 0 ? 100 : Math.round((current / total) * 100);
  document.getElementById('sync-percentage').textContent = pct + '%';
  document.getElementById('sync-progress-bar').style.width = pct + '%';
}

function getFileIcon(filename) {
  if (filename.endsWith('/')) return '📁';
  const ext = filename.split('.').pop().toLowerCase();
  const icons = { jpg:'🖼️', jpeg:'🖼️', png:'🖼️', gif:'🖼️', mp4:'🎥', mp3:'🎵', pdf:'📄', zip:'📦' };
  return icons[ext] || '📄';
}

async function hashFile(file) {
  const buffer = await file.arrayBuffer();
  const hash = await crypto.subtle.digest('SHA-256', buffer);
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, '0')).join('');
}

// IndexedDB
const DB_NAME = 'syncsphere', STORE_NAME = 'handles';
const idbReq = indexedDB.open(DB_NAME, 1);
idbReq.onupgradeneeded = e => e.target.result.createObjectStore(STORE_NAME);
idbReq.onsuccess = e => { 
  db = e.target.result;
  loadHandle().then(handle => {
    if (handle) restoreSession(handle);
  });
};

function saveHandle(handle) {
  const tx = db.transaction(STORE_NAME, 'readwrite');
  tx.objectStore(STORE_NAME).put(handle, 'sync-dir');
}

async function loadHandle() {
  return new Promise(resolve => {
    const tx = db.transaction(STORE_NAME, 'readonly');
    const req = tx.objectStore(STORE_NAME).get('sync-dir');
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => resolve(null);
  });
}

// WebSocket Management
function connectWS() {
  ws = new WebSocket(`ws://${location.host}/ws`);
  ws.binaryType = 'arraybuffer';
  
  ws.onopen = () => {
    DOM.statusText.textContent = '接続完了';
    DOM.statusDot.classList.add('connected');
    DOM.connect.hidden = true;
    
    if (!('showDirectoryPicker' in window)) {
      DOM.unsupported.hidden = false;
    } else {
      DOM.dashboard.hidden = false;
    }
    
    ws.send(JSON.stringify({ type: 'hello', device: navigator.userAgent }));
  };
  
  ws.onclose = () => {
    DOM.statusText.textContent = '再接続中...';
    DOM.statusDot.classList.remove('connected');
    setTimeout(connectWS, 3000);
  };

  ws.onmessage = async (e) => {
    if (e.data instanceof ArrayBuffer) {
      if (currentDownload && currentDownload.stream) {
        await currentDownload.stream.write(e.data);
      }
      return;
    }
    
    try {
      const msg = JSON.parse(e.data);
      
      if (msg.type === 'device_info') {
        DOM.deviceName.textContent = msg.name;
      } else if (msg.type === 'sync_plan') {
        handleSyncPlan(msg.plan);
      } else if (msg.type === 'download_start') {
        const handle = await getFileHandle(currentDirHandle, msg.path, true);
        currentDownload = { stream: await handle.createWritable(), path: msg.path };
      } else if (msg.type === 'download_complete') {
        if (currentDownload && currentDownload.stream) {
          await currentDownload.stream.close();
          showToast(`ダウンロード完了: ${currentDownload.path}`);
          currentDownload = null;
        }
      }
    } catch (err) {
      console.error('WS parse error', err);
    }
  };
}

// FSA Helpers
async function getFileHandle(dirHandle, path, create = false) {
  const parts = path.split('/');
  let curr = dirHandle;
  for (let i = 0; i < parts.length - 1; i++) {
    curr = await curr.getDirectoryHandle(parts[i], { create });
  }
  return await curr.getFileHandle(parts[parts.length - 1], { create });
}

async function scanDirectory(dirHandle, basePath = '') {
  const files = [];
  for await (const [name, handle] of dirHandle.entries()) {
    const path = basePath ? `${basePath}/${name}` : name;
    if (handle.kind === 'file') {
      const file = await handle.getFile();
      files.push({ path, size: file.size, modified: file.lastModified, isDir: false });
    } else {
      files.push({ path, size: 0, modified: 0, isDir: true });
      const subFiles = await scanDirectory(handle, path);
      files.push(...subFiles);
    }
  }
  return files;
}

// Folder Sync
async function pickSyncFolder() {
  if (!('showDirectoryPicker' in window)) {
    DOM.dashboard.hidden = true;
    DOM.unsupported.hidden = false;
    return;
  }
  try {
    const dirHandle = await window.showDirectoryPicker({ mode: 'readwrite' });
    await saveHandle(dirHandle);
    await restoreSession(dirHandle);
  } catch (err) {
    console.error('Pick folder cancelled or failed', err);
  }
}

async function restoreSession(dirHandle) {
  try {
    const permission = await dirHandle.requestPermission({ mode: 'readwrite' });
    if (permission !== 'granted') return;
    
    currentDirHandle = dirHandle;
    DOM.btnPickFolder.innerHTML = `📁 ${dirHandle.name} を同期中`;
    
    const files = await scanDirectory(dirHandle);
    renderFileList(files);
    
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ type: 'file_list', files }));
    }
  } catch(e) { console.error('Restore error', e); }
}

function renderFileList(files) {
  DOM.fileList.innerHTML = '';
  if (files.length === 0) {
    DOM.fileList.innerHTML = '<div class="empty-state">フォルダは空です</div>';
    return;
  }
  files.forEach(f => {
    const div = document.createElement('div');
    div.className = 'file-item';
    div.innerHTML = `
      <div class="file-info">
        <span class="file-icon">${f.isDir ? '📁' : getFileIcon(f.path)}</span>
        <span class="file-name">${f.path}</span>
      </div>
      <div class="file-meta">
        <span>${formatSize(f.size)}</span>
        <span>${formatDate(f.modified)}</span>
      </div>
    `;
    DOM.fileList.appendChild(div);
  });
  DOM.syncCount.textContent = files.length;
  DOM.syncSize.textContent = formatSize(files.reduce((a,b) => a + b.size, 0));
}

function handleSyncPlan(plan) {
  DOM.syncStatus.classList.remove('hidden');
  updateProgress(0, 100, '同期プランの確認');
  DOM.btnSyncNow.hidden = false;
  
  DOM.fileList.innerHTML = '';
  const addItems = (list, icon) => {
    if (!list) return;
    list.forEach(item => {
      const div = document.createElement('div');
      div.className = 'file-item';
      div.innerHTML = `
        <div class="file-info">
          <span class="file-icon">${icon}</span>
          <span class="file-name">${item.path}</span>
        </div>
      `;
      DOM.fileList.appendChild(div);
    });
  };
  addItems(plan.upload, '↑');
  addItems(plan.download, '↓');
  addItems(plan.conflicts, '⚠️');
  
  DOM.btnSyncNow.onclick = () => executeSyncPlan(plan);
}

async function executeSyncPlan(plan) {
  DOM.btnSyncNow.hidden = true;
  isSyncing = true;
  DOM.syncStatus.classList.remove('hidden');
  let total = (plan.upload?.length || 0) + (plan.download?.length || 0);
  let done = 0;
  
  if (plan.upload) {
    for (let item of plan.upload) {
      updateProgress(done, total, `アップロード: ${item.path}`);
      const handle = await getFileHandle(currentDirHandle, item.path);
      const file = await handle.getFile();
      
      ws.send(JSON.stringify({ type: 'upload_start', path: item.path, size: file.size }));
      const CHUNK_SIZE = 1024 * 1024;
      let offset = 0;
      while (offset < file.size) {
        const chunk = file.slice(offset, offset + CHUNK_SIZE);
        const buffer = await chunk.arrayBuffer();
        ws.send(buffer);
        offset += buffer.byteLength;
      }
      const hash = await hashFile(file);
      ws.send(JSON.stringify({ type: 'upload_complete', path: item.path, hash }));
      done++;
    }
  }
  
  ws.send(JSON.stringify({ type: 'start_downloads' }));
  updateProgress(done, total, done === total ? '同期完了！' : '同期中...');
  if (done === total && (!plan.download || plan.download.length === 0)) {
    isSyncing = false;
    showToast('同期完了！');
    setTimeout(() => { DOM.syncStatus.classList.add('hidden'); }, 3000);
  }
}

// Polling
setInterval(async () => {
  if (ws && ws.readyState === WebSocket.OPEN && currentDirHandle && !isSyncing) {
    const files = await scanDirectory(currentDirHandle);
    ws.send(JSON.stringify({ type: 'file_list', files }));
  }
}, 10000);

// Quick Transfer
function uploadQuickTransfer(files) {
  DOM.transferList.classList.remove('hidden');
  Array.from(files).forEach(file => {
    const id = 'tf-' + Math.random().toString(36).substr(2, 9);
    const item = document.createElement('div');
    item.className = 'file-item';
    item.id = id;
    item.innerHTML = `
      <div class="file-info">
        <span class="file-icon">${getFileIcon(file.name)}</span>
        <span class="file-name">${file.name}</span>
      </div>
      <div class="file-meta"><span class="progress-text">0%</span></div>
    `;
    DOM.transferList.prepend(item);
    
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/upload', true);
    xhr.upload.onprogress = e => {
      if (e.lengthComputable) {
        const percent = Math.round((e.loaded / e.total) * 100);
        document.querySelector(`#${id} .progress-text`).textContent = percent + '%';
      }
    };
    xhr.onload = () => {
      document.querySelector(`#${id} .progress-text`).textContent = '完了';
      showToast(`${file.name} のアップロード完了`);
    };
    xhr.onerror = () => {
      document.querySelector(`#${id} .progress-text`).textContent = 'エラー';
      showToast(`${file.name} のアップロード失敗`, 'error');
    };
    const fd = new FormData();
    fd.append('file', file);
    xhr.send(fd);
  });
}

// Events
DOM.tabs.forEach(tab => {
  tab.onclick = () => {
    DOM.tabs.forEach(t => t.classList.remove('active'));
    DOM.tabContents.forEach(c => c.classList.remove('active'));
    tab.classList.add('active');
    document.getElementById(tab.dataset.target).classList.add('active');
  };
});

DOM.btnPickFolder.onclick = pickSyncFolder;
DOM.btnForceTransfer.onclick = () => {
  DOM.unsupported.hidden = true;
  DOM.dashboard.hidden = false;
  DOM.tabs[1].click();
};

DOM.dropZone.ondragover = e => { e.preventDefault(); DOM.dropZone.classList.add('dragover'); };
DOM.dropZone.ondragleave = () => DOM.dropZone.classList.remove('dragover');
DOM.dropZone.ondrop = e => {
  e.preventDefault();
  DOM.dropZone.classList.remove('dragover');
  uploadQuickTransfer(e.dataTransfer.files);
};
DOM.dropZone.onclick = () => DOM.fileInput.click();
DOM.fileInput.onchange = e => uploadQuickTransfer(e.target.files);

// Start
connectWS();