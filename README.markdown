Screenshot
===

A Sinatra webservice that takes an image screenshot of any URL.

Parameters
---

If you install the service at the domain:
 http://domain.com/screenshot/

http://domain.com/screenshot/site/<site_url>

e.g. http://domain.com/screenshot/site/http://www.bbc.co.uk

Currently the service returns a png image.

Pause
---

You can get the service to insert a pause delay between the web page loading and the screenshot being taken. This gives you a chance for any javascript in the page to initialise.

http://domain.com/screenshot/site/pause:<time_delay>/<site_url>

Encoding site URLs
---

If the website to be captured has a URL with certain characters in it then you may need to URL encode it. For example:
  http://somesite.com/werid?url|with|data
  
Should become:
  http://somesite.com/werid?url%7cwith%7cdata

Screenshot binary
---

The actual screenshot is taken by the webcapture binary. (Link to webcapture github.)