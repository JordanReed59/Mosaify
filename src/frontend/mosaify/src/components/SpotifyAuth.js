import React, { useEffect, useState } from 'react';
import axios from 'axios';
import CryptoJS from 'crypto-js';

const SpotifyAuth = ({ onLogin }) => {
  // const [accessToken, setAccessToken] = useState(null);
  const clientId = process.env.REACT_APP_CLIENT_ID;
  const redirectUri = process.env.REACT_APP_REDIRECT_URI;
  const scope = 'user-read-private user-read-email';
  const authUrl = new URL("https://accounts.spotify.com/authorize");
  const tokenUrl = "https://accounts.spotify.com/api/token"

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get('code');
    // console.log("I only fire once")

    if (code) {
      getToken(code);
    }
  }, []);

  const handleAuthorization = () => {
    const codeVerifier = generateRandomString(128);
    const codeChallenge = base64URL(CryptoJS.SHA256(codeVerifier));
    // console.log(codeVerifier);
    // console.log(codeChallenge);
    window.localStorage.setItem('code_verifier', codeVerifier);

    const params = {
      response_type: 'code',
      client_id: clientId,
      scope,
      code_challenge_method: 'S256',
      code_challenge: codeChallenge,
      redirect_uri: redirectUri,
    };

    authUrl.search = new URLSearchParams(params).toString();
    window.location.href = authUrl.toString();
  };

  const generateRandomString = (length) => {
    const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const values = crypto.getRandomValues(new Uint8Array(length));
    return Array.from(values)
      .map((x) => possible[x % possible.length])
      .join('');
  };

  const base64URL = (str) => {
    return str.toString(CryptoJS.enc.Base64)
      .replace(/=/g, '')
      .replace(/\+/g, '-')
      .replace(/\//g, '_');
  };

  const getToken = async (code) => {
    try {
      const codeVerifier = localStorage.getItem('code_verifier');
      const payload = {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          client_id: clientId,
          grant_type: 'authorization_code',
          code,
          redirect_uri: redirectUri,
          code_verifier: codeVerifier,
        }).toString(),
      };
      // console.log(payload.body);

      const response = await fetch(tokenUrl, payload);
      const data = await response.json();
      // console.log(`Access token: ${data.access_token}`)
      // setAccessToken(data.access_token);
      onLogin(data.access_token);
    } catch (error) {
      console.error('Error fetching token:', error);
    }
  };

  return (
    <div>
      <h2>Login to Spotify</h2>
      <button onClick={handleAuthorization}>Authorize with Spotify</button>
    </div>
  );
  // return (
  //   <div>
  //     <h2>Login to Spotify</h2>
  //     {accessToken ? (
  //       <p>Access Token: {accessToken}</p>
  //     ) : (
  //       <button onClick={handleAuthorization}>Authorize with Spotify</button>
  //     )}
  //   </div>
  // );
};

export default SpotifyAuth;
