pragma solidity ^0.4.24;

import "../token/ERC20/ERC20.sol";


contract ERC223ContractInterface {
  function tokenFallback(address _from, uint256 _value, bytes _data) external;
}


contract ERC223TokenMock is ERC20 {

  constructor(address _initialAccount, uint256 _initialBalance) public {
    _mint(_initialAccount, _initialBalance);
  }

  // ERC223 compatible transfer function (except the name)
  function transferERC223(address _to, uint256 _value, bytes _data) public
    returns (bool success)
  {
    transfer(_to, _value);
    bool isContract = false;
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      isContract := not(iszero(extcodesize(_to)))
    }
    if (isContract) {
      ERC223ContractInterface receiver = ERC223ContractInterface(_to);
      receiver.tokenFallback(msg.sender, _value, _data);
    }
    return true;
  }
}
