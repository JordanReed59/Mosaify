import logo from './logo.svg';
import './App.css';
import ApiRequestComponent from './components/ApiRequestComponent';
import SpotifyAuth from './components/SpotifyAuth';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        {/* <ApiRequestComponent/> */}
        <SpotifyAuth/>
      </header>
    </div>
  );
}

export default App;
