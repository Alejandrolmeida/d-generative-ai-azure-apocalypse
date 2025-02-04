import React, { useState, useEffect, useRef } from "react";
import { Container, Row, Col, OverlayTrigger, Tooltip } from "react-bootstrap";
import { Link } from "react-router-dom";
import SimpleBar from "simplebar-react"; // si quieres agregar un scroll personalizado
import "simplebar/dist/simplebar.min.css";
import ReactMarkdown from "react-markdown";

import Copilot_Service, {
  Copilot_Request,
  Copilot_History_Interface,
} from "../services/Copilot_Service";

const Copilot: React.FC = () => {
  //Constante para saber si el ancho es mayor a 768px
  // const isMdOrLarger = useMediaQuery({ query: "(max-width: 768px)" });

  //#region Chat Data
  const [inputValue, setInputValue] = useState("");
  const [messages, setMessages] = useState([
    {
      user: "bot",
      text: "Hola soy D-Generative-AI. ¿En que puedo ayudarte?.",
    },
  ]);
  const [chatHistory, setChatHistory] = useState<Copilot_History_Interface[]>(
    []
  );
  //#endregion

  //#region Manage Chat
  const [messageTextSend, setMessageTextSend] = useState<string>("");
  const handleClearChat = () => {
    setMessages([
      {
        user: "bot",
        text: `Hola soy D-Generative-AI. En que puedo ayudarte.`,
      },
    ]);
    setChatHistory([
      {
        inputs: { question: "Hola. Mi nombre es Alejandro" },
        outputs: {
          answer: `Hola soy D-Generative-AI. En que puedo ayudarte.`,
        },
      },
    ]);
  };

  const handleSendMessage = async () => {
    if (inputValue.trim()) {
      const newMessage = {
        user: "user",
        text: inputValue.trim(),
      };
      console.log(chatHistory);
      setMessages([...messages, newMessage]);
      setInputValue("");
      setMessageTextSend(inputValue.trim());
    }
  };
  //#endregion

  //#region Chat Line
  const ChatComponent = () => {
    const chatEndRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
      chatEndRef.current?.scrollIntoView();
    }, [messages]);

    return (
      <SimpleBar className="content-inner chat-content" id="main-chat-content">
        {messages.map((message: any, index: number) => (
          <div
            key={index}
            className={`media ${
              message.user === "user" ? "flex-row-reverse" : ""
            }`}
          >
            {/* <div className="">
                <i
                  className={`icon ${
                    message.user === "user" ? "fe fe-user" : "fe fe-robot"
                  }`}
                ></i>
              </div> */}
            <div className="media-body">
              <div
                className={`main-msg-wrapper ${
                  message.user === "user" ? "right" : "left"
                }`}
              >
                <ReactMarkdown>{message.text}</ReactMarkdown>
              </div>
              <div>
                <span>{new Date().toLocaleTimeString()}</span>{" "}
                <Link to="#">
                  <i className="icon ion-android-more-horizontal"></i>
                </Link>
              </div>
            </div>
          </div>
        ))}
        <div ref={chatEndRef} />
      </SimpleBar>
    );
  };
  //#endregion

  //#region input Textarea
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  // Función para ajustar la altura del textarea
  const adjustTextareaHeight = () => {
    if (textareaRef.current) {
      // Restablecer la altura y luego ajustarla según el scrollHeight
      textareaRef.current.style.height = "auto";
      const maxLines = 5;
      const lineHeight = 24; // Ajusta según el tamaño de fuente del textarea
      const maxHeight = maxLines * lineHeight;

      if (textareaRef.current.scrollHeight > maxHeight) {
        textareaRef.current.style.height = `${maxHeight}px`;
        textareaRef.current.style.overflowY = "auto";
      } else {
        textareaRef.current.style.height = `${textareaRef.current.scrollHeight}px`;
        textareaRef.current.style.overflowY = "hidden";
      }
    }
  };
  useEffect(() => {
    adjustTextareaHeight(); // Ajusta la altura al cargar el componente
  }, [inputValue]);
  //#endregion

  //#region useEffect Send Message
  useEffect(() => {
    const fetchData = async () => {
      try {
        // Chat_Service;
        const request: Copilot_Request = {
          question: messageTextSend,
          chat_history: chatHistory.slice(-10), // Get the last 10 items
        };
        console.log(request);
        const resp = await Copilot_Service.getChatResp(request);
        const botMessage = {
          user: "bot",
          text: resp.answer,
          assistant: resp.assistant,
        };
        setMessages((prevMessages) => [...prevMessages, botMessage]);
        setChatHistory([
          ...chatHistory,
          {
            inputs: { question: messageTextSend },
            outputs: { answer: resp.answer },
          },
        ]);
      } catch (error) {
        const botMessage = {
          user: "bot",
          text: "Lo siento ha fallado la conexión con el servidor.",
        };
        setMessages((prevMessages) => [...prevMessages, botMessage]);
      } finally {
        setMessageTextSend("");
      }
    };
    if (messageTextSend != "") {
      fetchData();
    }
  }, [messageTextSend]);
  //#endregion

  return (
    <>
      <Container fluid className="copilot-container">
        {/* Contenido del chat */}
        <Row className="copilot-body">
          <Col>
            <ChatComponent />
          </Col>
        </Row>
        {/* Pie para enviar mensajes */}
        <div className="input-container">
          <OverlayTrigger overlay={<Tooltip>New Chat</Tooltip>}>
            <div className="p-2">
              <button
                className="btn btn-icon btn-sm waves-effect btn-success-light rounded-pill btn-wave"
                onClick={handleClearChat}
              >
                N
              </button>
            </div>
          </OverlayTrigger>
          <textarea
            ref={textareaRef}
            placeholder={
              messageTextSend === ""
                ? "Escribe una pregunta..."
                : "Esperando respuesta..."
            }
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            rows={1}
            className="message-textarea"
            disabled={messageTextSend !== ""}
          />
          {messageTextSend === "" && (
            <button className="send-button" onClick={handleSendMessage}>
              ➤
            </button>
          )}
        </div>
      </Container>
    </>
  );
};

export default Copilot;
