// 1) Get the input data from the Lambda response
const lambdaResponse = $input.first().json.result;

// 2) Parse the body if it's a string, or use it directly if it's already an object
let responseBody;
try {
  responseBody = typeof lambdaResponse.body === 'string' 
    ? JSON.parse(lambdaResponse.body) 
    : lambdaResponse.body;
} catch (error) {
  throw new Error(`Failed to parse Lambda response body: ${error.message}`);
}

// 3) Convert each image into an n8n item
return responseBody.images.map(image => ({
  json: {
    fileName: image.filename,
    totalPages: responseBody.total_pages
  },
  binary: {
    data: {
      data: image.content,
      mimeType: image.content_type,
      fileName: image.filename
    }
  }
}));
