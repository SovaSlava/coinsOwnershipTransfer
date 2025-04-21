// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;
import "openzeppelin-contracts/access/Ownable2step.sol";

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract Wallet is Ownable{

    uint public timeOut;
    address[] public futureOwners;
    uint public lastActionTimestamp;
    constructor(address owner, uint _timeOut, address[] memory _futureOwners) payable Ownable(owner) {
        timeOut = _timeOut;
        futureOwners = _futureOwners;
        lastActionTimestamp = block.timestamp;
    }

    modifier updateTimer() {
        lastActionTimestamp = block.timestamp;
        _;
    }

    function changeTimeOut(uint newTimeout) external onlyOwner updateTimer {
        timeOut = newTimeout;

    }

    function changeFutureOwners(address[] calldata newFutureOwners) external onlyOwner updateTimer{
        futureOwners = newFutureOwners;
    }

    function execute(address to, uint value, bytes memory _data) external payable onlyOwner updateTimer returns(bytes memory) {
        (bool success, bytes memory result) = to.call{value: value}(_data);
        require(success, string(result));
        return result;

    }

    function becomesOwner() external {
        require(block.timestamp - lastActionTimestamp > timeOut, "too early");
        for(uint i=0; i < futureOwners.length; i++) {
            if(msg.sender == futureOwners[i]) {
                _transferOwnership(msg.sender);
                lastActionTimestamp = block.timestamp;
                delete futureOwners;
                break;
            }
        }
    }

    function iamalive() external onlyOwner {
        lastActionTimestamp = block.timestamp;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // top-up
    receive() external payable {}
}