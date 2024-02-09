import React, { useEffect, useState } from 'react';
import './App.css';
import SpotifyAuth from './components/SpotifyAuth';
import UserInfo from './components/UserInfo';
import Playlists from './components/Playlists';

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
          <Playlists accessToken={accessToken}/>
        </div>
      )}
    </div>
  );
}

export default App;
