import React, { useEffect, useState } from 'react';
import './App.css';
import SpotifyAuth from './components/SpotifyAuth';
import UserInfo from './components/UserInfo';
import Playlists from './components/Playlists';
import ImageUpload from './components/ImageUpload';

function App() {
  const [accessToken, setAccessToken] = useState(null);
  const [imageName, setimageName] = useState(null);
  // add playlist list

  const handleAuthorization = (token) => {
    setAccessToken(token)
  }

  const handleImageName = (imageName) => {
    setimageName(imageName)
  }

  return (
    <div className="App">
      {!accessToken ? (
        <SpotifyAuth onLogin={handleAuthorization}/>
      ) : (
        <div>
          <UserInfo accessToken={accessToken}/>
          <Playlists accessToken={accessToken}/>
          <ImageUpload/>
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
