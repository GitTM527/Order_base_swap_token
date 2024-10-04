// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OrderBasedSwapModule = buildModule("OrderBasedSwapModule", (m) => {

  const _TobiXItoken= "0xaF0f737D7a4064a803E7714472C8618B9BdCFA83"
  const _TOBWeb3token = "0x095bD4e1C40098214e20a714B1AADA08d44f1113"
  
  const orderbasedswap = m.contract("OrderBasedSwap", [_TobiXItoken, _TOBWeb3token]);

  return { orderbasedswap };
});

export default OrderBasedSwapModule;
