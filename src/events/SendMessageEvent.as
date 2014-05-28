package events 
{

import flash.events.Event;

/**
 * A MessageEvent is used to signal that a message is received.
 */
public class SendMessageEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const SEND_MESS_EVENT_TYPE:String = "SendMessageEvent";

	/** The message's text */
	public var text:String;
	
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function SendMessageEvent(text:String = "" )
	{
		super( SEND_MESS_EVENT_TYPE );
		this.text = text;
	}

} // end class
} // end package
