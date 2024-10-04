import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TOBWeb3Module = buildModule("TOBWeb3Module", (m) => {

    const erc20 = m.contract("TOBWeb3");

    return { erc20 };
});

export default TOBWeb3Module;