// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Project {
    enum ProjectState { Ongoing, Successful, Failed }

    struct Donation {
        address donor;
        uint256 amount;
    }

    address public creator;
    string public description;
    uint256 public goalAmount;
    uint256 public deadline;
    uint256 public currentAmount;
    ProjectState public state;
    Donation[] public donations;

    event DonationReceived(address indexed donor, uint256 amount);
    event ProjectStateChanged(ProjectState indexed newState);
    event FundsWithdrawn(address indexed creator, uint256 amount);
    event FundsRefunded(address indexed donor, uint256 amount);

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can call this function");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp >= deadline, "The deadline has not passed yet");
        _;
    }

    function initialize(address _creator, string memory _description, uint256 _goalAmount, uint256 _duration) public {
        creator = _creator;
        description = _description;
        goalAmount = _goalAmount;
        deadline = block.timestamp + _duration;
        state = ProjectState.Ongoing;
    }

    function donate() external payable {
        require(state == ProjectState.Ongoing, "The project is not ongoing");
        require(block.timestamp < deadline, "Project deadline has passed");

        donations.push(Donation({
            donor: msg.sender,
            amount: msg.value
        }));

        currentAmount += msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyCreator onlyAfterDeadline {
        require(state == ProjectState.Successful, "The project is not successful");

        uint256 amount = address(this).balance;
        payable(creator).transfer(amount);

        emit FundsWithdrawn(creator, amount);
    }

    function refund() external onlyAfterDeadline {
        require(state == ProjectState.Failed, "The project is not failed");

        uint256 totalRefund = 0;
        for (uint i = 0; i < donations.length; i++) {
            if (donations[i].donor == msg.sender) {
                totalRefund += donations[i].amount;
                donations[i].amount = 0; // Mark as refunded
            }
        }

        require(totalRefund > 0, "No funds to refund");
        
        payable(msg.sender).transfer(totalRefund);

        emit FundsRefunded(msg.sender, totalRefund);
    }

    function updateProjectState() external onlyAfterDeadline {
        require(state == ProjectState.Ongoing, "Project is already finalized");

        if (currentAmount >= goalAmount) {
            state = ProjectState.Successful;
        } else {
            state = ProjectState.Failed;
        }
    }
}