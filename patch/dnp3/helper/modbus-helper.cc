#include "modbus-helper.h"
#include "ns3/names.h"

namespace ns3 {

ModbusMasterHelper::ModbusMasterHelper()
{
  m_factory.SetTypeId("ns3::ModbusMasterApp");
}

void ModbusMasterHelper::SetAttribute(std::string name, const AttributeValue &value)
{
  m_factory.Set(name, value);
}

ApplicationContainer ModbusMasterHelper::Install(Ptr<Node> node) const
{
  return ApplicationContainer(InstallPriv(node));
}

ApplicationContainer ModbusMasterHelper::Install(NodeContainer c) const
{
  ApplicationContainer apps;
  for (auto i = c.Begin(); i != c.End(); ++i)
    {
      apps.Add(InstallPriv(*i));
    }
  return apps;
}

Ptr<ModbusMasterApp> ModbusMasterHelper::InstallPriv(Ptr<Node> node) const
{
  Ptr<ModbusMasterApp> app = m_factory.Create<ModbusMasterApp>();
  node->AddApplication(app);
  return app;
}

ModbusSlaveHelper::ModbusSlaveHelper()
{
  m_factory.SetTypeId("ns3::ModbusSlaveApp");
}

void ModbusSlaveHelper::SetAttribute(std::string name, const AttributeValue &value)
{
  m_factory.Set(name, value);
}

ApplicationContainer ModbusSlaveHelper::Install(Ptr<Node> node) const
{
  return ApplicationContainer(InstallPriv(node));
}

ApplicationContainer ModbusSlaveHelper::Install(NodeContainer c) const
{
  ApplicationContainer apps;
  for (auto i = c.Begin(); i != c.End(); ++i)
    {
      apps.Add(InstallPriv(*i));
    }
  return apps;
}

Ptr<ModbusSlaveApp> ModbusSlaveHelper::InstallPriv(Ptr<Node> node) const
{
  Ptr<ModbusSlaveApp> app = m_factory.Create<ModbusSlaveApp>();
  node->AddApplication(app);
  return app;
}

} // namespace ns3
