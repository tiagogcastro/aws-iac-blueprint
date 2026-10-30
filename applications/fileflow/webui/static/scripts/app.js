import { getFiles, removeFile, uploadFile } from "./api.js";
import { notify, showFiles, showLoadError, showLoading } from "./ui.js";

const input = document.querySelector("#file-input");
const dropZone = document.querySelector("#drop-zone");
const progress = document.querySelector("#progress");

async function loadFiles() {
  showLoading();
  try {
    showFiles(await getFiles(), deleteFile);
  } catch (error) {
    showLoadError();
    notify(error.message, true);
  }
}

async function upload(file) {
  progress.hidden = false;
  try {
    await uploadFile(file);
    notify(`${file.name} uploaded`);
    input.value = "";
    await loadFiles();
  } catch (error) {
    notify(error.message, true);
  } finally {
    progress.hidden = true;
  }
}

async function deleteFile(file) {
  if (!window.confirm(`Delete ${file.name}?`)) return;
  try {
    await removeFile(file.id);
    notify(`${file.name} deleted`);
    await loadFiles();
  } catch (error) {
    notify(error.message, true);
  }
}

document.querySelector("#browse-button").addEventListener("click", (event) => {
  event.stopPropagation();
  input.click();
});
document.querySelector("#refresh-button").addEventListener("click", loadFiles);
dropZone.addEventListener("click", () => input.click());
input.addEventListener(
  "change",
  () => input.files[0] && upload(input.files[0]),
);

for (const name of ["dragenter", "dragover", "dragleave", "drop"]) {
  dropZone.addEventListener(name, (event) => event.preventDefault());
}
dropZone.addEventListener("dragover", () => dropZone.classList.add("dragging"));
dropZone.addEventListener("dragleave", () =>
  dropZone.classList.remove("dragging"),
);
dropZone.addEventListener("drop", (event) => {
  dropZone.classList.remove("dragging");
  if (event.dataTransfer.files[0]) upload(event.dataTransfer.files[0]);
});

loadFiles();
