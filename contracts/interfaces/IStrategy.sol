// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IStrategy {
    enum Status {OPEN, CANCELLED, FINISHED}

    function status() external view returns (Status);

    function token() external view returns (address);

    function owner() external view returns (address);

    function tokenId() external view returns (uint256);

    function amount() external view returns (uint256);

    function recipient() external view returns (address);

    function currency() external view returns (address);

    function endBlock() external view returns (uint256);

    function currentPrice() external view returns (uint256);

    function initialize(
        address _owner,
        uint256 _tokenId,
        uint256 _amount,
        bytes calldata _config
    ) external;

    function cancel() external;
}
