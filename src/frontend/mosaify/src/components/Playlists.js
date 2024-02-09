import React, { useEffect, useState } from 'react';
import axios from 'axios';
import blankUser from '../BlankPlaylistImage.png';
import '../Playlists.css'

const Playlists = ({ accessToken }) => {
    const [playlists, setPlaylists] = useState(null);
    const [playlistList, setplaylistList] = useState(null);
    const [selectedPlaylistId, setSelectedPlaylistId] = useState(null);
    const userPlaylistsUrl = "https://api.spotify.com/v1/me/playlists"

    useEffect(() => {
        retrievePlaylists()
    }, []);

    useEffect(() => {
        if (playlists) {
            console.log("Creating playlist list elements")
            
            const listItems = playlists.map(playlist =>
                <li key={playlist.id}>
                    <div className='Playlist-container'>
                        <button onClick={() => handleSelectPlaylist(playlist.id)}>Select</button>
                        <img
                            src={playlist.url}
                        />
                        <p>{playlist.name}</p>
                    </div>
                </li>
            );
            setplaylistList(listItems);
        }
    }, [playlists]);

    useEffect(() => {
        if (selectedPlaylistId) {
            console.log(selectedPlaylistId)
        };
    }, [selectedPlaylistId]);

    const retrievePlaylists = () => {
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
        const playlistArray = data.items.map(item => ({
            id: item.id,
            name: item.name,
            url: item.images.length > 0 ? item.images[2].url : blankUser
        }));
        setPlaylists(playlistArray)
        }) 
        .catch(err => {
        console.log(err);
        });
    };

    const handleSelectPlaylist = (playlistId) => {
        setSelectedPlaylistId(playlistId);
    };

    return (
        <div>
            <ul id="playlists">{playlistList}</ul>
        </div>
    );
};

export default Playlists;