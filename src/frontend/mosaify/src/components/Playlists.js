import React, { useEffect, useState } from 'react';
import axios from 'axios';
import blankUser from '../BlankPlaylistImage.png';
import '../Playlists.css'

const Playlists = ({ accessToken }) => {
    const [playlists, setPlaylists] = useState(null);
    // const [userImageUrl, setuserImageUrl] = useState(null);
    const userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists"

    axios({
        url: userPlaylistsUrl,
        method: 'get',
        headers: {
            'Authorization': `Bearer ${accessToken}`
        }
    })
    .then(response => {
    const data = response.data
    const total = data.total
    console.log(data)
    console.log(total)
    var playlistArray = []
    for(let i=0; i < total; i++) {
        const name = data.items[i].name
        var url = blankUser
        if (data.items[i].images.length > 0) {
            url = data.items[i].images[2]['url']
        };
        const imageUrl = url
        console.log(name)
        console.log(imageUrl)
        var playlistDict = {name: name, url: url}
        playlistArray.push(playlistDict)
        // var list = document.getElementById('playlists')
        // var listElement = document.createElement("li");
        // var div = document.createElement("div");
        // var img = document.createElement("img");
        // var test = document.createElement("p");
        // div.setAttribute('className', 'Playlist-container');
        // div.setAttribute('src', imageUrl);
    };
    setPlaylists(playlistArray)
    }) 
    .catch(err => {
    console.log(err);
    });

    const listItems = playlists.map(playlist =>
        <li>
            <div className='Playlist-container'>
                <img
                    src={playlist.url}
                />
                <p>{playlist.name}</p>
            </div>
        </li>
    );
    
    return (
        <div>
            <ul id="playlists">{listItems}</ul>
        </div>
    );
};

export default Playlists;