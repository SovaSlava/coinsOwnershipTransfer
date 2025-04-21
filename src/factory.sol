// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;
import "openzeppelin-contracts/access/Ownable2step.sol";
import "./Wallet.sol";
contract Factory is Ownable(msg.sender) {

    event newWalletCreated(address indexed walletAddress);
    address public feeReceiver;
    uint public feeAmount;
    constructor(uint _feeAmount) {
        feeReceiver = msg.sender;
        feeAmount = _feeAmount;
    }

    function changeFeeReceiver(address newFeeReceiver) external onlyOwner {
        feeReceiver = newFeeReceiver;
    }

    function changeFeeAmount(uint newFeeAmount) external onlyOwner {
        feeAmount = newFeeAmount;
    }

    function createNewWallet(
        uint timeOut, // time, while contract will wait user reaction
        address[] calldata newOwners // new owners of wallet, if user will not call contract
    ) external payable {
        require(msg.value >= feeAmount, "fee");
        require(timeOut > 0, "timeOut");
        require(newOwners.length > 0, "at least 1 future owner");
        uint initValue = msg.value > feeAmount ? msg.value - feeAmount : 0;
        Wallet newWallet = new Wallet{value: initValue}(msg.sender, timeOut, newOwners);
        emit newWalletCreated(address(newWallet));
    }

}