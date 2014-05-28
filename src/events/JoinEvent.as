package events 
{

import flash.events.Event;

/**
 * A ConnectEvent is used to signal that an IRC connection
 * needs to be made to a specific host on a specific port.
 */
public class JoinEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const JOIN_EVENT_TYPE:String = "joinEvent";

	/** The port over which to contact the host */
	public var mchanId:String;
	
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function JoinEvent( chanId:String = "")
	{
		super( JOIN_EVENT_TYPE );
		
		this.mchanId = chanId;
	}
	
	public function get ChanId():String {
		return mchanId;
	}

} // end class
} // end package