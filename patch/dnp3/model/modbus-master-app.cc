/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */

#include "modbus-master-app.h"
#include "ns3/log.h"
#include "ns3/socket-factory.h"
#include "ns3/inet-socket-address.h"
#include "ns3/inet6-socket-address.h"
#include "ns3/simulator.h"
#include "ns3/uinteger.h"

namespace ns3 {

NS_LOG_COMPONENT_DEFINE ("ModbusMasterApp");

TypeId
ModbusMasterApp::GetTypeId (void)
{
  static TypeId tid = TypeId ("ns3::ModbusMasterApp")
    .SetParent<Application> ()
    .SetGroupName ("Applications")
    .AddConstructor<ModbusMasterApp> ()
    .AddAttribute ("PeerAddress", "Remote address of the Modbus slave", AddressValue (),
                   MakeAddressAccessor (&ModbusMasterApp::m_peerAddress),
                   MakeAddressChecker ())
    .AddAttribute ("PeerPort", "Remote port of the Modbus slave", UintegerValue (502),
                   MakeUintegerAccessor (&ModbusMasterApp::m_peerPort),
                   MakeUintegerChecker<uint16_t> ())
    .AddAttribute ("PacketSize", "Size of Modbus request packets", UintegerValue (12),
                   MakeUintegerAccessor (&ModbusMasterApp::m_packetSize),
                   MakeUintegerChecker<uint32_t> ())
    .AddAttribute ("DataRate", "Data rate for sending packets", DataRateValue (DataRate ("1Mbps")),
                   MakeDataRateAccessor (&ModbusMasterApp::m_dataRate),
                   MakeDataRateChecker ());
  return tid;
}

ModbusMasterApp::ModbusMasterApp ()
  : m_socket (0),
    m_peerPort (502),
    m_packetSize (12),
    m_dataRate ("1Mbps")
{
}

ModbusMasterApp::~ModbusMasterApp ()
{
  m_socket = 0;
}

void
ModbusMasterApp::StartApplication (void)
{
  NS_LOG_FUNCTION (this);

  if (!m_socket)
    {
      TypeId tid = TypeId::LookupByName ("ns3::TcpSocketFactory");
      m_socket = Socket::CreateSocket (GetNode (), tid);
      m_socket->SetConnectCallback (
        MakeCallback (&ModbusMasterApp::ConnectionSucceeded, this),
        MakeCallback (&ModbusMasterApp::ConnectionFailed, this));
    }

  if (InetSocketAddress::IsMatchingType (m_peerAddress))
    {
      m_socket->Connect (InetSocketAddress (Ipv4Address::ConvertFrom (m_peerAddress), m_peerPort));
    }
  else if (Inet6SocketAddress::IsMatchingType (m_peerAddress))
    {
      m_socket->Connect (Inet6SocketAddress (Ipv6Address::ConvertFrom (m_peerAddress), m_peerPort));
    }
}

void
ModbusMasterApp::StopApplication (void)
{
  NS_LOG_FUNCTION (this);

  if (m_socket)
    {
      m_socket->Close ();
      m_socket = 0;
    }
}

void
ModbusMasterApp::ConnectionSucceeded (Ptr<Socket> socket)
{
  NS_LOG_FUNCTION (this << socket);
  Simulator::ScheduleNow (&ModbusMasterApp::SendData, this);
}

void
ModbusMasterApp::ConnectionFailed (Ptr<Socket> socket)
{
  NS_LOG_FUNCTION (this << socket);
}

void
ModbusMasterApp::SendData (void)
{
  NS_LOG_FUNCTION (this);

  uint8_t buf[] = {
    0x00, 0x01,       // Transaction ID
    0x00, 0x00,       // Protocol ID
    0x00, 0x06,       // Length
    0x01,             // Unit Identifier
    0x01,             // Function Code: Read Coils
    0x00, 0x01,       // Starting Address
    0x00, 0x0A        // Quantity of coils (10)
  };

  Ptr<Packet> packet = Create<Packet> (buf, sizeof (buf));
  m_socket->Send (packet);
}

} // namespace ns3

