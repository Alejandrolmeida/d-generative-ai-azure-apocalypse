import { FC } from "react";
import { Card, Col, Row } from "react-bootstrap";
import Copilot from "./components/Copilot";
import Notification from "./components/Notifications";

interface ComponentProps {}

const DashBoard: FC<ComponentProps> = () => {
  return (
    <>
      <Row>
        <Col xs={12} lg={5}>
          <Notification />
        </Col>
        <Col xs={12} lg={7}>
        <Card className="bg-black bg-opacity-50 p-2">
          <Copilot />
          </Card>
        </Col>
      </Row>
    </>
  );
};

export default DashBoard;
