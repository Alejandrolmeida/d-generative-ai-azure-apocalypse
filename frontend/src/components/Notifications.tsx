import { useEffect, useState, useRef } from "react";
import { Card, Row, Col } from "react-bootstrap";
import * as signalR from "@microsoft/signalr";

const Notifications: React.FC = () => {
  const [messages, setMessages] = useState<string[]>([]);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const connection = new signalR.HubConnectionBuilder()
      .withUrl("https://TU_AZURE_SIGNALR_URL")
      .withAutomaticReconnect()
      .build();

    connection
      .start()
      .then(() => console.log("Conectado a SignalR"))
      .catch((err) => console.error("Error conectando a SignalR:", err));

    connection.on("ReceiveNotification", (msg: string) => {
      setMessages((prevMessages) => [...prevMessages, msg]);
    });

    // // Simulación de recepción de mensajes cada 5 segundos
    // const intervalId = setInterval(() => {
    //   const simulatedMessage = `( ${new Date().toLocaleTimeString()} ) - Mensaje simulado`;
    //   setMessages((prevMessages) => [...prevMessages, simulatedMessage]);
    // }, 10000);

    return () => {
      connection.stop();
      // clearInterval(intervalId);
    };
  }, []);

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
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

export default Notifications;
