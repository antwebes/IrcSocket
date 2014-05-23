package es.antweb.ircsocket {
	import flash.net.Socket;

	import flash.utils.*;
	
	import flash.external.ExternalInterface;	

	/**
	 * @author ant4
	 */
	public class IRCSocket extends Socket {
		/** The buffer for received messages */
		private var buffer:String;	
				
		private var input: String;
		
		public function ReadMessage():void {
			var me:RecvMessageEvent = null;
			
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

							ExternalInterface.call('console.log', input);
							me = new RecvMessageEvent(input);
							dispatchEvent(me);	
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
			
			me = new RecvMessageEvent(input);
			dispatchEvent(me);	
		}
		
		public function WriteRawMessage(output:String):void{
			trace( '->', output );
			ExternalInterface.call('console.log', output);
			
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
