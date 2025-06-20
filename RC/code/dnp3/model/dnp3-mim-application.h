/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright 2007 University of Washington
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author:  Tom Henderson (tomhend@u.washington.edu)
 */

#ifndef DNP3_APPLICATION_H
#define DNP3_APPLICATION_H

#include "ns3/application.h"
#include "ns3/event-id.h"
#include "ns3/ptr.h"
#include "ns3/traced-callback.h"
#include "ns3/address.h"
#include "ns3/random-variable-stream.h"
#include "ns3/address-utils.h"
#include "ns3/simulator-impl.h"
#include "ns3/scheduler.h"
#include "ns3/event-impl.h"
#include "ns3/ptr.h"
#include "ns3/application.h"

#include <list>
#include <map>
#include "ns3/endpoint.hpp"
#include "ns3/station.hpp"
#include "ns3/common.hpp"
#include "ns3/master.hpp"
#include "ns3/lpdu.hpp"
#include "ns3/outstation.hpp"
#include "ns3/timer_interface.hpp"
#include "ns3/traced-callback.h"
#include "ns3/dummy_timer.hpp"
#include "ns3/event_interface.hpp"
#include "ns3/traced-callback.h"

namespace ns3 {

class Address;
class Socket;
class Packet;

/**
 * \ingroup applications
 * \defgroup packetsink PacketSink
 *
 * This application was written to complement OnOffApplication, but it
 * is more general so a PacketSink name was selected.  Functionally it is
 * important to use in multicast situations, so that reception of the layer-2
 * multicast frames of interest are enabled, but it is also useful for
 * unicast as an example of how you can write something simple to receive
 * packets at the application layer.  Also, if an IP stack generates
 * ICMP Port Unreachable errors, receiving applications will be needed.
 */

/**
 * \ingroup packetsink
 *
 * \brief Receive and consume traffic generated to an IP address and port
 *
 * This application was written to complement OnOffApplication, but it
 * is more general so a PacketSink name was selected.  Functionally it is
 * important to use in multicast situations, so that reception of the layer-2
 * multicast frames of interest are enabled, but it is also useful for
 * unicast as an example of how you can write something simple to receive
 * packets at the application layer.  Also, if an IP stack generates
 * ICMP Port Unreachable errors, receiving applications will be needed.
 *
 * The constructor specifies the Address (IP address and port) and the
 * transport protocol to use.   A virtual Receive () method is installed
 * as a callback on the receiving socket.  By default, when logging is
 * enabled, it prints out the size of packets and their address.
 * A tracing source to Receive() is also available.
 */
class Dnp3Application : public Application, public EventInterface
{
public:
    //Type of control for send
    enum ControlType  {
	SELECT_OPERATE                               = 0x00,
	DIRECT                                   = 0x01,
	DIRECT_NO_RESP                                 = 0x02
    };

  /**
   * \brief Get the type ID.
   * \return the object TypeId
   */
  static TypeId GetTypeId (void);

  Dnp3Application ();

  virtual ~Dnp3Application ();

  /**
   * \return the total bytes received in this sink app
   */
  uint32_t GetTotalRx () const;

  /**
   * \return pointer to listening socket
   */
  Ptr<Socket> GetListeningSocket (void) const;

  /**
   * \return list of pointers to accepted sockets
   */
  std::list<Ptr<Socket> > GetAcceptedSockets (void) const;

  /**
   * \brief set the name
   * \param name name
   */
  void SetName (const std::string &name);
  /**
   * \brief set the local address and port
   * \param ip local IPv4 address
   * \param port local port
   */
  void SetLocal (Ipv4Address ip, uint16_t port);
  /**
   * \brief set the local address and port
   * \param ip local IPv6 address
   * \param port local port
   */
  void SetLocal (Ipv6Address ip, uint16_t port);
  /**
   * \brief set the local address and port
   * \param ip local IP address
   * \param port local port
   */
  void SetLocal (Address ip, uint16_t port);

  void Store(std::string point, std::string value);

  // implementation of EventInterface
    void changePoint(DnpAddr_t addr, DnpIndex_t index,
                 PointType_t    pointType,
                 int value, DnpTime_t timestamp=0);

    void registerName(       DnpAddr_t      addr,
                 DnpIndex_t index,
                 EventInterface::PointType_t    pointType,
                 char*          name,
                 int initialValue );

    std::string GetName (void) const;
    Address m_localAddress; //!< Local address
    uint16_t m_localPort; //!< Local port
    Address m_remoteAddress; //!< Local address
    uint16_t m_remotelPort; //!< Local port
    std::string m_name; //!< name of this application
    std::string f_name; //!< name of the output file
    bool m_isMaster; //Flag to indicate master or outstation
    double m_jitterMinNs; //!<minimum jitter delay time for packets sent via FNCS
    double m_jitterMaxNs; //!<maximum jitter delay time for packets sent via FNCS
protected:
  virtual void DoDispose (void);
private:
  // inherited from Application base class.
  virtual void StartApplication (void);    // Called at time specified by Start
  virtual void StopApplication (void);     // Called at time specified by Stop
  void startMaster (void);
  void startOutstation (Ptr<Socket> sock);
  /**
   * \brief Handle a packet received by the application
   * \param socket the receiving socket
   */
  void HandleRead (Ptr<Socket> socket);
  /**
   * \brief Handle an incoming connection
   * \param socket the incoming connection socket
   * \param from the address the connection is from
   */
  void HandleAccept (Ptr<Socket> socket, const Address& from);
  /**
   * \brief Handle an connection close
   * \param socket the connected socket
   */
  void HandlePeerClose (Ptr<Socket> socket);
  /**
   * \brief Handle an connection error
   * \param socket the connected socket
   */
  void HandlePeerError (Ptr<Socket> socket);

  void ConnectToPeer(Ptr<Socket> localSocket, uint16_t servPort);

  void periodic_poll(int count);
  void store_points(std::string point, std::string value);
  void initConfig(void);
  void makeTcpConnection(void);
  void makeUdpConnection(void);
  void handle_MIM(Ptr<Socket> socket);
  void handle_normal(Ptr<Socket> socket);
  void set_attack(bool state);
  void send_directly(Ptr<Packet> packet);
  void send_control_binary(Dnp3Application::ControlType type, DnpIndex_t index, ControlOutputRelayBlock::Code code);
  void send_control_analog(Dnp3Application::ControlType type, DnpIndex_t index, double value);

  // Socket used for both TCP and UDP operation
  Ptr<Socket>     m_socket;        //!< Application socket
  std::list<Ptr<Socket> > m_socketList; //!< the accepted sockets

  Address         m_local;        //!< Local address to bind to
  uint32_t        m_totalRx;      //!< Total bytes received
  TypeId          m_tid;          //!< Protocol TypeId

  /// Traced Callback: received packets, source address.
  TracedCallback<Ptr<const Packet>, const Address &> m_rxTrace;
  int debugLevel;
  int respTimeout;
  int integrityPollInterval;

  uint16_t m_integrityInterval;
  uint16_t m_master_device_addr;
  uint16_t m_station_device_addr;
  Master::MasterConfig          masterConfig;
  Station::StationConfig        stationConfig;
  Datalink::DatalinkConfig      datalinkConfig;
  Endpoint::EndpointConfig      endpointConfig;
  Outstation::OutstationConfig  outstationConfig;
  RemoteDevice remoteDevice;
  std::map<uint16_t, RemoteDevice>  deviceMap;
  Master* m_p;
  Outstation* o_p;
  DummyTimer ti;
  bool m_enableTcp;
  bool m_connected;
  int m_input_select;
  int m_victim;
  Ptr<UniformRandomVariable> m_rand_delay_ns; //!<random value used to add jitter to packet transmission
  /// Callbacks for tracing the packet Tx events
  TracedCallback<Ptr<const Packet> > m_txTrace;
  map<string, float> analog_points;
  map<string, uint16_t> bin_points;
  vector<string> binary_point_names;
  vector<string> analog_point_names;
  static const int MAX_LEN = 77;
  uint16_t m_attackType;
  uint16_t m_attackStartTime;
  uint16_t m_attackEndTime;
  bool m_attack_on;
};

} // namespace ns3

#endif /* DNP3_APPLICATION_H */

