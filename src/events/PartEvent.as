package events 
{

import flash.events.Event;

/**
 * A ConnectEvent is used to signal that an IRC connection
 * needs to be made to a specific host on a specific port.
 */
public class PartEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const PART_EVENT_TYPE:String = "partEvent";

	/** The port over which to contact the host */
	private var mchanId:String;
	
	/** The port over which to contact the host */
	private var mReason:String;
	
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function PartEvent( chanId:String = "", reason:String= "Bye")
	{
		super( PART_EVENT_TYPE );
		
		this.mchanId = chanId;
		this.mReason = reason;
	}
	
	public function get ChanId():String {
		return mchanId;
	}
	
	public function get Reason():String {
		return mReason;
	}

} // end class
} // end package