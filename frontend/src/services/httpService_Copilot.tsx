import axios from "axios";

export const http = axios.create({
  // baseURL: "https://copilotcsp.azurewebsites.net/",
  baseURL: "https://app-prodwareazurecopilot-assistant-001-aydneph2abcpeqer.spaincentral-01.azurewebsites.net/",
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 'ApiKey': 'c66b5486-b22e-49f8-8738-62fbb55ac9c5'
  },
  timeout: 30,
});
export default http;