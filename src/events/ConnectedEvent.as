
package events 
{

import flash.events.Event;

/**
 * A ConnectEvent is used to signal that an IRC connection
 * needs to be made to a specific host on a specific port.
 */
public class ConnectedEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const CONNECTED_EVENT_TYPE:String = "connectedEvent";

		
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function ConnectedEvent()
	{
		super( CONNECTED_EVENT_TYPE );
	}
	

} // end class
} // end package