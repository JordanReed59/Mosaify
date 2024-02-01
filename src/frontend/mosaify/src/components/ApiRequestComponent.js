import React, { useState } from 'react';
import axios from 'axios';

const ApiRequestComponent = () => {
  const [responseMsg, setResponseMsg] = useState(null);
  const [error, setError] = useState(null);

  const fetchData = async () => {
    try {
      const apiUrl = process.env.REACT_APP_API_URL;
      const response = await axios.get(apiUrl);
  
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
