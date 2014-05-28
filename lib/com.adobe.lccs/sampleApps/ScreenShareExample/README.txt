This example shows how you can use LCCS ScreenSharePublisher to share the screen with ScreenShareSubscriber.

ScreenSharePublisherExample: This example shows how to publish one's screen and share with other subscribers in the same room who has its publisherID.
When invoke this publisher, Adobe Screen Share Addin will appear and a sharing dialog will pop up for asking which application/view to share.  Upon confirmation, 
both streamID and publisherID will be displayed on the center textfields.  Use the publisherID on the screenshare subscriber to see the screenshare.  (Please verify
account information and roomURL before using the publisher)  

ScreenShareSubscriberExample: With right account information and roomURL, this application will connect to the first screen share publisher in the room (you don't need to specify the publisherID).

ScreenSharePubSubExample: This example has both publisher and subscriber in the same application.  This is very useful for showing off your own screen and at the same time seeing other user's screen.  
You will need to specify the other publisher's ID in order to see their screen.  

ScreenShareMultiSubscriberExample: This application allow you to see multiple screen share publishers in the same room.  All you need is specify the publisherID in the textfield box and click on 
subscribe to see the screen share.  This application shows two screenshare subscriptions.


