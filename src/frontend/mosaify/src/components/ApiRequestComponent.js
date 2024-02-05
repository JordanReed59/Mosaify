import React, { useState } from 'react';
import axios from 'axios';

const ApiRequestComponent = () => {
  const [responseMsg, setResponseMsg] = useState(null);
  const [error, setError] = useState(null);
  const requestData = {
    authorizationCode: 'value1'
    // codeVerifier: "value2",
    // clientId: "value3",
    // redirectUri: "http://localhost:3000"
  };
  const headers = {
    "Content-Type": "application/json"
  };

  const fetchData = async () => {
    try {
      const apiUrl = '/test/auth';
      const response = await axios.post(apiUrl, requestData, {
        headers: headers
      });
  
      if (response.status === 200) {
        const responseData = response.data;
        setResponseMsg(responseData.msg);
        setError(null);
      } else {
        setError('An error occurred');
        setResponseMsg(null);
      }
    } catch (error) {
      console.error('Error:', error);
      setError('An error occurred');
      setResponseMsg(null);
    }
  };
  
  
  

  return (
    <div>
      <h2>API Request Component</h2>
      <button onClick={fetchData}>Fetch Data</button>
      {error && <p>Error: {error}</p>}
      {responseMsg && <p>Response: {responseMsg}</p>}
    </div>
  );
};

export default ApiRequestComponent;

