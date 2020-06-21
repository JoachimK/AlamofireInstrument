# AlamofireInstrument
A custom Instrument for tracing Alamofire http requests

You can read more about the background of this instrument here: https://blog.cocoafrog.de/how-to/2020/06/20/You-should-all-build-this-custom-instrument.html

# Compatibility
This currently only works with Alamofire 4.8.x, it wasn't tested with other versions. 
It might as well work, because it only relies on the notifications sent out by Alamofire.
If you are using a different version of Alamofire or a different networking library, all you need to do is adapt the `Logger.swift` file for your use-case to make sure the log-statements are sent at the correct times with the correct data.

# How to use it
1. Clone the repository.
2. Copy the "Logger.swift" file somewhere into your project.
3. Call `SignpostLog.logger.startObservingNetworkRequestsIfNecessary()` somewhere in your code, early enough that the logging starts before oyur first network request. (e.g. in the App Delegate).
4. Build the app you want to profile for Profiling (Cmd+I).
5. Instruments will open. Choose the blank template and add the os_signpost instrument, to verify that there are os_signpost intervalls for `org.alamofire`.
6. If nothing appears in Instruments, ensure that [the `OS_ACTIVITY_MODE` environment variable is not set](https://stackoverflow.com/a/57187309/1956359).
7. Once that works, open the Xcode project in this repository. Run it monochrome (gray?) Instruments app will open. Choose a blank template, click the Plus-button in the top right and find the "Alamofire" instrument in the list to add to your template.
8. Choose the app and device you want to profile in the top left. Hit record. Your app should start now and you should see requests coming in.

