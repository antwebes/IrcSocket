package RTC

/**
 *
 * Adobe LiveCycle Collaboration Service Account Management API
 *
 * Revision
 *   $Revision: #1 $ - $Date: 2010/10/20 $
 *
 * Author
 *   Sean Corfield
 *   Raffaele Sena
 *
 * Copyright
 *   ADOBE SYSTEMS INCORPORATED
 *   Copyright 2007 Adobe Systems Incorporated
 *   All Rights Reserved.
 *
 *  NOTICE: Adobe permits you to use, modify, and distribute this file in accordance with the 
 *  terms of the Adobe license agreement accompanying it.  If you have received this file from a 
 *  source other than Adobe, then your use, modification, or distribution of it requires the prior 
 *  written permission of Adobe.
 */

/**
 * Error - error thrown or generated by RTC API
 */
class Error extends Exception {
  Error(String message) {
    super(message)
  }
}

/**
 * Constants for common user roles
 */
public static interface UserRole
{
      public static final int NONE      = 0;
      public static final int LOBBY     = 5;
      public static final int VIEWER    = 10;
      public static final int PUBLISHER = 50;
      public static final int OWNER     = 100;
}

/**
 * Authenticator - generate RTC authentication tokens
 */
class Authenticator {

  Authenticator(url) {
    authURL = url
  }
  
  /*
   * Get an RTC authentication token give login and password.
   */
  String login(user,pw,retHeaders) {
    
    def headers = [ "Content-Type" : "text/xml" ]
    def data = new groovy.xml.StreamingMarkupBuilder().bind {
      request() {
        username(user)
        password(pw)
      }
    }
    
    def resp = Utils.http_post(authURL,data,headers)
    
    if (Utils.DEBUG) {
      println resp
    }

    try {
      def result = new XmlSlurper().parseText(resp)
      
      if (result.@status == "ok") {
        if (result.authtoken.@type == "COOKIE") {
          retHeaders["Cookie"] = result.authtoken.text()
          return null
        } else {
          def gak = Utils.base64(result.authtoken.text())
          return "gak=${gak}"
        }
      } else {
        throw new Error(resp)
      }
    } catch (Exception e) {
      println e.dump()
      throw new Error("bad-response")
    }
  }
  
  /*
   * Get a guest authentication token.
   */
  String guestLogin(user) {
    def guk = Utils.base64("g:${user}")
    "guk=${guk}"
  }
  
  String authURL
}

/**
 * Session - deals with meeting sessions and # external collaboration
 */

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

class Session {

  Session(instance, account, room) {

    this.instance = instance.replaceAll("#room#", room)
    this.account = account
    this.room = room
  }

  /**
   * get an external authentication token
   */
  String getAuthenticationToken(accountSecret, name, id, role) {
    role = role as Integer
    if (role < UserRole.NONE || role > UserRole.OWNER)
      throw new Error("invalid-role")
    def token = "x:${name}::${this.account}:${id}:${this.room}:${role}"
    def signed = "${token}:${sign(accountSecret, token)}"

    // unencoded
    //def ext = "ext=${signed}"

    // encoded
    def ext = "exx=${Utils.base64(signed)}"

    ext
  }
  
  /**
   * get the userId that the server will generate for this user
   */
  String getUserID(id) {
    ("EXT-" + this.account + "-" + id).toUpperCase();
  }

  def getSecret(baseURL, authToken, authHeaders) {
    def data = Utils.http_get("${baseURL}app/session?instance=${this.instance}&${authToken}", authHeaders)

    if (Utils.DEBUG) println data;

    def response = new XmlSlurper().parseText(data)
    this.secret = response."session-secret".text()
  }

  def invalidate(baseURL, authToken, authHeaders) {
    def data = "action=delete&instance=${this.instance}&${authToken}"
    def res = Utils.http_post("${baseURL}app/session", data, authHeaders)

    if (Utils.DEBUG) println res;

    this.instance = null
    this.account = null
    this.room = null
    this.secret = null

    res
  }

  protected def sign(acctSecret, data) {
    def bigSecret = "${acctSecret}:${this.secret}"
    def sk = new SecretKeySpec(bigSecret.getBytes(), "HmacSHA1")
    def mac = Mac.getInstance("HmacSHA1");

    mac.init(sk)
    def hmac = mac.doFinal(data.getBytes())
    Utils.hexString(hmac)
  }

  String instance
  String account
  String room
  String secret
}

/**
 * Item: Room or template item information.
 */
class Item {
  String name
  String desc
  Date created
}

/**
 * AccountManager - high-level account manipulation
 */
class AccountManager {
  
  final static ROOM_ITEMS     = "meetings"
  final static TEMPLATE_ITEMS = "templates"
  
  String url
  
  AccountManager(url) {
    this.url = url
    do_initialize()
  }
  
  String getContentURL() {
    baseURL + "app/content" + contentPath
  }
  
  /*
   * Login into account
   */
  def login(user,password = null) {
    
    if (password) {
      authToken = authenticator.login(user,password,authHeaders)
    } else {
      authToken = authenticator.guestLogin(user)
    }
    
    return do_initialize()
  }

  /*
   * keep the authentication token alive by accessing the account
   */
  def keepalive(user = null, password = null) {
    contentPath = null;
    if (do_initialize()) return true;
    if (user != null) return login(user, password);
    return false;
  }
  
  /*
   * Create room
   */
  def createRoom(room,template = null) {
    
    if (!template) {
      template = "default"
    }
    
    def data = "mode=xml&room=${room}&template=${template}&${authToken}"
    
    Utils.http_post(url,data,authHeaders)
  }
  
  /*
   * List rooms or templates
   */
  def listItems(type = null) {
    
    if (type != AccountManager.TEMPLATE_ITEMS) {
      type = AccountManager.ROOM_ITEMS
    }
    
    def items = []
    
    def data = Utils.http_get("${contentURL}/${type}/?${authToken}",authHeaders)
    
    if (Utils.DEBUG) {
      println data
    }
    
    def repository = null
    
    try {
      
      repository = new XmlSlurper().parseText(data)
      
    } catch (Exception e) {
      throw new Error("bad-response")
    }
    
    repository.children.node.each { n ->
      def name = n.name.text()
      def desc = null
      def created = null
      n.properties.property.each { p ->
        if (p.@name == "cr:description") {
          desc = p
        } else if (p.@name == "jcr:created") {
          def raw = p.toString()
          // ends with "-HH:MM" and we need to turn this into " -HHMM" so that it will parse!
          raw = raw.substring(0,raw.length()-6) + " " + raw.substring(raw.length()-6,raw.length()-3) + raw.substring(raw.length()-2)
          created = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.S Z").parse(raw)
        }
      }
      items << new Item(name:name,desc:desc,created:created)
    }
    
    items
  }
  
  /*
   * delete room or template
   */
  def delete(item, type=null, list=false) {
    
    if (type != AccountManager.TEMPLATE_ITEMS) {
      type = AccountManager.ROOM_ITEMS
    }
    
    def limitCount = list ? "" : "&count=0"
    def data = "action=delete&response=inline${limitCount}&${authToken}"

    Utils.http_post("${contentURL}/${type}/${item}",data,authHeaders)
  }
  
  /*
   * List rooms
   */
  def listRooms() {
    listItems(AccountManager.ROOM_ITEMS)
  }
  
  /*
   * List templates
   */
  def listTemplates() {
    listItems(AccountManager.TEMPLATE_ITEMS)
  }
  
  /*
   * Delete room
   */
  def deleteRoom(r, list=false) {
    if (r == null) throw new Error("parameter-required")
    delete(r.toLowerCase(),AccountManager.ROOM_ITEMS,list)
  }
  
  /*
   * Delete template
   */
  def deleteTemplate(t,list=false) {
    if (t == null) throw new Error("parameter-required")
    delete(t,AccountManager.TEMPLATE_ITEMS,list)
  }

  /*
   * Return a room session for external authentication
   */
  Session getSession(room) {
    def parts = this.url.split("/")
    def session = new Session(this.roomInstance, parts[parts.length-1], room)
    session.getSecret(this.baseURL, this.authToken, this.authHeaders)
    session
  }

   /*
    * invalidate room session
    */
  def invalidateSession(session) {
    session.invalidate(this.baseURL, this.authToken, this.authHeaders)
  }

  /*
   * Return the RTC nodes @ path
   */
  def getNodes(room, path) {
    def instance = this.roomInstance.replaceAll("#room#", room)
    def data = Utils.http_get("${baseURL}app/collections?instance=${instance}&path=${path}&${authToken}", authHeaders)
    data
  }

  /*
   * Return information about the account, if active
   */
  def getAccountInfo() {
    def acctid = this.roomInstance.split("/")[0]
    def data = Utils.http_get("${baseURL}app/account?account=${acctid}&${authToken}", authHeaders)
    data
  }

  /*
   * Return information about the room/instance, if active
   */
  def getRoomInfo(room) {
    def instance = room

    if (room.indexOf("/") < 0)
      instance = this.roomInstance.replaceAll("#room#", room)
    
    def data = Utils.http_get("${baseURL}app/account?instance=${instance}&${authToken}", authHeaders)
    data
  }

  private def do_initialize() {
    
    if (contentPath != null)
      return true

    def data = Utils.http_get("${url}?mode=xml&accountonly=true&${authToken}",authHeaders)
    
    if (Utils.DEBUG)
      println data
    
    try {

      def result = new XmlSlurper().parseText(data)
      
      if (result.name() == "meeting-info") {
        baseURL = result.baseURL.@href
        url = baseURL + new URL(url).path.substring(1)
        contentPath = result.accountPath.@href
        if (result.room)
	  this.roomInstance = result.room.@instance
        return true
      }
      
      if (result.name() == "result") {
        if (result.@code == "unauthorized") {
          if (result.baseURL) {
            baseURL = result.baseURL.@href
            url = baseURL + new URL(url).path.substring(1)
          }
          String authURL = result.authentication.@href
          if (authURL[0] == '/') {
            authURL = baseURL + authURL
          }
          authenticator = new Authenticator(authURL)
          return false
        }
      }

    } catch (Exception e) {
      throw new Error("bad-response")
    }
    
    throw new Error(data)
  }
  
  String   authToken = ""
  Map      authHeaders = [:] 
  def      authenticator = null
  String   baseURL = null
  String   contentPath = null
  String   roomInstance = null
}

/**
 * Utility methods
 */
class Utils {
    
  static DEBUG = false
  
  static http_get(url, headers = null) {
    
    if (DEBUG) {
      println "http_get: ${url}"
      if (headers) {
        println headers.dump()
      }
    }
    
    def req = new URL(url)
    def connection = req.openConnection()
    
    if (headers) {
      headers.each { key, value ->
        connection.addRequestProperty(key,value)
      }
    }

    if (Utils.DEBUG) {
    	def host = connection.getHeaderField("X-Acorn-Hostname")
        if (host) println "Host: " + host
    }
    
    if (connection.responseCode == 200) {

      return connection.content.text

    } else if (connection.responseCode == 302) {

	if (Utils.DEBUG)
	  System.out.println("Redirecting to " + connection.getHeaderField("Location"));

	return http_get(connection.getHeaderField("Location"), headers);
	
    } else {

      if (Utils.DEBUG) {
        println "HTTP error " + connection.responseCode
        println connection.content.text
      }
      
      throw new Exception("GET ${url} failed with ${connection.responseCode}")

    }
  }

  static http_post(url,params,headers = null) {
    
    def data = params // convert from array??
        
    if (Utils.DEBUG) {
      println "http_post: ${url} ${data}"
      if (headers) {
        println headers.dump()
      }
    }

    def req = new URL(url)
    def connection = req.openConnection()
    
    if (headers) {
      headers.each { key, value ->
        connection.addRequestProperty(key,value)
      }
    }
    
    connection.requestMethod = "POST"
    connection.doOutput = true
    Writer writer = new OutputStreamWriter(connection.outputStream)
    writer.write(data)
    writer.flush()
    writer.close()
    connection.connect()

    if (Utils.DEBUG) {
    	def host = connection.getHeaderField("X-Acorn-Hostname")
        if (host) println "Host: " + host
    }
    
    if (connection.responseCode == 200) {

      return connection.content.text

    } else if (connection.responseCode == 302) {

	if (Utils.DEBUG)
	  System.out.println("Redirecting to " + connection.getHeaderField("Location"));

	return http_post(connection.getHeaderField("Location"), headers);
	
    } else {

      if (Utils.DEBUG) {
        println "HTTP error " + connection.responseCode
        println connection.content.text
      }
      
      throw new Exception("POST ${url} failed with ${connection.responseCode}")

    }

  }

  static String hexString(data) {
    def bytes = (data instanceof String) ? data.getBytes() : data
    def sb = new StringBuilder()

    bytes.each { b -> 
      def x = Integer.toString((b >= 0 ? b : 256 + b), 16);
      if (x.length() == 1)
	sb.append("0")
      sb.append(x)
    }
 
    sb.toString()
  }

  static String base64(s) {
    // a bug in Groovy 1.5.5 chunks the encoded string so we have to remove LF
    s.toString().getBytes().encodeBase64().toString().replace("\n","")
  }
  
}

/**
 * A simple command line utility
 */
static usage(String progname) {
  println("usage: " + progname + " [--debug] [--host=url] account user password");
  println("         --list");
  println("         --create room [template]");
  println("         --delete room");
  println("         --delete-template template");
  println("         --ext-auth secret room username userid role");
  println("         --invalidate room");
  System.exit(1);
}

static main(args) {
  def host = "http://connectnow.acrobat.com"
  def argc = 0;

  while (argc < args.length) {

    def arg = args[argc];

    if (arg.startsWith("--host="))
      host = arg.substring(7);
    
    else if (arg == "--debug")
      Utils.DEBUG = true;

    else
      break;

    argc++;
  }

  if (args.length - argc < 3)
    usage("lccs");

  def account = args[argc++];
  def username = args[argc++];
  def password = args[argc++];

  def am = new AccountManager("${host}/${account}")
  am.login(username,password)
  
  if (args.length - argc == 0 || args[argc] == "--list") {
    println("==== template list for ${account} ====");
    try {
      am.listTemplates().each { aTemplate ->
	println("${aTemplate.name} : ${aTemplate.created}");
      }
    } catch(Exception e) {
      println "error listing templates: ${e}"
    }

    println("==== room list for ${account} ====");
    try {
      am.listRooms().each { aRoom ->
	println("${aRoom.name} : ${aRoom.desc} : ${aRoom.created}");
      }
    } catch(Exception e) {
      println "error listing rooms: ${e}"
    }
  }

  else if (args[argc] == "--create") {
    am.createRoom(args[argc+1], (args.length - argc) > 2 ? args[argc+2] : null);
  }

  else if (args[argc] == "--delete") {
    am.deleteRoom(args[argc+1]);
  }

  else if (args[argc] == "--delete-template") {
    am.deleteTemplate(args[argc+1]);
  }

  else if (args[argc] == "--ext-auth") {
    def role = UserRole.LOBBY;
    
    if (args.length - argc >= 6) {
      role = args[argc+5];
      if (role.equalsIgnoreCase("none"))
	role = UserRole.NONE;
      else if (role.equalsIgnoreCase("lobby"))
	role = UserRole.LOBBY;
      else if (role.equalsIgnoreCase("viewer"))
	role = UserRole.VIEWER;
      else if (role.equalsIgnoreCase("publisher"))
	role = UserRole.PUBLISHER;
      else if (role.equalsIgnoreCase("owner"))
	role = UserRole.OWNER;
    }

    def session = am.getSession(args[argc+2])
    def token =  session.getAuthenticationToken(args[argc+1], args[argc+3], args[argc+4], role)
    println token
    println "userID: " + session.getUserID(args[argc+4])
  }

  else if (args[argc] == "--invalidate") {
    def session = am.getSession(args[argc+1])
    am.invalidateSession(session)
  }
  
  else if (args[argc] == "--info") {
    if ((args.length - argc) == 1)
      println am.getAccountInfo()
    else
      println am.getRoomInfo(args[argc+1])
  }

  else if (args[argc] == "--get-nodes") {
    println am.getNodes(args[argc+1], args[argc+2])
  }

  else
    usage("lccs")
}  

main(args)