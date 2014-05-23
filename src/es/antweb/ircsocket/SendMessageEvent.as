package es.antweb.ircsocket {
	import flash.events.Event;
	
	/**
	 * @author ant4
	 */
	public class SendMessageEvent extends Event {
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
	}
}