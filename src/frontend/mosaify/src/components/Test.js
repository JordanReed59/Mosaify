import React from "react";
import "react-dropzone-uploader/dist/styles.css";
import Dropzone from "react-dropzone-uploader";
import axios from 'axios';

const Uploader = () => {
//   const axios = require("axios").default;

  const API_ENDPOINT = process.env.REACT_APP_API_URL + "/url";
  const handleChangeStatus = ({ meta, remove }, status) => {
    console.log(status, meta);
  };

  const handleSubmit = async (files) => {
    const f = files[0];
    console.log(f["file"]);
    const body = {
        "key": f["file"].name,
        "contentType": f["file"].type
    }
    
    // * GET request: presigned URL
    const response = await axios({
        url: API_ENDPOINT,
        method: 'post',
        headers: {
            "Content-Type": "application/json"
        },
        data: body
    });

    console.log("Response: ", response);

    // * PUT request: upload file to S3
    const result = await fetch(response.data.url, {
      method: "PUT",
      headers: new Headers({
        "Content-Type": f["file"].type
      }),
      body: f["file"],
    });
    console.log("Result: ", result);
  };

  return (
    <Dropzone
      onChangeStatus={handleChangeStatus}
      onSubmit={handleSubmit}
      hjello
      maxFiles={1}
      multiple={false}
      canCancel={false}
      inputContent="Drop A File"
      styles={{
        dropzone: { width: 400, height: 200 },
        dropzoneActive: { borderColor: "green" },
      }}
    />
  );
};

<Uploader />;

export default Uploader;