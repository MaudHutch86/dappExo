// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

 /**

     * @title Voting dapp
     * @author Maud Hutchinson
     * @dev Contract module that allows to {owner} to grant right to vote .
     * voters can propose a proposal and vote for their favoutite ones. 
     * the winning proposal will be given when voting session is effectively ended.
   
*/


contract Voting is Ownable {

    uint public winningProposalID;
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum  WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public workflowStatus = WorkflowStatus.RegisteringVoters;
    Proposal[]  public proposalsArray;
    mapping (address => Voter) voters;


    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    /**
     * @dev Requires msg.sender to be registered.
     */

    modifier onlyVoters() {
        require(voters[msg.sender].isRegistered, "You're not a voter");
        _;
    }
    
     /**
     * @notice Returns the voter.
     * @dev Returns voter address.
     * @param _addr is the address of the voter.
     */


    function getVoter(address _addr) external onlyVoters view returns (Voter memory) {
        return voters[_addr];
    }

     /**
     * @notice Returns a proposal by its id.
     * @dev Returns proposal by id.
     */

    
    function getOneProposal(uint _id) external onlyVoters view returns (Proposal memory) {
        return proposalsArray[_id];
    }

     /**
     * @notice Returns all the proposal registered.
     * @dev Returns list of proposals.
     */


    function getAllProposals() public view returns ( Proposal [] memory) {
         return proposalsArray;
    }

     /**
     * @notice Returns the winning proposal.
     * @dev Returns  winning proposal.
     */


    function getWinningProposalID() external view returns ( uint){
        return winningProposalID;
    }

     /**
     * @notice Returns the current voting status.
     * @dev Returns current status.
     */


    function getCurrentStatus() external view returns(WorkflowStatus) {
        return workflowStatus;
    }

 
     /**
     * @dev Add voter.
     * @param _addr is added to mapping of voters.
     * if voter is registered.

     * Requirements :

     * -workflow status must be open for voter registration.

     * -must have only owner role.

     * May emit a voterRegistered event.
     */


    function addVoter(address _addr) external onlyOwner {
        require(voters[_addr].isRegistered != true, 'Already registered');
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');        
    
        voters[_addr].isRegistered = true;
        emit VoterRegistered(_addr);
    }
 

     /**
     * @notice Add a proposal
     * @param _desc is a string
     * @dev Add a proposal.

     * Requirements :

     * -workflow status must be started for proposal registration.

     * -must have voter role.

     * -must forbid empty strings.

     * May emit a proposalRegistered event.
     */

    function addProposal(string memory _desc) external onlyVoters {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Proposals are not allowed yet');
        require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")), 'Vous ne pouvez pas ne rien proposer'); // facultatif
        // voir que desc est different des autres

        Proposal memory proposal;
        proposal.description = _desc;
        proposalsArray.push(proposal);
        emit ProposalRegistered(proposalsArray.length-1);
    }



    /**
     * @dev Set Vote 

     * @param _id is of uint type and vote is made using _id.

     * Requirements :

     * - workflow status voting session must be open.

     * - must have voter role.

     * - voter should not have voted yet.

     * - can only allow vote for existing proposal.

     * May emit a voted event.
     */


    function setVote( uint _id) external onlyVoters {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        require(voters[msg.sender].hasVoted != true, 'You have already voted');
        require(_id < proposalsArray.length, 'Proposal not found'); // pas obligé, et pas besoin du >0 car uint

        voters[msg.sender].votedProposalId = _id;
        voters[msg.sender].hasVoted = true;
        proposalsArray[_id].voteCount++;

        emit Voted(msg.sender, _id);
    }

     /**
     * @dev Start proposal registration session 
     * 

     * Requirements :

     * -workflow status must allow proposal registration.

     * -must have only owner role.

     * May emit a workflowStatusChange (start proposal session) event.
     */


    function startProposalsRegistering() external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Registering proposals cant be started now');
        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    /**
     * @dev end proposal registration session 
     * 

     * requirements :

     * -workflow status must allow proposal registration ending.

     * -must have only owner role.

     * May emit a workflowStatusChange (end proposal session) event.
     */


    function endProposalsRegistering() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Registering proposals havent started yet');
        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }
    /**
     * @dev start voting session 
     * 

     * requirements :

     * -workflow status must allow voting session starting.

     * -must have only owner role.

     * May emit a workflowStatusChange (start voting session) event.
     */


    function startVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, 'Registering proposals phase is not finished');
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

     /**
     * @dev End voting session 
     * 

     * Requirements :

     * -workflow status must allow voting session ending.

     * -must have only owner role.

     * May emit a workflowStatusChange (end voting session) event.
     */


    function endVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

     /**
     * @notice calculates and gives the winning proposal.
     * @dev Caculates the total of votes and gives the winning proposal
     * 

     * Requirements :

     * -workflow status must be voting session ended.

     * -must have only owner role.

     * May emit a workflowStatusChange (votesTallies true) event.
     */



   function tallyVotes() external onlyOwner {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
       uint _winningProposalId;
      for (uint256 p = 0; p < proposalsArray.length; p++) {
           if (proposalsArray[p].voteCount > proposalsArray[_winningProposalId].voteCount) {
               _winningProposalId = p;
          }
          if (proposalsArray.length == 50){
            break;
          }
       }
       winningProposalID = _winningProposalId;
       
       workflowStatus = WorkflowStatus.VotesTallied;
       emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }
}