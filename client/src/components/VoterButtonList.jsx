import { useState, useEffect} from "react";
import useEth from "../contexts/EthContext/useEth";

function VoterButtonList() {
  const { state: { contract, accounts } } = useEth();
  const [inputValue, setInputValue] = useState("");
  const [proposalId, setVoting] = useState(0);
  //const [proposalsList, setProposalsList] = useState([]);


  useEffect(() => {
    contract?.events.WorkflowStatusChange({}, (error, event) => {
      console.log(event);
    })
    
    contract?.events.ProposalRegistered()
    .on("data", async (event) => {
      const proposalRegistered = await contract.methods.getOneProposal(event.returnValues.proposalId).call({from : accounts[0]});
      console.log(proposalRegistered);
      //setProposalsList( proposalsList => event.returnValues.proposalId)  ;
      // console.log(proposalsList)
    })
    // eslint-disable-next-line
   
  }, [contract]);

  const handleInputChange = e => {
    
      setInputValue(e.target.value);
   
    
  };

  const handleVoting = e => {
    
    setVoting(e.target.value);
     
};

  // handle the button click to start the proposal registration

  const writeProposal = async e => {
    if (e.target.tagName === "INPUT") {
      return;
    }
    if (inputValue === "") {
      alert("Please add the voter address.");
      return;
    }
    const newValue = inputValue;
    
     if (contract !== null){
      await contract.methods.addProposal(newValue).send({ from: accounts[0] });
     }
  
   
   

  };

  // handle the voting using the index 

  const ProposalVoting = async () => {
    
  
    const proposalIndex = parseInt(proposalId);
    if (contract !== null) {
    await contract.methods.setVote(proposalIndex).send({ from: accounts[0] });
   }
   
   
  };

  


    return (
        <div className="btn-group">
        <input
          id="addInput"
          type="text"
          placeholder="Add your proposal"
          value={inputValue}
          onChange={handleInputChange}></input>
        <button id="addButton" onClick={writeProposal}> Add Proposal </button>
        <input
          id="addIndex"
          type="text"
          placeholder="Select index of the proposal"
          value={proposalId}
          onChange={handleVoting}></input>

        <button onClick={ProposalVoting}> Vote </button>
       
       
      </div>
    );
}

export default VoterButtonList;