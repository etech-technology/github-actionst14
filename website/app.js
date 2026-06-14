const button = document.getElementById("deploymentButton");
const status = document.getElementById("status");

button.addEventListener("click", () => {
  const deployedAt = new Date().toLocaleString();
  status.textContent = `Deployment verified from the browser by elvis at ${deployedAt}.`;
});
