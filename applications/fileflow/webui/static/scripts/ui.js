const list = document.querySelector("#file-list");
const count = document.querySelector("#file-count");
const toast = document.querySelector("#toast");

export function showFiles(files, onDelete) {
  count.textContent = files.length;
  if (!files.length) {
    list.innerHTML =
      '<div class="empty"><strong>Your workspace is empty</strong>Upload the first file to start the flow.</div>';
    return;
  }
  list.replaceChildren(...files.map((file) => fileRow(file, onDelete)));
}

export function showLoading() {
  list.innerHTML = '<div class="empty">Loading files…</div>';
}

export function showLoadError() {
  list.innerHTML =
    '<div class="empty"><strong>Connection interrupted</strong>Try refreshing the list.</div>';
}

function fileRow(file, onDelete) {
  const row = document.createElement("article");
  row.className = "file-row";
  row.innerHTML = `
    <span class="file-icon"></span>
    <div class="file-info">
      <strong></strong>
      <small>${file.status} · ${formatBytes(file.size)} · ${new Date(file.createdAt).toLocaleString()}</small>
    </div>
    <a class="download" href="/api/files/${file.id}/content?download=true">Download</a>
    <button class="delete" type="button" aria-label="Delete file">×</button>`;
  row.querySelector(".file-icon").textContent = extension(file.name);
  row.querySelector("strong").textContent = file.name;
  row.querySelector(".delete").addEventListener("click", () => onDelete(file));
  return row;
}

function extension(name) {
  return (name.includes(".") ? name.split(".").pop() : "FILE")
    .slice(0, 4)
    .toUpperCase();
}

function formatBytes(bytes) {
  if (!bytes) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const index = Math.min(
    Math.floor(Math.log(bytes) / Math.log(1024)),
    units.length - 1,
  );
  return `${(bytes / 1024 ** index).toFixed(index ? 1 : 0)} ${units[index]}`;
}

let timer;
export function notify(message, error = false) {
  clearTimeout(timer);
  toast.textContent = message;
  toast.className = `toast show${error ? " error" : ""}`;
  timer = setTimeout(() => {
    toast.className = "toast";
  }, 2800);
}
