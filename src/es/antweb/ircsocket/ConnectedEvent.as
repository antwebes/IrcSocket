package es.antweb.ircsocket {
	import flash.events.Event;
	
	/**
	 * @author ant4
	 */
	public class ConnectedEvent extends Event {
		public function ConnectedEvent():void {
			super("ConnectedEvent");
		}
	}
}