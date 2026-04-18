// This will automatically be routed to Flask by the Ingress Load Balancer
const fetchHealth = async () => {
  const response = await fetch("/api/v1/health");
  const data = await response.json();
  console.log(data);
};
