# Objective

Virtual Tourist application is a part of Udacity Nanodegree program. The project is implemented to practice with persisting data locally on a device. Specification could be found [here](https://s3.amazonaws.com/video.udacity-data.com/topher/2019/April/5cb60ce5_app-specifications-virtual-tourist/app-specifications-virtual-tourist.pdf)
<p>The Virtual Tourist app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.

## Getting started
- Clone the repo and run FlickrSearch.xcodeproj
- Get an API Key from [FlickrAPI](https://www.flickr.com/services/api/misc.api_keys.html)
- Paste your generated API Key to file *APIKey.swift*

## Flickr API Documentation
The application uses the endpoint [flickr.photos.search](https://www.flickr.com/services/api/flickr.photos.search.html) to search images with specific geolocation.
- Response includes an array of photo objects, each represented as:
``` swift
{
"id": "43213681030",
"owner": "164058447@N08",
"secret": "a4bf8df905",
"server": "1937",
"farm": 2,
"title": "Puss under the boot",
"ispublic": 1,
"isfriend": 0,
"isfamily": 0
}
```

The farm, server, id, and secret are used to build the image path. [Flickr Photo Source URLs](https://www.flickr.com/services/api/misc.urls.html)
- **Image Path**: http://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg
- **Example**: https://farm8.staticflickr.com/7564/15981410640_a0d5006167_m.jpg
- Response object is the image file.

## Class details
The application uses MVVM architecture. UML Diagram could be found [here]()

## Screenshots
