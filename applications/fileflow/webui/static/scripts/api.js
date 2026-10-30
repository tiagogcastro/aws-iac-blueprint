async function parse(response) {
  if (response.status === 204) return;
  const body = await response.json();
  if (!response.ok) throw new Error(body.error || "Request failed");
  return body;
}

export async function getFiles() {
  const body = await parse(await fetch("/api/files"));
  return body.files;
}

export async function uploadFile(file) {
  const form = new FormData();
  form.append("file", file);
  return parse(await fetch("/api/files", { method: "POST", body: form }));
}

export async function removeFile(id) {
  return parse(await fetch(`/api/files/${id}`, { method: "DELETE" }));
}
