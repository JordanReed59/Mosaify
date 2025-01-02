import React, { useEffect, useState } from 'react';
import './App.css';
import SpotifyAuth from './components/SpotifyAuth';
import UserInfo from './components/UserInfo';
import Playlists from './components/Playlists';
import ImageUpload from './components/ImageUpload';
import Uploader from './components/Test';

function App() {
  const [accessToken, setAccessToken] = useState(null);
  const [imageName, setImageName] = useState(null);
  const [playlistList, setPlaylistList] = useState(null);
  // const [file, setFile] = useState(null);
  // const [url, setUrl] = useState(null);
  // add playlist list

  const handleAuthorization = (token) => {
    setAccessToken(token)
  }

  const handleImageName = (imageName) => {
    console.log("Parent values set")
    setImageName(imageName)
    console.log(imageName)
    // setFile(file)
    // setUrl(url)
    // console.log(file)
    // console.log(url)
  }

  const handlePlaylist = (playlistList) => {
    setPlaylistList(playlistList)
    console.log("App log: " + playlistList)
  }

  return (
    <div className="App">
      {/* <Uploader/> */}
      {!accessToken ? (
        <SpotifyAuth onLogin={handleAuthorization}/>
        ) : (
          <div>
          <UserInfo accessToken={accessToken}/>
          <Playlists accessToken={accessToken} onSelect={handlePlaylist}/>
          <ImageUpload onUpload={handleImageName}/>
          {/* {(playlistList && file) && <button onClick={handleUpload}>Upload</button>} */}
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
