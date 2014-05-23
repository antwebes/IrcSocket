package es.antweb.ircsocket {
	import flash.utils.getTimer;
	import flash.events.ProgressEvent;
	import flash.display.Sprite;
	import es.antweb.ircsocket.IRCSocket;
	import flash.external.ExternalInterface;

	/**
	 * @author ant4
	 */
	public class Main extends Sprite {
		private var socket : IRCSocket = null;
		private var onreceive_cb : Function = null;

		private function connect(host : String, port : uint) : void {
			try {
				socket.connect(host, port);
				// ExternalInterface.call('alert','connected');
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}

		private function close() : void {
			try {
				socket.close();
				// ExternalInterface.call('alert','closed');
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}

		private function socketReadHandler(event : ProgressEvent) : void {
			try {
				socket.ReadMessage();
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}

		private function write(output : String) : void {
			try {
				socket.WriteRawMessage(output);
				// ExternalInterface.call('alert', output);
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}

		private function receive(evt : RecvMessageEvent) : void {
			try {
				// ExternalInterface.call('alert','have data');
				if (onreceive_cb != null) {
					onreceive_cb(evt.message);
					// ExternalInterface.call('alert','received');
				}
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}

		private function onreceive(callback : Function) : void {
			try {
				onreceive_cb = callback;
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}

		private function flush() : void {
			try {
				socket.flush();
				ExternalInterface.call('alert','flushed');
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}
		}
		
		private function sleep(ms:int):void {
			var init : int = getTimer();
			while (true) {
				if (getTimer() - init >= ms) {
					break;
				}
			}
		}

		public function Main() {
			try {
				socket = new IRCSocket();
				socket.addEventListener(ProgressEvent.SOCKET_DATA, socketReadHandler);
				socket.addEventListener(RecvMessageEvent.RECV_MESS_EVENT_TYPE, receive);

				ExternalInterface.addCallback('connect', connect);
				ExternalInterface.addCallback('close', close);
				ExternalInterface.addCallback('write', write);
				ExternalInterface.addCallback('onreceive', onreceive);
				ExternalInterface.addCallback('flush', flush);
				ExternalInterface.call('alert', 'started');
			} catch(err : Error) {
				ExternalInterface.call('alert', err.toString());
			}

			try {
				connect("fresa.irc.chatsfree.net", 6667);
				write("NICK unsupernick2");
				flush();
				write("USER ident host server :lolaso");
				flush();
				sleep(5000);
				ExternalInterface.call('alert', 'ti que sabras');
			} catch(err : Error) {
			}
		}
	}
}
