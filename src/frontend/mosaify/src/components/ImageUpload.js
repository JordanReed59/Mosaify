import React, { useState } from 'react';
import axios from 'axios';

const ImageUpload = () => {
    // allow user to select iamge

    const getUploadUrl = (imageName) => {
        const apiUrl = process.env.REACT_APP_API_URL + "/url";
        const endpoint = "/dev/url"
        const body = {
            "key": imageName
        }
        const headers = {
            "Content-Type": "application/json"
          }

        axios({
            url: apiUrl,
            method: 'post',
            headers: headers,
            data: body
        })
        .then(response => {
        console.log(response)
        })
        .catch(err => {
        console.log(err);
        });
    };

    const testUrl = () => {
        getUploadUrl("some_react_name.jpeg")
    }

    return (
        <div>
          <h2>Upload Image</h2>
          <button onClick={testUrl}>Test URL</button>
        </div>
      );
};

export default ImageUpload;