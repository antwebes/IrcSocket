/*
*
* ADOBE CONFIDENTIAL
* ___________________
*
* Copyright [2007-2010] Adobe Systems Incorporated
* All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains
* the property of Adobe Systems Incorporated and its suppliers,
* if any.  The intellectual and technical concepts contained
* herein are proprietary to Adobe Systems Incorporated and its
* suppliers and are protected by trade secret or copyright law.
* Dissemination of this information or reproduction of this material
* is strictly forbidden unless prior written permission is obtained
* from Adobe Systems Incorporated.
*/
package com.adobe.rtc.events
{
	import flash.events.Event;

	/**
	 * Emitted by <code>Roster</code>  this event class notifies changes in data of the Roster. It is fired by the Roster's internal Itemrenderer
	 * 
	 * @see com.adobe.rtc.pods.Roster
	 */
	
   public class  RTCEvent extends Event
	{
		/**
		 *  This event is fired when the data is changed...
		 */
		public static const DATA_CHANGE:String = "dataChange";
		
		public function RTCEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		public override function clone():Event
		{
			return new RTCEvent(type, bubbles, cancelable);
		}
		
	}
}