package events 
{

import flash.events.Event;

import mx.controls.Alert;

/**
 * A MessageEvent is used to signal that a message is received.
 */
public class WhoisEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const WHOIS_EVENT_TYPE:String = "WhoisEvent";

	/** The message's prefix */
	public var nombre:String;
	
	/** The message's command */
	public var canales:Array;
	
	public var ident:String;
	
	public var away:String;

	public var usaChatea:Boolean = false;	//usa chat nuestro
	
	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function WhoisEvent( nombre:String)
	{
		super( WHOIS_EVENT_TYPE );
		this.nombre=nombre;
	}
	
	public function setCanales(ar:Array):void {
		canales = ar;
	}

	public function setAway(s:String):void {
		away =s; 
	}
	
	public function setIdent(id:String):void {
		ident = id;
		if(id == "fl_chatea") usaChatea = true;
	}

} // end class
} // end package
