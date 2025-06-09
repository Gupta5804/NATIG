/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */

#ifndef MODBUS_SLAVE_APP_H
#define MODBUS_SLAVE_APP_H

#include "ns3/application.h"
#include "ns3/socket.h"
#include "ns3/network-module.h"

namespace ns3 {

class ModbusSlaveApp : public Application
{
public:
  static TypeId GetTypeId (void);
  ModbusSlaveApp ();
  virtual ~ModbusSlaveApp ();

protected:
  virtual void StartApplication (void);
  virtual void StopApplication (void);

private:
  void HandleRead (Ptr<Socket> socket);
  void HandleAccept (Ptr<Socket> s, const Address& from);

  Ptr<Socket> m_socket;
  uint16_t    m_localPort;
  std::list<Ptr<Socket>> m_socketList;
};

} // namespace ns3
#endif
