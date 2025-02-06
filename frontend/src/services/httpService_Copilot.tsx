import axios from "axios";

export const http = axios.create({
  // baseURL: "https://copilotcsp.azurewebsites.net/",
  baseURL: "https://app-dgenerative-assistant-001.azurewebsites.net/",
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 'ApiKey': '<key>'
  },
  timeout: 300000,
});
export default http;