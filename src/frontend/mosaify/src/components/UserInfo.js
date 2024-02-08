import React, { useEffect, useState } from 'react';
import axios from 'axios';

const UserInfo = ({ accessToken }) => {
    const [userDisplayName, setUserDisplayName] = useState(null);
    const [userImageUrl, setuserImageUrl] = useState(null);
    const userInfoUrl = "https://api.spotify.com/v1/me"

    axios({
        url: userInfoUrl,
        method: 'get',
        headers: {
            'Authorization': `Bearer ${accessToken}`
        }
     })
     .then(response => {
        setUserDisplayName(response.data.display_name)
        setuserImageUrl(response.data.images[0].url)
        // create 64x64 blank user image to use if the image array has a length of 0
        console.log(userImageUrl)
     }) 
     .catch(err => {
        console.log(err);
     });
    return (
        <div>
            <h1> Welcome {userDisplayName}!</h1>
            <img src={userImageUrl}/>
        </div>
    );
};

export default UserInfo;