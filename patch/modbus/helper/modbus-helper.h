#ifndef MODBUS_HELPER_H
#define MODBUS_HELPER_H

#include "ns3/object-factory.h"
#include "ns3/application-container.h"
#include "ns3/node-container.h"
#include "ns3/modbus-master-app.h"
#include "ns3/modbus-slave-app.h"

namespace ns3 {
namespace modbus {

class ModbusMasterHelper
{
public:
  ModbusMasterHelper();
  void SetAttribute (std::string name, const AttributeValue &value);
  ApplicationContainer Install (Ptr<Node> node) const;
  ApplicationContainer Install (NodeContainer c) const;
  Ptr<ModbusMasterApp> InstallPriv (Ptr<Node> node) const;
private:
  ObjectFactory m_factory;
};

class ModbusSlaveHelper
{
public:
  ModbusSlaveHelper();
  void SetAttribute (std::string name, const AttributeValue &value);
  ApplicationContainer Install (Ptr<Node> node) const;
  ApplicationContainer Install (NodeContainer c) const;
  Ptr<ModbusSlaveApp> InstallPriv (Ptr<Node> node) const;
private:
  ObjectFactory m_factory;
};

} // namespace modbus
} // namespace ns3

#endif // MODBUS_HELPER_H
