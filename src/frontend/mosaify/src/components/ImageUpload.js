import React, { useState } from 'react';
import axios from 'axios';

const ImageUpload = () => {
    const [file, setFile] = useState(null);
    const [hash, setHash] = useState(null);
    const [url, setUrl] = useState(null);
    const [imageUrl, setImageUrl] = useState(null);

  
    const handleFileChange = async (event) => {
      const selectedFile = event.target.files[0];
      // setFile(selectedFile);
      // console.log(event.target.files);
      console.log(selectedFile);

      const imageUrl = URL.createObjectURL(selectedFile);
      setImageUrl(imageUrl);
  
      // Compute hash of the file
      const reader = new FileReader();
      reader.onload = async (event) => {
        const buffer = await event.target.result;
        console.log('File content:', buffer); // Log the file content
        const crypto = window.crypto || window.msCrypto; // Support for older browsers
        const hasher = crypto.subtle.digest('SHA-256', buffer);
        const hashArrayBuffer = await hasher;
        const hashArray = Array.from(new Uint8Array(hashArrayBuffer));
        const hashHex = hashArray.map(byte => byte.toString(16).padStart(2, '0')).join('');
        setHash(hashHex);

        const newFile = new File([selectedFile], `${hashHex}.${selectedFile.name.split('.').pop()}`, { type: selectedFile.type });
        setFile(newFile);
        getUploadUrl(newFile.name, newFile.type)
      };
      reader.readAsArrayBuffer(selectedFile);
    };

    const getUploadUrl = (key, type) => {
        console.log(key)
        const apiUrl = process.env.REACT_APP_API_URL + "/url";
        // const endpoint = "/dev/url"
        const body = {
            "key": key,
            "contentType": type
        }

        axios({
            url: apiUrl,
            method: 'post',
            headers: {
                "Content-Type": "application/json"
            },
            data: body
        })
        .then(response => {
        setUrl(response.data.url)
        console.log(response.data.url)
        })
        .catch(err => {
        console.log(err);
        });
    };
    
    const handleUpload = async () => {
      axios({
        url: url,
        method: 'put',
        headers: {
          "Content-Type": file.type
        },
        data: file
      })
      .then(response => {
      console.log(response)
      }) 
      .catch(err => {
      console.log(err);
      });
    };
  
    return (
      <div>
        <input type="file" onChange={handleFileChange} />
        {hash && <p>Hash: {hash}</p>}
        {imageUrl && <img src={imageUrl} alt="Uploaded" style={{ maxWidth: '100%', maxHeight: '300px' }} />}
        {url && <button onClick={handleUpload}>Upload</button>}
      </div>
    );
  };

export default ImageUpload;
