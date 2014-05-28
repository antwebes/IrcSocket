package events 
{

import flash.events.Event;

/**
 * A QueryEvent is used to signal that an private windows
 * needs to be opened with a specific user.
 */
public class QueryEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const QUERY_EVENT_TYPE:String = "queryEvent";

	/** The nick we want to contact */
	private var mNick:String;
	public var mostrar:Boolean = false;
	
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function QueryEvent( nick:String = "")
	{
		super( QUERY_EVENT_TYPE ,true);
		this.mNick = nick;
	}
	
	public function get Nick():String{
		return mNick;
	}

} // end class
} // end package