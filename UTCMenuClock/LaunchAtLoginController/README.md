# LaunchAtLoginController

A simple controller for Cocoa Mac Apps to register/deregister for Launch at Login using the modern SMAppService API (macOS 13+).

## IMPLEMENTATION (Code):

### Will app launch at login?

```objc
LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
BOOL launch = [launchController launchAtLogin];
```

### Set launch at login state.

```objc
LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
[launchController setLaunchAtLogin:YES];
```

## IMPLEMENTATION (Interface builder):

* Open Interface Builder
* Place a NSObject (the blue box) into the nib window
* From the Inspector - Identity Tab (Cmd+6) set the Class to LaunchAtLoginController
* Place a Checkbox on your Window/View
* From the Inspector - Bindings Tab (Cmd+4) unroll the > Value item
  * Bind to Launch at Login Controller
  * Model Key Path: launchAtLogin

## IS IT WORKING:

After implementing either through code or through IB, setLaunchAtLogin:YES and then check System Settings > General > Login Items. You should see your app in the list of apps that will start when the user logs in.

## REQUIREMENTS:

Requires macOS 13.0 (Ventura) or later. Uses SMAppService API.

## ORIGINAL CODE IDEAS:

* Growl. 
* User: invariant Link: (http://stackoverflow.com/questions/815063/how-do-you-make-your-app-open-at-login/2318004#2318004)
* Updated for SMAppService by UTCMenuClock project

## LICENSE:

(The MIT License)

Copyright (c) 2010 Ben Clark-Robinson, ben.clarkrobinson@gmail.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
