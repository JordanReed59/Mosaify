import React, { useEffect, useState } from 'react';
import './App.css';
import SpotifyAuth from './components/SpotifyAuth';
import UserInfo from './components/UserInfo';

function App() {
  const [accessToken, setAccessToken] = useState(null);

  const handleAuthorization = (token) => {
    setAccessToken(token)
  }

  return (
    <div className="App">
      {!accessToken ? (
        <SpotifyAuth onLogin={handleAuthorization}/>
      ) : (
        <div>
          <UserInfo accessToken={accessToken}/>
          {/* <h1>Logged In</h1>
          <p>Access Token: {accessToken}</p> */}
        </div>
      )}
    </div>
  );

  // return (
    // <div className="App">
    //   <header className="App-header">
    //     {/* <ApiRequestComponent/> */}
    //     <SpotifyAuth/>
    //   </header>
    // </div>
  // );
}

export default App;
