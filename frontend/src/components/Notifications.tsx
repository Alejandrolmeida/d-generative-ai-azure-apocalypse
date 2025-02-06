import { useEffect, useState, useRef } from "react";
import { Card, Row, Col } from "react-bootstrap";
import store from "../common/redux/store";
import { connect } from "react-redux";
import { ThemeChanger } from "../common/redux/action";
import * as signalR from "@microsoft/signalr";
import CryptoJS from "crypto-js";

import Copilot_Service, {
  Copilot_Request,
} from "../services/Copilot_Service";

// Función para codificar en Base64URL
const base64url = (source: string): string => {
  return source.replace(/=+$/, '').replace(/\+/g, '-').replace(/\//g, '_');
};

// Función para generar el JWT manualmente
const generateJWT = (accessKey: string, audience: string): string => {
  const header = {
    alg: "HS256",
    typ: "JWT"
  };

  const payload = {
    aud: audience,
    exp: Math.floor(Date.now() / 1000) + 60 * 60, // Expira en 1 hora
  };

  const stringifiedHeader = JSON.stringify(header);
  const stringifiedPayload = JSON.stringify(payload);

  const encodedHeader = base64url(btoa(stringifiedHeader));
  const encodedPayload = base64url(btoa(stringifiedPayload));

  const signature = CryptoJS.HmacSHA256(
    `${encodedHeader}.${encodedPayload}`,
    accessKey
  );

  const encodedSignature = base64url(CryptoJS.enc.Base64.stringify(signature));

  return `${encodedHeader}.${encodedPayload}.${encodedSignature}`;
};


const Notifications: React.FC<{
  ThemeChanger: any;
}> = ({ ThemeChanger }) => {
  // const simulatedMessages = ["Alerta: CPU al 5%", "Alerta: GPU al 99%", "Alerta: Red saturada al 100%", "Alerta: Bases de datos con 1% de espacio libre",
  //   "Alerta: Uso de disco a 0%", "Alerta: Sobrecarga de solicitudes en el servidor", "Alerta: La temperatura del servidor ha caído a -5°C", "Alerta: Niveles de batería de respaldo al 2%",
  //   "Alerta: El sistema ha detectado un intento de acceso sin autenticación", "Alerta: El disco C: está corrupto"];
  const [messages, setMessages] = useState<string[]>([]);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let connection: signalR.HubConnection;

    const connectToSignalR = async () => {
      const accessKey: string = 'ZjzF5oL02u3F4CsdfahxZLkCPt9vd049Dy6bU6NhU2xmAMDJFe21JQQJ99BBACHYHv6XJ3w3AAAAASRSaHuI'; // Tu AccessKey
      const endpoint: string = 'https://dgenerativeai-signalr.service.signalr.net';
      const hubName: string = 'dgenerativeai';
      const audience: string = `${endpoint}/client/?hub=${hubName}`;

      // Generar el JWT manualmente
      const token: string = generateJWT(accessKey, audience);

      // Conectar a SignalR
      connection = new signalR.HubConnectionBuilder()
        .withUrl(`${endpoint}/client/?hub=${hubName}`, {
          accessTokenFactory: (): string => token,
        })
        .withAutomaticReconnect()
        .configureLogging(signalR.LogLevel.Information)
        .build();

      try {
        await connection.start();
        console.log("Conectado a SignalR en modo serverless");

        connection.on("ReceiveNotification", (msg: string) => {
          setMessages((prevMessages) => [...prevMessages, msg]);
        });
      } catch (err) {
        console.error("Error conectando a SignalR:", err);
      }
    };

   connectToSignalR();

    // Simulación de recepción de mensajes cada 5 segundos
    // let simulatedMessagesIndex = 0;
    // const intervalId = setInterval(() => {
    //   const simulatedMessage = `( ${new Date().toLocaleTimeString()} ) - ${simulatedMessages[simulatedMessagesIndex]}`;
    //   if (simulatedMessagesIndex === simulatedMessages.length - 1) {
    //     simulatedMessagesIndex = 0;
    //   } else {
    //     simulatedMessagesIndex++;
    //   }
    //   setMessages((prevMessages) => [...prevMessages, simulatedMessage]);
    // }, 20000);

    return () => {
      if (connection) connection.stop();
      // clearInterval(intervalId);
    };
  }, []);

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
    //LLm Call
    const fetchData = async () => {
      try {
        // Chat_Service;
        const request: Copilot_Request = {
          question: messages[messages.length - 1],
          chat_history: [], // Get the last 10 items
          alert_history: [],  
          isAlert:true,
        };
        // console.log(request);
        const resp = await Copilot_Service.getChatResp(request);
        console.log(resp.answerChat);
        ThemeChanger({
          ...store.getState(),
          alertMessage: resp.answerAlert,
        });

      } catch (error) {

      } finally {

      }
    };
    if (messages.length > 0){
      fetchData();
    }
  }, [messages]);

  return (
    <Card className="bg-black">
      <Card.Body>
        <Card.Title>Notificaciones</Card.Title>
        <div className="notifications-container scrollable-content mt-4">
          <Row className="copilot-body">
            <Col>
              {messages.slice().map((msg, index) => (
                <div
                  key={index}
                  className={
                    index === messages.length - 1
                      ? "text-danger"
                      : "text-danger text-opacity-50 mb-2"
                  }
                >
                  {msg}
                </div>
              ))}
              <div ref={messagesEndRef} />
            </Col>
          </Row>
        </div>
      </Card.Body>
    </Card>
  );
};

// export default Notifications;
const mapStateToProps = (state: any) => ({
  local_varaiable: state,
});

export default connect(mapStateToProps, { ThemeChanger })(Notifications);
