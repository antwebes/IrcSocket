/*
 * FIRC: A IRC Client for Flash Player 9 and above
 * Copyright (C) 2005-2006 Darron Schall <darron@darronschall.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 * 02111-1307 USA
 */
package irc
{
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListData;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	


	public class IrcNick
	{
		[Bindable] public var mNick:String;
		[Bindable] public var fNick:String;
		private var mVoiced:Boolean;
		private var mOped:Boolean;
		
		public function IrcNick(nick:String="") {
			
			mVoiced = false;
			mOped = false;
			mNick=nick;
			
			if(nick.charAt(0) == "+") {
				mVoiced = true;
				mNick=nick.substr(1);				
			}
			if(nick.charAt(0) == "@") {
				mOped = true;
				mNick=nick.substr(1);
			}
			fNick = IrcNick.formatNick(this);
			var loader:Loader=new Loader(); 
						
		}		

		public function renombrar(s:String):void {
			mNick=s;
			fNick = IrcNick.formatNick(this);
		}
	
		public function get Nick():String {
			return mNick;
		}

		public function set Nick(value:String):void {
			mNick = value;
			fNick = value;
		}
		
		
		public function get Oped():Boolean {
			return mOped;
		}
		
		public function get Voiced():Boolean {
			return mVoiced;
		}
		
		public function set Oped(value:Boolean):void {
			mOped = value;
		}
		
		public function set Voiced(value:Boolean):void {
			mVoiced = value;
		}
		
	
				
		
		//To sort the nicklist (@>+>...)
		static public function sortNick(a:IrcNick, b:IrcNick, fields:Array=null):int {
			if(a == null || b == null) return -1;
			
			if(a.Oped && !b.Oped) return -1;
			if(b.Oped && !a.Oped) return 1;
			
			if(a.Voiced && !b.Voiced) return -1;
			if(b.Voiced && !a.Voiced) return 1;
			
			if(a.Nick.toLocaleLowerCase() < b.Nick.toLocaleLowerCase()) return -1;
			if(a.Nick.toLocaleLowerCase() > b.Nick.toLocaleLowerCase()) return 1;
			return 0
		}

		
		//Format the nickname with the flags (+o, +v)
		static public function formatNick(item:IrcNick):String {
			var res:String;
			if(item.Oped) return "@" + item.Nick;
			if(item.Voiced) return "+" + item.Nick;
			return item.Nick;
		}
		
	}
} 