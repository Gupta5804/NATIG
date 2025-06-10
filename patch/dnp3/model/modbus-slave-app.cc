/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */

#include "modbus-slave-app.h"
#include "ns3/log.h"
#include "ns3/socket-factory.h"
#include "ns3/inet-socket-address.h"
#include "ns3/inet6-socket-address.h"
#include "ns3/simulator.h"
#include <algorithm>
#include <list>

namespace ns3 {

NS_LOG_COMPONENT_DEFINE ("ModbusSlaveApp");

TypeId
ModbusSlaveApp::GetTypeId (void)
{
  static TypeId tid = TypeId ("ns3::ModbusSlaveApp")
    .SetParent<Application> ()
    .SetGroupName ("Applications")
    .AddConstructor<ModbusSlaveApp> ()
    .AddAttribute ("LocalPort", "Listening port", UintegerValue (502),
                   MakeUintegerAccessor (&ModbusSlaveApp::m_localPort),
                   MakeUintegerChecker<uint16_t> ());
  return tid;
}

ModbusSlaveApp::ModbusSlaveApp ()
  : m_socket (0),
    m_localPort (502)
{
}

ModbusSlaveApp::~ModbusSlaveApp ()
{
  m_socket = 0;
}

void
ModbusSlaveApp::StartApplication (void)
{
  NS_LOG_FUNCTION (this);

  if (!m_socket)
    {
      TypeId tid = TypeId::LookupByName ("ns3::TcpSocketFactory");
      m_socket = Socket::CreateSocket (GetNode (), tid);

      InetSocketAddress local = InetSocketAddress (Ipv4Address::GetAny (), m_localPort);
      m_socket->Bind (local);
      m_socket->Listen ();

      m_socket->SetAcceptCallback (
        MakeNullCallback<bool, Ptr<Socket>, const Address &> (),
        MakeCallback (&ModbusSlaveApp::HandleAccept, this));
    }
}

void
ModbusSlaveApp::StopApplication (void)
{
  NS_LOG_FUNCTION (this);

  while (!m_socketList.empty ())
    {
      Ptr<Socket> accepted = m_socketList.front ();
      m_socketList.pop_front ();
      accepted->Close ();
    }

  if (m_socket)
    {
      m_socket->Close ();
      m_socket = 0;
    }
}

void
ModbusSlaveApp::HandleAccept (Ptr<Socket> s, const Address& from)
{
  NS_LOG_FUNCTION (this << s << from);
  s->SetRecvCallback (MakeCallback (&ModbusSlaveApp::HandleRead, this));
  m_socketList.push_back (s);
}

void
ModbusSlaveApp::HandleRead (Ptr<Socket> socket)
{
  NS_LOG_FUNCTION (this << socket);
  Address from;
  Ptr<Packet> packet;

  while ((packet = socket->RecvFrom (from)))
    {
      uint32_t size = packet->GetSize ();
      if (size < 8)
        {
          continue;
        }

      uint8_t buf[12];
      uint32_t copySize = std::min<uint32_t> (size, sizeof(buf));
      packet->CopyData (buf, copySize);

      uint8_t functionCode = buf[7];
      if (functionCode == 0x01 && size >= 12)
        {
          uint8_t unitId = buf[6];

          uint8_t resp[] = {
            buf[0], buf[1],               // Transaction ID
            buf[2], buf[3],               // Protocol ID
            0x00, 0x05,                   // Length
            unitId,                       // Unit ID
            0x01,                         // Function Code
            0x02,                         // Byte Count
            0x00,                         // Coil status byte 1
            0x00                          // Coil status byte 2
          };

          Ptr<Packet> response = Create<Packet> (resp, sizeof (resp));
          socket->Send (response);
        }
    }
}

} // namespace ns3

