
package events 
{

import flash.events.Event;

import mx.controls.Alert;

/**
 * A ConnectEvent is used to signal that an IRC connection
 * needs to be made to a specific host on a specific port.
 */
public class ConnectEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const CONNECT_EVENT_TYPE:String = "connectEvent";

	/** The host that needs to be connected to */
	private var mHost:String;
	
	/** The port over which to contact the host */
	private var mPort:Number;
		
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function ConnectEvent( host:String = "", port:int = 6667)
	{
		super( CONNECT_EVENT_TYPE );
		this.mHost = host;
		this.mPort = port;
	}
	
	/** Read only access to the host */
	public function get Host():String
	{
		return mHost;
	}
	
	/** Read only access to the port */
	public function get Port():int
	{
		return mPort;
	}

} // end class
} // end package