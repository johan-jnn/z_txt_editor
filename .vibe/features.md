# ZTextEditor features

## Presentation

The ZTextEdition app is a mobile application used to edit text-based files on the device, espacially code files.

It needs, at least to support those formats :

- html
- css
- javascript
- markdown
- python
- raw text

## Features

### Open file

You should be able to open a file from the device.
For now, just use single-file editing based. But keep in mind that in future versions we'll be able to open multiple editors at once.

### Editing files

After you opened the file, the editor will show up with the file's content.
It must have syntax highlighting, line numbers and a bottom-right bubble with additionnal options such as file saving, open another file or open recent file.

### File saving

We must have a "save" button as well as a "save as" button that let us edit the new file's name & location.

### Settings

The settings must be accessible in the app's menu that opens with a burger button the app's bar.

## Settings of the application

## Main background

The application's background should be a unicolor background, that can be changed through a color pick in the setting's page.

## Overlay background

Because this application is created mainly for developpers, we must have a dev-duck in the app.
So, by using [this API](https://publicapi.dev/random-duck-api), you must display on ech page a duck image in the background.
Add a setting to change the image's opacity (from 1% to 100%).

This feature can have 3 behaviors:

### Full-random image

At each view change, change the duck's image.
To retreive a random jpeg duck image, use this url : `https://random-d.uk/api/randomimg?type=JPG`.

### Fixed-random image

In the settings, you have a button to get a new duck image that will stay on the background.
To do this, use this endpoint : `https://random-d.uk/api/quack`.
It will return you back a json with a `url` key that contains the url to a duck's image.
Use this image as the background's overlay.

### Disabled image

This will just disable the duck's background. In this case, we hide all the opacity settings.

---

For this feature, you must have only 2 variables :

- The overlay url
  - Either `https://random-d.uk/api/randomimg?type=JPG`
  - Or the url returned by the `https://random-d.uk/api/quack` endpoint
- The overlay opacity
  - A number in the [0; 100] (or [0; 1]) range
  - If the number is `0`, it means that the overlay feature is disabled
