
/************************************************
* Adobe LCCS 2010 
* Server To Server Java Interface and Example
* Version 1.0
* 
* This release aims at providing server to server integration with Adobe LCCS solution.
* 
* This README file shows how to install JAVA AMF third party library that will allow LCCS server
* to invoke http hooks on your Java Application server (tomcat) and allowing your application to recieve LCCS real time events 
* as Adobe Flash AMF packages.  It also demonstrate how your Java application invoking LCCS server APIs.   
*
* To get more information on the LCCS HTTP Server to Server API, visit ****
*************************************************/

Invoking LCCS server APIs:

1) We choose BlazeDS as AMF java application gateway, download BlazeDS from http://opensource.adobe.com/wiki/display/blazeds/download+blazeds+3

2) BlazeDS development guid: http://livedocs.adobe.com/blazeds/1/blazeds_devguide/

3) If you have tomcat server setup or any Java application server installation, copy BlazeDS' blazeds.war under your deployment directory.  
BlazeDS also came with samples.war and you can also copy that and use it as an experiment deployment.  Our gateway example tested under samples directory.

4) Copy LCCS.jar from serverIntegeration/java to the WEB-INF/lib directory

5) Create AccountManager instance from your application and start calling the server to server APIs.

	Sequence of calling:
	AccountManager am = new AccountManager(meetingurl);
	am.login(username, password);
	am.registerHook(endpoint, token);
	am.subscribeCollection(room, collection);
	
(Login only one time and keep it in cache for performance)


Setting Web Hooks:

1) create an LCCS directory under the blazeds or samples directory.  (e.g. tomcat/webapps/samples/WEB-INF/src/flex/samples/LCCS)

5) copy RTCHOOKS.java from serverIntergration/java  

6) compile RTCHOOKS.java into your WEB_INF/classes directory,  flex-messaging-core.jar should came with BlazeDS setup.
  (e.g. javac -d WEB-INF/classes/ WEB-INF/src/flex/samples/LCCS/*.java -classpath WEB-INF/lib/LCCS.jar:WEB-INF/lib/flex-messaging-core.jar) 


7) update remote-config.xml with following: (id="RTCHOOKS" is required)

    <destination id="RTCHOOKS">
        <properties>
            <source>flex.samples.LCCS.RTCHOOKS</source>
        </properties>
    </destination>

    <destination id="LCCS" channels="my-amf">
        <properties>
            <source>com.adobe.rtc.account.AccountManager</source>
        </properties>
    </destination>

   <destination id="MySessionHandler: channels="my-amf">
        <properties>
            <source>flex.samples.LCCS.MySessionHandler</source>
        </properties>
        <adapter ref=java-object/>
    </destination>

   (find all the configuration for AMFEndpoint at WEB_INF/flex directory, e.g. tomcat/webapp/samples/WEB-INF/flex)
    
    if you use flash flex builder compiler option -context-root "samples" -services="<path>/services-config.xml"

8) CAll AccountManager registerHook with callback url (e.g. hook info: http://<hostname>:8400/samples/messagebroker/amf);

9) Call AccountManager subscribeCollection with collection name you are interested.

10) This is all it takes to create hooks in BlazeDS for LCCS to send you events.  (see BlazeDSGateway_Java for detailed example)



