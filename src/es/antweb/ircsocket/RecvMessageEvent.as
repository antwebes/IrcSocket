package es.antweb.ircsocket {
	import flash.events.Event;
	
	/**
	 * @author ant4
	 */
	public class RecvMessageEvent extends Event{
		/** Static constant for the event type to avoid typos with strings */
		public static const RECV_MESS_EVENT_TYPE:String = "RecvMessageEvent";
	
		/** The message's prefix */
		public var prefix:String;
		
		/** The message */
		public var message:String;
	
	
				
		
		/**
		 * Constructor, create a new ConnectEvent with a specific host and port
		 */
		public function RecvMessageEvent( message:String = "")
		{
			super( RECV_MESS_EVENT_TYPE );
			this.prefix = prefix;
			this.message = message;
		}
	}
}