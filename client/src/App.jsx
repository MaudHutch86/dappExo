import { EthProvider } from "./contexts/EthContext";
import "./App.css";
import Main from "./components/main";

function App() {
  return (
    <EthProvider>
      <Main/>
    </EthProvider>
  );
}

export default App;
