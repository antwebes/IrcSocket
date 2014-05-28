// ActionScript file
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
package com.adobe.rtc.archive
{
	import com.adobe.rtc.authentication.PlaybackAuthenticator;
	import com.adobe.rtc.core.session_internal;
	import com.adobe.rtc.events.ArchiveEvent;
	import com.adobe.rtc.events.SessionEvent;
	import com.adobe.rtc.session.ConnectSession;
	import com.adobe.rtc.session.IConnectSession;
	import com.adobe.rtc.session.ISessionSubscriber;
	import com.adobe.rtc.session.managers.SessionManagerBase;
	import com.adobe.rtc.session.managers.SessionManagerPlayback;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	/**
	 * The <code>currentTimeChange</code> is dispatched when: 
	 * <ul>
	 *   <li>When the recording is played back, developers can add handlers to get the current playback time.</li>
	 * </ul>
	 * 
	 * @eventType com.adobe.rtc.events.ArchiveEvent
	 */
	[Event(name="currentTimeChange", type="com.adobe.rtc.events.ArchiveEvent")]

	/**
	 * Dispatched when the total playback time changes.
	 *
	 * @eventType com.adobe.rtc.events.ArchiveEvent
	 */
	[Event(name="totalTimeChange", type="com.adobe.rtc.events.ArchiveEvent")]
	/**
	 * Dispatched when the recording changes i.e. starts/stops.
	 *
	 * @eventType com.adobe.rtc.events.ArchiveEvent
	 */
	[Event(name="recordingChange", type="com.adobe.rtc.events.ArchiveEvent")]
	/**
	 * Dispatched when the playback changes i.e. starts/stops.
	 *
	 * @eventType com.adobe.rtc.events.ArchiveEvent
	 */
	[Event(name="playbackChange", type="com.adobe.rtc.events.ArchiveEvent")]
	
	/**
	 * The fundamental class behind archive and playback.
	 * This can retrived from your connectsession.
	 * This class contains APIs for recording and playback.
	 * It also throws events on various property changes such as totaltime, currenttime etc.
	 */
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


	public class ArchiveManager extends EventDispatcher implements ISessionSubscriber
	{
		public const DEFAULT_ARCHIVE_ID:String = "__defaultArchive__";
		
		/**
		 * @private 
		 */		
		protected var _connectSession:IConnectSession = ConnectSession.primarySession;
		/**
		 * @private
		 */
		protected var _sessionManager:SessionManagerBase ;
		
		/**
		 * Current time for playback
		 */
		//[Bindable (event="currentTimeChange")]
		public var currentTime:Number = 0;
		
		/**
		 * Total time for playback
		 */
		//[Bindable (event="totalTimeChange")]
		public var totalTime:Number = 0 ;
		
		/**
		 * @private 
		 */
		protected var _recording:Boolean = false;
		
		/**
		 * 
		 */
		protected var _archiveID:String = DEFAULT_ARCHIVE_ID;
		/**
		 * @private 
		 */
		protected var _isCollectionRecording:Object = new Object();
		/**
		 * @private 
		 */
		protected var _isRecordingStreamType:Object = new Object();
		/**
		 * @private 
		 */
		protected var _isRecordingAllStreams:Boolean = false;
		/**
		 * @private
		 */
		 protected var _isPaused:Boolean = false ;
	
		
		public function ArchiveManager()
		{			
			super();
		}
		
		/**
		 * Returns true if the connectSession is synchronized
		 */
		public function get isSynchronized():Boolean
		{
			return _connectSession.isSynchronized ;
		}
		
		/**
		 * @private 
		 */
		public function get sharedID():String
		{
			return null;
		}
		
		/**
		 * @private
		 */
		public function set sharedID(p_id:String):void
		{
			// NO-OP
		}
		
		/**
		 * 
		 * This gives the folder name that contains recording files. If you want to have multiple recordings at the same time without overwrite, you should
		 * assign different archiveID 
		 * @default null
		 */
		public function get archiveID():String 
		{
			return _archiveID ;
		}
		
		/**
		 * @private
		 */
		public function set archiveID(p_archiveID:String):void 
		{
			if (p_archiveID == null)
				p_archiveID = DEFAULT_ARCHIVE_ID;
					
			if ( p_archiveID != _archiveID ) {
				_archiveID = p_archiveID;
				
				if (_sessionManager is SessionManagerPlayback)
					(_sessionManager as SessionManagerPlayback).archiveID  = _archiveID;
			}
		}
		
		/**
		 * Subscribe instantiates the SessionManager object and adds its event handlers.
		 * The handlers are added based on recording/playback mode.
		*/
		public function subscribe():void
		{
			_connectSession.addEventListener(SessionEvent.SYNCHRONIZATION_CHANGE,onSynchronizationChange);
			
			if ( _connectSession.authenticator is PlaybackAuthenticator ) {
				_sessionManager = SessionManagerPlayback(_connectSession.authenticator.session_internal::sessionManager);
				_sessionManager.addEventListener(ArchiveEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
				_sessionManager.addEventListener(ArchiveEvent.TOTAL_TIME_CHANGE, onTotalTimeChange);
			}else {
				_sessionManager = _connectSession.authenticator.session_internal::sessionManager ;
			}

			if (_sessionManager is SessionManagerPlayback) {
				(_sessionManager as SessionManagerPlayback).archiveID  = _archiveID;
			}
		}
		
		/**
		 * Specifies the IConnectSession to which this manager is assigned. 
		 */
		public function get connectSession():IConnectSession
		{
			return _connectSession;
		}
		
		/**
		 * @private
		 */
		public function set connectSession(p_session:IConnectSession):void
		{
			_connectSession = p_session;
		}
		
		//[Bindable (event="recordingChange")]
		/**
		 * [Read-only] Returns true if the recording is in progress.
		 */
		public function get isRecording():Boolean
		{
			return _recording;
		}
		
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		//[Bindable (event="playbackChange")]
		/**
		 * [Read-only]  Returns true if the playback is in progress. 
		 */
		 public function get isPlayingBack():Boolean
		 {
		 	if ( _connectSession && _connectSession.authenticator is PlaybackAuthenticator ) {
		 		return true ;
		 	}
		 	
		 	return false ;
		 }
		
		/**
		 * Starts/Stop the recording. This function calls SessionManager API's for recording messages and streams.
		 */
		public function set recordSession(p_startStop:Boolean):void
		{	
			if (p_startStop!=_recording) {
				_recording = p_startStop;
				_sessionManager.session_internal::recordMessages(p_startStop,null,null,_archiveID);
				_sessionManager.session_internal::recordStreams(p_startStop,null,null,null,_archiveID);
			}
		}
		
		/**
		 * Cleans the sessionManager handlers and disconnects from the network.
		 */
		public function close():void
		{
			if ( _connectSession && _connectSession.authenticator is PlaybackAuthenticator ) {
				_sessionManager.addEventListener(ArchiveEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
				_sessionManager.addEventListener(ArchiveEvent.TOTAL_TIME_CHANGE, onTotalTimeChange);
			}
		}
		
		
		/**
		 * Pauses/Plays the Playback of archive.
		 */
		public function pause(p_toggle:Boolean):void
		{
			if ( currentTime >= totalTime ) {
				return ;
			}
			
			_isPaused = p_toggle ;
			(_sessionManager as SessionManagerPlayback).currentTime = currentTime ;
			(_sessionManager as SessionManagerPlayback).session_internal::pause(p_toggle);
		}
		
		/**
		 * Seeks to Playback the archive from a given time.
		 */
		public function seek(p_time:Number):void
		{
			if ( p_time >= totalTime ) {
				return ;
			}
			
			(_sessionManager as SessionManagerPlayback).session_internal::seek(p_time);
		}
		
		/**
		 * @private
		 */
		protected function onCurrentTimeChange(p_evt:Event):void
		{
			currentTime = (_sessionManager as SessionManagerPlayback).currentTime;
			dispatchEvent(p_evt);
		}

		/**
		 * @private
		 */
		protected function onTotalTimeChange(p_evt:Event):void
		{
			totalTime = (_sessionManager as SessionManagerPlayback).totalTime;
			dispatchEvent(p_evt);
		}
		
		/**
		 * @private
		 */
		 protected function onSynchronizationChange(p_evt:SessionEvent):void
		 {
		 	if ( !_connectSession.isSynchronized ) {
		 		if ( isRecording ) {
		 			recordSession = false ;
		 		}
		 	}
		 }
		 
		 
		// The code below are for recording individual nodes/stream. They will be in release 1.2 or later... 	
		
		/**
		 * @private
		 * Determines whether a particular collection node is recording or not
		 * This is for 1.3 and won't be used in next release
		 */
		public function isCollectionRecording(p_collectionName:String):Boolean
		{
			if ( isRecording) {
				return true ;
			}
			
			if ( _isCollectionRecording[p_collectionName] == null ) {
				return false ;
			}
			
			return _isCollectionRecording[p_collectionName];
		}
		
		
		/**
		 * @private
		 *  Record a particular collection node
		 * This is for 1.3 and won't be used in next release
		 */
		public function recordCollection(p_startStop:Boolean,p_collectionName:String):void
		{
			if ( !isRecording && p_startStop != _isCollectionRecording[p_collectionName]) {
				_isCollectionRecording[p_collectionName] = p_startStop ;
				_sessionManager.session_internal::recordMessages(p_startStop,p_collectionName);
			}
		}
		
		/**
		 * @private
		 * Determines whether a particular type of stream is recorded or not
		 * This is for 1.3 and won't be used in next release
		 */
		public function isRecordingStream(p_type:String=null):Boolean
		{
			if ( isRecording ) {
				return true ;
			}
			
			if ( !p_type ) {
				return _isRecordingAllStreams ;
			}else {
				if ( !_isRecordingStreamType[p_type]) {
					return false ;
				}else {
					return _isRecordingStreamType[p_type];
				} 
			}
			
			return false ;
			
		}
		
		/**
		 * @private
		 *  Record a particular stream
		 *  This is for 1.3 release and won't be used in next release
		 */
		public function recordStream(p_startStop:Boolean,p_type:String=null):void
		{
			if ( ! isRecording ) {
				if ( ! p_type ) {
					if ( p_type != _isRecordingAllStreams ) {
						_isRecordingAllStreams = p_startStop ;
						_sessionManager.session_internal::recordStreams(p_startStop);
					}
				} else {
					if ( !_isRecordingAllStreams ) {
						if ( _isRecordingStreamType[p_type] == null || _isRecordingStreamType[p_type] != p_startStop ) {
							_isRecordingStreamType[p_type] = p_startStop ;
							_sessionManager.session_internal::recordStreams(p_startStop,null,p_type);
						}
					}
				}
			}
		}

	}
}