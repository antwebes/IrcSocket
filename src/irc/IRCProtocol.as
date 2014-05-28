package irc
{
	
	import events.ConnectEvent;
	import events.ConnectedEvent;
	import events.RecvMessageEvent;
	
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.*;
	
	import mx.core.FlexGlobals;
	import mx.utils.StringUtil;
	
	public class IRCProtocol extends Socket
	{
		/** The port we're connecting on */
		private var port:uint;
	
		/** The host we're connecting to */
		public var host:String;
				
		private var input: String;
		
		
		private var reg:RegExp = new RegExp("(.+)!(.+)@(.+)");		
	
		public function ReadMessage():void {
			while ( bytesAvailable > 0 )
			{
				var byte: uint = readUnsignedByte();
				var next: uint;
				
				if ( byte == 13 )
				{
					if ( bytesAvailable >= 1 )
					{
						next = readUnsignedByte();
						
						if ( next == 10 )
						{
							trace( '<-', input );
							decodeMessage(input );
							input = '';
						}
						else
						{
							input += String.fromCharCode( byte );
							input += String.fromCharCode( next );
						}
					}
					else
						input += String.fromCharCode( byte );
				}
				else
					input += String.fromCharCode( byte );
			}
			
			decodeMessage(input);
		}

		
		private function decodeMessage(input:String):void
		{
			var me:RecvMessageEvent = new RecvMessageEvent(input);
			dispatchEvent(me);
		}
		
		
		public function WriteRawMessage(output:String):void{
			trace( '->', output );
			
			var array: ByteArray = new ByteArray();
			var i: int = 0;
			var j: int = output.length;
		
			while ( i < j )
				array.writeByte( output.charCodeAt( i++ ) );
						
			array.writeByte( 0x0D );
			array.writeByte( 0x0A );
			
			writeBytes( array, 0, array.length );
			flush();
		}
	}
}
