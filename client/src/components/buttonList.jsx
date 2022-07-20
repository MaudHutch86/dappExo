import { useState, useEffect} from "react";
import useEth from "../contexts/EthContext/useEth";

function ButtonList() {
  const { state: { contract, accounts } } = useEth();
  const [inputValue, setInputValue] = useState("");
  // const [votersList, setVotersList] = useState ([]);
  

  useEffect(() => {
    contract?.events.WorkflowStatusChange({}, (error, event) => {
      console.log(event);
    })

    contract?.events.VoterRegistered()
    .on("data", async (event) => {
      const voterRegistered= await contract.methods.getVoter(event.returnValues).call({from : accounts[0]});
      console.log(voterRegistered);
      //setProposalsList( proposalsList => event.returnValues.proposalId)  ;
      //console.log(ProposalList)
    })
    
  }, [contract]);
 
  const handleInputChange = e => {
    
      setInputValue(e.target.value);
    
  };

  // handle the button click to start the proposal registration

  const startRegistration = async () => {
    await contract.methods.startProposalsRegistering().send({ from: accounts[0] });
    
  };

  // handle the button click to end the proposal registration

  const endRegistration = async () => {
   await contract.methods.endProposalsRegistering().send({ from: accounts[0] });
    
  };

  // handle the button click to start the voting session


  const startVotingSession = async () => {
     await contract.methods.startVotingSession().send({ from: accounts[0] });
  
  };

 // handle the button click to end the voting session

  const endVotingSession = async () => {
     await contract.methods.endVotingSession().send({ from: accounts[0] });
    
  };

  const write = async e => {
    if (e.target.tagName === "INPUT") {
      return;
    }
    if (inputValue === "") {
      alert("Please add the voter address.");
      return;
    }
    const newValue = inputValue;
    

    await contract.methods.addVoter(newValue).send({ from: accounts[0] });
  };

  

    return (
        <div className="btn-group">
       
        <input
          id="addInput"
          type="text"
          placeholder="Add voter address"
          value={inputValue}
          onChange={handleInputChange}></input>
        <button id="addButton" onClick={write}> Add Voter to white list </button>
        <button onClick={startRegistration}> start registering proposal </button>
        <button onClick={endRegistration}> end registering proposal </button>
        <button onClick={startVotingSession}> start voting session </button>
        <button onClick={endVotingSession}> end voting session </button>
      </div>
    );
}

export default ButtonList;