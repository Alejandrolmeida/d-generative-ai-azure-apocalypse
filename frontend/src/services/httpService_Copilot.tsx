import axios from "axios";

export const http = axios.create({
  // baseURL: "https://copilotcsp.azurewebsites.net/",
  baseURL: "https://app-prodwareazurecopilot-assistant-001-aydneph2abcpeqer.spaincentral-01.azurewebsites.net/",
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 'ApiKey': '<key>'
  },
  timeout: 30,
});
export default http;