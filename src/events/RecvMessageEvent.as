package events 
{

import flash.events.Event;

/**
 * A MessageEvent is used to signal that a message is received.
 */
public class RecvMessageEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const RECV_MESS_EVENT_TYPE:String = "RecvMessageEvent";

	/** The message's prefix */
	public var input:String;	


			
	
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function RecvMessageEvent( input:String = "")
	{
		super( RECV_MESS_EVENT_TYPE );
		this.input = input;
	}

} // end class
} // end package
