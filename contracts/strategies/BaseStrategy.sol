// SPDX-License-Identifier: MIT

pragma solidity =0.8.3;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/INFT.sol";
import "../interfaces/INFTFactory.sol";
import "../interfaces/IStrategy.sol";
import "../libraries/TokenHelper.sol";

abstract contract BaseStrategy is Initializable, IStrategy {
    using TokenHelper for address;

    Status public override status;
    address public override token;
    address public override owner;
    uint256 public override tokenId;
    uint256 public override amount;
    address public override recipient;
    address public override currency;
    uint256 public override endBlock;

    modifier whenSaleOpen {
        require(status == Status.OPEN, "SHOYU: SALE_NOT_OPEN");
        _;
    }

    function __BaseStrategy_init(
        address _owner,
        uint256 _tokenId,
        uint256 _amount
    ) internal initializer {
        token = msg.sender;
        owner = _owner;
        tokenId = _tokenId;
        amount = _amount;
    }

    function currentPrice() public view virtual override returns (uint256);

    function _cancel() internal {
        require(msg.sender == owner, "SHOYU: FORBIDDEN");
        status = Status.CANCELLED;
    }

    function _buy(uint256 price) internal {
        uint256 _currentPrice = currentPrice();
        require(price >= _currentPrice, "SHOYU: INVALID_PRICE");
        require(block.number <= endBlock, "SHOYU: EXPIRED");

        (address _token, uint256 _tokenId, uint256 _amount) = (token, tokenId, amount);

        status = Status.FINISHED;
        INFT(_token).closeSale(_tokenId, _amount);

        INFT(_token).safeTransferFrom(owner, msg.sender, _tokenId, _amount);

        address _currency = currency;
        address factory = INFT(token).factory();
        address feeTo = INFTFactory(factory).feeTo();
        uint256 feeAmount = (_currentPrice * INFTFactory(factory).fee()) / 1000;
        _currency.safeTransferFromSender(feeTo, feeAmount);
        _currency.safeTransferFromSender(recipient, _currentPrice - feeAmount);
    }
}
