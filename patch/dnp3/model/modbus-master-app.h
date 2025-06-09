/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */

#ifndef MODBUS_MASTER_APP_H
#define MODBUS_MASTER_APP_H

#include "ns3/application.h"
#include "ns3/socket.h"
#include "ns3/network-module.h"

namespace ns3 {

class ModbusMasterApp : public Application
{
public:
  static TypeId GetTypeId (void);
  ModbusMasterApp ();
  virtual ~ModbusMasterApp ();

protected:
  virtual void StartApplication (void);
  virtual void StopApplication (void);

private:
  void SendData (void);
  void ConnectionSucceeded (Ptr<Socket> socket);
  void ConnectionFailed (Ptr<Socket> socket);

  Ptr<Socket> m_socket;
  Address     m_peerAddress;
  uint16_t    m_peerPort;
  uint32_t    m_packetSize;
  DataRate    m_dataRate;
};

} // namespace ns3
#endif
