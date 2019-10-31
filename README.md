# Objective

Virtual Tourist application is a part of Udacity Nanodegree program. The project is implemented to practice with persisting data locally on a device. Specification could be found [here](https://s3.amazonaws.com/video.udacity-data.com/topher/2019/April/5cb60ce5_app-specifications-virtual-tourist/app-specifications-virtual-tourist.pdf)
<p>The Virtual Tourist app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.

## Getting started
- Clone the repo and run VirtualTourist.xcodeproj
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
The project consists of 2 View Controllers: MapViewController and PhotoAlbumViewController.
- **MapViewController**:
  </p>Objective: To incorporate map view and allow user to specify location with MapKit framework imported.  Tapping a pin redirects to PhotoAlbumVC. </p>
- **PhotoAlbumViewController**:
  <p>Objective: To feed CollectionView with photos downloaded from the FlickrAPI. All photos are saved to memory by using Core Data framework.</p>
  
  The application uses MVVM architecture.
- **MapViewModel**:
  <p>Works with Data Manager to retrieve saved pins and casts them as array of Pins. Talks to MapVC using POP to send requested data. Creates an instance of LocationDetailViewModel with specified location and sends back to MapVC, which pushes a PhotoAlbumVC with a LocationDetailViewModel injected.</p>
- **LocationDetailVewModel**:
  <p>Works with both Data Manager and Network Manager. Data Manager is used to retrieve saved photos associated with location. If there is no saved data, it initiates a network call to download photos using Network Manager. Also, uses POP to talk to PhotoAlbumVC.</p>
  
  There are 2 services: DataManager and NetworkManager:
- **DataManager**:
  <p>This class is built around Core Data. Implements CRUD to manipulate models.</p>
- **NetworkManager**:
  <p>This class is responsible for network calls and handles success and failure results. Has an instance of Router with specified EndpointType because Router is generic class. </p>
  <p>It is aimed to make a request with URLSession. In this project, being Router as generic function is not really useful, but made for learning purposes.</p>
  <p> **FlickrAPI** is enum conforms to protocol Endpoint and specifies URLs for cases: search() and getImage(). </p>
  
## Screenshots

<p align="center">
<img src="https://github.com/zhaziragaripolla/images/blob/master/VirtualTourist1.png" width="160"  title="vt1">
<img src="https://github.com/zhaziragaripolla/images/blob/master/VirtualTourist2.png" width="160" title="MapView">

</p>
