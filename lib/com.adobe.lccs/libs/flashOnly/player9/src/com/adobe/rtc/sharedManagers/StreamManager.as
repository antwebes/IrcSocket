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
package com.adobe.rtc.sharedManagers
{
	//importing all the different classes needed 
	import com.adobe.rtc.events.CollectionNodeEvent;
	import com.adobe.rtc.events.ScreenShareEvent;
	import com.adobe.rtc.events.StreamEvent;
	import com.adobe.rtc.events.UserEvent;
	import com.adobe.rtc.messaging.MessageItem;
	import com.adobe.rtc.messaging.NodeConfiguration;
	import com.adobe.rtc.messaging.UserRoles;
	import com.adobe.rtc.pods.cameraClasses.CameraModel;
	import com.adobe.rtc.session.ConnectSession;
	import com.adobe.rtc.session.IConnectSession;
	import com.adobe.rtc.session.ISessionSubscriber;
	import com.adobe.rtc.session.RoomSettings;
	import com.adobe.rtc.sharedManagers.descriptors.On2ParametersDescriptor;
	import com.adobe.rtc.sharedManagers.descriptors.StreamDescriptor;
	import com.adobe.rtc.sharedModel.CollectionNode;
	
	import flash.events.EventDispatcher;
	
	/**
	 * Dispatched when the synchronization changes for the camera.
	 */
	[Event(name="synchronizationChange", type="com.adobe.rtc.events.CollectionNodeEvent")]	

	/**
	 * Dispatched when the my role with respect to a stream changes.
	 */
	[Event(name="myRoleChange", type="com.adobe.rtc.events.CollectionNodeEvent")]
	/**
	 * Dispatched when the user's role with respect to a stream changes.
	 */
	[Event(name="userRoleChange", type="com.adobe.rtc.events.CollectionNodeEvent")]	
	
	/**
	 * Dispatched when the aspect ratio of a video stream changes.
	 */
	[Event(name="aspectRatioChange", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * Dispatched when the room recieves a new stream.
	 */
	[Event(name="streamReceive", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * Dispatched when a stream is removed from the room.
	 */
	[Event(name="streamDelete", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * Dispatched when the dimensions of a video stream change.
	 */
	[Event(name="dimensionsChange", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * Dispatched when the bandwidth settings for a stream change.
	 */
	[Event(name="bandwidthChange", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * Dispatched when a stream is paused or muted.
	 */
	[Event(name="streamPause", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * Dispatched when the volume of an audio stream changes.
	 */
	[Event(name="volumeChange", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	* @private
	*/
	[Event(name="noStreamDetected", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	* @private
	*/
	[Event(name="streamSelect", type="com.adobe.rtc.events.StreamEvent")]
	
	/**
	 * @private
	 */
	[Event(name="receivedCancelControl", type="com.adobe.rtc.events.ScreenShareEvent")]
	
	/**
	 * One of the "4 pillars" of a room, the StreamManager represents the shared model 
	 * for files available for client download. It expresses a variety of methods 
	 * for other components to access, modify, or publish specific audio and video streams. 
	 * StreamManager uses StreamDescriptors as control metadata to represent the available 
	 * streams. Streams themselves may be published, modified, and subscribed to through 
	 * Audio/WebcamSubscriber and Audio/WebcamPublisher (in general those classes are an 
	 * easier interface for this achieving this functionality).
	 * 
	 * <p>The StreamManager keep Streams in "groups" representing the type of Stream (for 
	 * example, Webcam, VOIP) with permissions settable on a per-group basis. By default, 
	 * only users with a publisher role and higher may publish a stream and users with a 
	 * viewer role and higher are able to subscribe.</p>
	 * 
	 * <p> Most of the API's have a <code class="property">p_groupName</code> parameter that identifies the group to which
	 * a set of streams belong. Each stream group has a set of four nodes associated with themselves
	 * (each node identifying a type of stream like Webcam , VOIP, etc)
	 * There is a default group of streams if the <code class="property">groupName</code> is null, and any new group that is 
	 * created creates these set of four streams for that group. Grouping streams by a group name
	 * helps identify multiple camera, voip, screenshare streams with different configurations as well 
	 * as support multiple rooms where each room has a unique set of streams.
	 * One user can publish only one specific stream type within a group.</p> 
	 * 
	 * <p>Each IConnectSession handles creation/setup of its own StreamManager instance.  Use an <code>IConnectSession</code>'s
	 *  <code class="property">streamManager</code> property to access it.</p>
	 *  
	 * @see com.adobe.rtc.sharedManagers.descriptors.StreamDescriptor
	 * @see com.adobe.rtc.collaboration.AudioPublisher
	 * @see com.adobe.rtc.collaboration.AudioSubscriber
	 * @see com.adobe.rtc.collaboration.WebcamPublisher
	 * @see com.adobe.rtc.collaboration.WebcamSubscriber
	 * @see com.adobe.rtc.events.StreamEvent
	 * @see com.adobe.rtc.session.IConnectSession
	 */
   public class  StreamManager extends EventDispatcher implements ISessionSubscriber
	{
		/**
		 * The name of the <code>collectionNode</code> used to represent the shared 
		 * model of the StreamManager.
		 */
		public static const COLLECTION_NAME:String = "AVManager";
		
		/**
		 * Constant for identifying Audio Streams; for example, VOIP streams from a 
		 * computer microphone.
		 */
		public static const AUDIO_STREAM:String = "audio";
		
		/**
		 * Constant for identifying Camera Streams; for example, webcam streams 
		 * from a computer camera.
		 */
		public static const CAMERA_STREAM:String = "camera";

		/**
		 * Constant for identifying Screen Share Streams
		 */
		public static const SCREENSHARE_STREAM:String = "screenShare";

		/**
		 * @private
		 */
		public static const REMOTE_CONTROL_STREAM:String = "remoteControl";
		
		/**
		 * @private
		 */
		public static const SCREEN_SHARING_SETTINGS:String = "screenSharingSettings";
		
		/**
		 * @public
		 */
		public static const REMOTE_CONTROL_CANCEL_NOTIFICATION:String = "remoteControlCancel";
		
		/**
		 * @private
		 */
		protected static const CAMERA_SETTINGS:String = "cameraSettings";

		/**
		 * Constant for specifying a portrait aspect ratio on a video stream.
		 */
		public static const AR_PORTRAIT:String = "portrait";
		
		/**
		 * Constant for specifying a standard aspect ratio on a video stream.
		 */
		public static const AR_STANDARD:String = "standard";
		
		/**
		 * Constant for specifying a landscape aspect ratio on a video stream.
		 */
		public static const AR_LANDSCAPE:String = "landscape";
				
		/**
		 * @private
		 */
		public static const AR_PORTRAIT_W:Number = 144;
		
		/**
		 * @private
		 */
		public static const AR_PORTRAIT_H:Number = 112;

		/**
		 * @private
		 */
		public static const AR_STANDARD_W:Number = 128;
		
		/**
		 * @private
		 */
		public static const AR_STANDARD_H:Number = 128;

		/**
		 * @private
		 */
		public static const AR_LANDSCAPE_W:Number = 160;
		
		/**
		 * @private
		 */
		public static const AR_LANDSCAPE_H:Number = 96;		

		/**
		 *	Node for publishing the audio streams.
		 *	@private
		*/
		protected const NODE_NAME_AUDIO_STREAM:String = "audioStreams";
		
		/**
		 * 	Node for publishing the camera streams.
		 *	@private
		*/
		protected const NODE_NAME_CAMERA_STREAM:String = "cameraStreams";
		
		/**
		 * Node for publishing the screenshare streams. 
		 *	@private
		*/
		protected const NODE_NAME_SCREENSHARE_STREAM:String = "screenShareStreams";
		
		/**
		 * @private
		 */
		protected const NODE_NAME_REMOTE_CONTROL_STREAM:String = "remoteControlStreams";
		
		/**
		 * Node for defining the aspect ratio.
		 *	@private
		*/
		protected const NODE_NAME_ASPECT_RATIO:String = "aspectRatio";
		
		/**
		 * Node for remote control notification
		 */
		protected const NODE_NAME_REMOTE_CONTROL_NOTIFICATION:String = "remoteControlNotification";
		
		/**
		 * Default constant for the various data structures supporting default groups
		 *	@private
		*/
		protected const DEFAULT:String = "default" ;
				
		/**
		 * @private
		 * AspectRatio of the streams, relevant for video streams. 
		 */
		protected var _aspectRatio:String = AR_STANDARD;
		
		/**
		 * @private
		 */
		protected var _screenSharingSettings:Object;
		
		/**
		 * @private
		 */
		protected var _cameraSettings:Object;
		
		/**
		 * @private
		 */
		protected var _on2ParamsTable:Object;
		
		/**
		 * @private 
		 */
		protected var _connectSession:IConnectSession = ConnectSession.primarySession;
		
		/**
		 * @private
		 * Object containing hashes of <code>streamDescriptors</code>. Objects are 
		 * hashed on the stream descriptor's ID.
		 *
		 * Hash(streamType, Hash(streamID, StreamDescriptor))
		 */
		protected var _streamTypeDescriptors:Object;
		
		/**
		 * @private
		 *  NodeCollection Variable. All various stream types are child nodes to this NodeCollection.
		 */
		protected var _collectionNode:CollectionNode; 
		/**
		 * @private
		 * _userManager variable
		 */
		protected var _userManager:UserManager;
		/**
		* @private
		* User Role for Publish
		*/		
		protected static var _userRoleForPublish:Object;
				
		/**
		 * @private
		 */
		protected var _streamToNodeNameTable:Object ;
		
		/**
		 * @private
		 */
		 protected var _groupNames:Array = new Array();
		 /**
		 * @private
		 */
		 protected var _creatingGroup:Boolean = false ;
		 /**
		 * @private
		 */
		 protected var _tempGroupName:String ;
		 /**
		 * @private
		 */
		 protected var _allowPrivateStreams:Boolean = false ;
		 /**
		 * @private
		 */
		 private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
		 /**
		 * @private
		 * This variable is used by both the audio publisher and camera publisher to see if one has allowed/denied access 
		 * to the web cam...
		 */
		 public var camAudioPermissionDenied:Boolean = false ;

		/**
		 * Constructor.
		 */
		public function StreamManager()
		{	
			initializeModel();
			
		}
		
		/**
		 * (Read Only) Specifies the IConnectSession to which this manager is assigned. 
		 */
		public function get connectSession():IConnectSession
		{
			return _connectSession;
		}
		
		/**
		 * Sets the IConnectSession to which this manager is assigned. 
		 */
		public function set connectSession(p_session:IConnectSession):void
		{
			_connectSession = p_session;
		}
		
		/**
		 * @private 
		 */
		public function get sharedID():String
		{
			return COLLECTION_NAME;
		}
		
		/**
		 * @private
		 */
		public function set sharedID(p_id:String):void
		{
			// NO-OP
		}
		//[Bindable(event="synchronizationChange")]
		
		/**
		 * Returns true if the model is synchronized.
		 */
		public function get isSynchronized():Boolean
		{
			if (_collectionNode) {
				return _collectionNode.isSynchronized ;
			} else { 
				return false;
			}
		}
		
		/**
		 *  Returns whether private streaming is allowed.
		 *  Currently when we set , we set for all streams( both camera and audio). Setting Permission on Stream Type Basis is not there now.
		 *  @default false
		 */
		 public function get allowPrivateStreams():Boolean
		 {
		 	if ( _collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM)) {
		 		if ( _collectionNode.getNodeConfiguration(NODE_NAME_AUDIO_STREAM) != _allowPrivateStreams ) {
		 			_allowPrivateStreams = _collectionNode.getNodeConfiguration(NODE_NAME_AUDIO_STREAM).allowPrivateMessages ;
		 		}
		 	}
		 	
		 	return _allowPrivateStreams ;
		 }
		 
		 public function set allowPrivateStreams(p_allowPrivateStream:Boolean):void
		 {
		 	if ( _userManager.myUserRole < UserRoles.OWNER ) {
		 		throw new Error("You do not have necessary permission to change this property. Only owners can change this property.");
		 		return ;
		 	}
		 	
		 	if ( _allowPrivateStreams == p_allowPrivateStream ) {
		 		return ;
		 	}
		 	
		 	_allowPrivateStreams = p_allowPrivateStream ;
		 	
		 	// changing node Config for audio ;
		 	var audioNodeConfig:NodeConfiguration = getNodeConfiguration(AUDIO_STREAM);
		 	audioNodeConfig.allowPrivateMessages = _allowPrivateStreams ;
		 	setNodeConfiguration(audioNodeConfig,AUDIO_STREAM);
		 	
		 	// changing node Config for camera ;
		 	var cameraNodeConfig:NodeConfiguration = getNodeConfiguration(CAMERA_STREAM);
		 	cameraNodeConfig.allowPrivateMessages = _allowPrivateStreams ;
		 	setNodeConfiguration(cameraNodeConfig,CAMERA_STREAM);
		 	
		 	
		 	// changing node Config for screen Share ;
		 	var screenShareNodeConfig:NodeConfiguration = getNodeConfiguration(SCREENSHARE_STREAM);
		 	screenShareNodeConfig.allowPrivateMessages = _allowPrivateStreams ;
		 	setNodeConfiguration(screenShareNodeConfig,SCREENSHARE_STREAM);
		 	
		 		// changing node Config for remote control Screen ;
		 	var remoteControlNodeConfig:NodeConfiguration = getNodeConfiguration(REMOTE_CONTROL_STREAM);
		 	remoteControlNodeConfig.allowPrivateMessages = _allowPrivateStreams ;
		 	setNodeConfiguration(remoteControlNodeConfig,REMOTE_CONTROL_STREAM);
		 	
		 }
		 
		
		/**
		 * @private
		 * On Closing session.
		 */
		public function close():void
		{
			//NO OP
		}
		
		
		/**
		 * Sets the role of the specified user for a particular type 
		 * of stream. Only users with an owner role may call this method.
		 * 
		 * @param p_userID The specified user's <code>userID</code>.
		 * @param p_role The role desired.
		 * @param p_streamName The type of stream specified by one of StreamManager's stream type constants.
		 * @param p_groupName The group name on which the user role is being set. The default is null.
		 */ 
		public function setUserRole(p_userID:String, p_role:int, p_streamType:String , p_groupName:String = null):void
		{
			if ( p_groupName == null ) 
				_collectionNode.setUserRole(p_userID, p_role, _streamToNodeNameTable[p_streamType][DEFAULT]);
			else 
				_collectionNode.setUserRole(p_userID, p_role, _streamToNodeNameTable[p_streamType][p_groupName]);
		}
		
		/**
		 * Gets the role of the specified user for a particular type of stream. 
		 * 
		 * @param p_userID The specified user's <code>userID</code>.
		 * @param p_streamName The type of stream specified by one of StreamManager's stream type constants.
		 * @param p_groupName The group name for which we are getting the user roles. The default is null
		 * 
		 * @return int which is the user role value
		 */
		public function getUserRole(p_userID:String, p_streamType:String , p_groupName:String = null):int
		{
			if (!_collectionNode) {
				return -1;
			}
			if ( p_groupName == null ) 
				return _collectionNode.getUserRole(p_userID, _streamToNodeNameTable[p_streamType][DEFAULT]);
			else 
				return _collectionNode.getUserRole(p_userID, _streamToNodeNameTable[p_streamType][p_groupName]);
		}
		
		/**
		 * Whether or not a specified user may adjust roles or permissions for a given stream type. 
		 *
		 * @param p_userID The specified user's <code>userID</code>.
		 * @param p_streamName The type of stream specified by one of StreamManager's stream type constants.
		 * @param p_groupName The group name for which the user has the right to configure the nodes. The default is null.
		 *
		 * @return True if the user can configure; false if not.
		 */
		public function canUserConfigure(p_userID:String, p_streamType:String , p_groupName:String = null):Boolean
		{
			if ( p_groupName == null ) {
				if ( p_streamType == AUDIO_STREAM ) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_AUDIO_STREAM);
				else if ( p_streamType == CAMERA_STREAM ) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_CAMERA_STREAM);
				else if ( p_streamType == SCREENSHARE_STREAM) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_SCREENSHARE_STREAM);
				else if ( p_streamType == REMOTE_CONTROL_STREAM ) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_REMOTE_CONTROL_STREAM);
			} else {
				if ( p_streamType == AUDIO_STREAM ) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_AUDIO_STREAM + "_" + p_groupName);
				else if ( p_streamType == CAMERA_STREAM ) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_CAMERA_STREAM + "_" + p_groupName);
				else if ( p_streamType == SCREENSHARE_STREAM) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName);
				else if ( p_streamType == REMOTE_CONTROL_STREAM ) 
					return _collectionNode.canUserConfigure(p_userID, NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName);
			}
			
			return false ;
				
		}
		
		
		/**
		 * Whether or not a specified user may publish streams of a given stream type.
		 * 
		 * @param p_userID The specified user's <code>userID</code>.
		 * @param p_streamName The type of stream specified by one of StreamManager's stream type constants.
		 * @param p_groupName The group name to check to see if the user has a right to publish. The default is null.
		 * 
		 * @return true if the user can publish, false if not
		 */
		public function canUserPublish(p_userID:String, p_streamType:String , p_groupName:String = null):Boolean
		{
			if ( p_groupName == null ) {
				if ( p_streamType == AUDIO_STREAM ) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_AUDIO_STREAM);
				else if ( p_streamType == CAMERA_STREAM ) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_CAMERA_STREAM);
				else if ( p_streamType == SCREENSHARE_STREAM) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_SCREENSHARE_STREAM);
				else if ( p_streamType == REMOTE_CONTROL_STREAM ) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_REMOTE_CONTROL_STREAM);
			} else {
				if ( p_streamType == AUDIO_STREAM ) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_AUDIO_STREAM + "_" + p_groupName);
				else if ( p_streamType == CAMERA_STREAM ) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_CAMERA_STREAM + "_" + p_groupName);
				else if ( p_streamType == SCREENSHARE_STREAM) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName);
				else if ( p_streamType == REMOTE_CONTROL_STREAM ) 
					return _collectionNode.canUserPublish(p_userID, NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName);
			}
			
			return false ;
		}
		
	
		/**
		 * Sets the node configuration on a specific stream node such as an audio or camera node 
		 * within a group, or else it sets it on all nodes.
		 * 
		 * @param p_nodeConfiguration The NodeConfiguration you want to set on the nodes.
		 * @param p_streamType The type of stream specified by one of StreamManager's stream type constants. 
		 * If it is null, then Nodeconfiguration is set on all stream nodes.
		 * @param p_groupName The group name for the node(s) to configure. The default is null.
		 * 
		 */	
		public function setNodeConfiguration(p_nodeConfiguration:NodeConfiguration ,p_streamType:String=null , p_groupName:String=null ):void
		{
			if ( p_nodeConfiguration == null ) {
				return ;
			}
			
			var nodeName :String ;
			if ( p_streamType != null ) {
				if( p_streamType == AUDIO_STREAM ) {
					nodeName = NODE_NAME_AUDIO_STREAM ;
				} else if ( p_streamType == CAMERA_STREAM ) {
					nodeName = NODE_NAME_CAMERA_STREAM ;
				} else if( p_streamType == SCREENSHARE_STREAM ) {
					nodeName = NODE_NAME_SCREENSHARE_STREAM ;
				} else if ( p_streamType == REMOTE_CONTROL_STREAM ) {
					nodeName = NODE_NAME_REMOTE_CONTROL_STREAM ;
				} else {
					return ;
				}
				
			}
			
			if ( p_nodeConfiguration.allowPrivateMessages != _allowPrivateStreams ) {
				// if some user directly sets the private streaming through setNodeConfig , we should be able to handle that case.
				_allowPrivateStreams = p_nodeConfiguration.allowPrivateMessages ;
			}
			
			
			if ( p_streamType != null ) {
				if ( p_groupName == null ) {
					_userRoleForPublish[p_streamType][DEFAULT] = p_nodeConfiguration.publishModel ;
					_collectionNode.setNodeConfiguration(nodeName,p_nodeConfiguration);
				}else {
					_userRoleForPublish[p_streamType][p_groupName] = p_nodeConfiguration.publishModel ;
					_collectionNode.setNodeConfiguration(nodeName + "_" + p_groupName,p_nodeConfiguration);
				}
			}else {
				if ( p_groupName == null ) {
					_userRoleForPublish[AUDIO_STREAM][DEFAULT] = p_nodeConfiguration.publishModel;
					_userRoleForPublish[CAMERA_STREAM][DEFAULT] = p_nodeConfiguration.publishModel;
					_userRoleForPublish[SCREENSHARE_STREAM][DEFAULT] = p_nodeConfiguration.publishModel;
					_userRoleForPublish[REMOTE_CONTROL_STREAM][DEFAULT] = p_nodeConfiguration.publishModel;
					
					_collectionNode.setNodeConfiguration(NODE_NAME_AUDIO_STREAM,p_nodeConfiguration);
					_collectionNode.setNodeConfiguration(NODE_NAME_CAMERA_STREAM,p_nodeConfiguration);
					_collectionNode.setNodeConfiguration(NODE_NAME_SCREENSHARE_STREAM,p_nodeConfiguration);
					_collectionNode.setNodeConfiguration(NODE_NAME_REMOTE_CONTROL_STREAM,p_nodeConfiguration);
				}else {
					_userRoleForPublish[AUDIO_STREAM][p_groupName] = p_nodeConfiguration.publishModel;
					_userRoleForPublish[CAMERA_STREAM][p_groupName] = p_nodeConfiguration.publishModel;
					_userRoleForPublish[SCREENSHARE_STREAM][p_groupName] = p_nodeConfiguration.publishModel;
					_userRoleForPublish[REMOTE_CONTROL_STREAM][p_groupName] = p_nodeConfiguration.publishModel;
					
					_collectionNode.setNodeConfiguration(NODE_NAME_AUDIO_STREAM + "_" + p_groupName,p_nodeConfiguration);
					_collectionNode.setNodeConfiguration(NODE_NAME_CAMERA_STREAM + "_" + p_groupName,p_nodeConfiguration);
					_collectionNode.setNodeConfiguration(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName,p_nodeConfiguration);
					_collectionNode.setNodeConfiguration(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName,p_nodeConfiguration);
				}
			}
		} 
		
		/**
		 * Gets the NodeConfiguration on a specific stream node (for example Audio or Camera) within a group.
		 *
		 * @param p_streamType The type of stream for the node on which we are returning the NodeConfiguration.
		 * @param p_groupName The group name for the node on which we are returning the NodeConfiguration. The default is null.
		 * 
		 */
		public function getNodeConfiguration( p_streamType:String , p_groupName:String=null ):NodeConfiguration
		{
			var nodeName :String ;
			if ( p_streamType != null ) {
				if( p_streamType == AUDIO_STREAM ) {
					nodeName = NODE_NAME_AUDIO_STREAM ;
				} else if ( p_streamType == CAMERA_STREAM ) {
					nodeName = NODE_NAME_CAMERA_STREAM ;
				} else if( p_streamType == SCREENSHARE_STREAM ) {
					nodeName = NODE_NAME_SCREENSHARE_STREAM ;
				} else if ( p_streamType == REMOTE_CONTROL_STREAM ) {
					nodeName = NODE_NAME_REMOTE_CONTROL_STREAM ;
				} else {
					return null;
				}
				
			}
				
			if ( !_collectionNode.isNodeDefined(nodeName)) {
				return null ;
			}
			
			if ( p_groupName == null ) {
				return _collectionNode.getNodeConfiguration(nodeName);
			}else {
				return _collectionNode.getNodeConfiguration(nodeName + "_" + p_groupName);
			}
			
			
			return null ;
			
		}
		
		/**
		 * @private
		 */
		public function set screenSharingSettings(on2params:Object):void
		{
			_screenSharingSettings.quality = on2params.quality;
			_screenSharingSettings.quality = on2params.quality;
			_screenSharingSettings.performance = on2params.performance
			_screenSharingSettings.kf = on2params.keyframeInterval;
			_screenSharingSettings.fps = on2params.fps;
			_screenSharingSettings.enableHFSS = on2params.enableHFSS;
			
		}
		/**
		 * @private
		 */
		public function get screenSharingSettings():Object
		{
			return _screenSharingSettings;
		}
		
		/**
		 * @private
		 */
		public function get cameraSettings():Object
		{
			return _cameraSettings;
		}
		
		/**
		 * @private
		 */
		public function get on2ParamsTable():Object
		{
			return _on2ParamsTable;
		}

		/**
		 * @private
		 */
		public function subscribe():void
		{
			if (!_userManager) {
				_userManager = _connectSession.userManager; // creates the user manager from the connect session
				_userManager.addEventListener(UserEvent.SYNCHRONIZATION_CHANGE, onUserManagerSync);
			}

			initializeModel();
			
			_collectionNode = new CollectionNode(); // creates the collection
			_collectionNode.sharedID = COLLECTION_NAME ; // assigning a name to  collection node, for details look asdocs of Collection Node
			_collectionNode.connectSession = _connectSession;
			// adding all the event handlers for the colllection
			_collectionNode.addEventListener(CollectionNodeEvent.SYNCHRONIZATION_CHANGE, onSynchronizationChange); 
			_collectionNode.addEventListener(CollectionNodeEvent.ITEM_RECEIVE, onItemReceive);
			_collectionNode.addEventListener(CollectionNodeEvent.ITEM_RETRACT, onItemRetract);
			_collectionNode.addEventListener(CollectionNodeEvent.MY_ROLE_CHANGE,onMyRoleChange);
			_collectionNode.addEventListener(CollectionNodeEvent.USER_ROLE_CHANGE,onUserRoleChange);
			_collectionNode.addEventListener(CollectionNodeEvent.NODE_CREATE,onNodeCreate);
			
			//subscribing to the collection
			_collectionNode.subscribe();
		}

		
		/**
		 * Initiates a new stream of a given type from the current client or else requests 
		 * another user to begin publishing.
 		 * 
		 * @param p_streamDescriptor The stream descriptor being published. If it is null, it returns an error.
		 * 
		 */
		public function createStream(p_streamDescriptor:StreamDescriptor):void
		{
			
			if ( p_streamDescriptor == null ) {
				throw new Error("The stream cannot be created because the descriptor is null.");
				return;
			}
			
			if ( p_streamDescriptor.type == null) {
				throw new Error("The stream cannot be created because the stream type is null.");
				return;
			}
			
			if ( getStreamDescriptor(p_streamDescriptor.type,p_streamDescriptor.streamPublisherID,p_streamDescriptor.groupName) != null ) {
				throw new Error("The stream cannot be created because it already exists.");
				return;
			}
			
			p_streamDescriptor.id = createUID();
			
			// finally assign the uniquedID created above to the stream's id
			//sets the finished publishing value to given value , user is responsible for this value, default is false.
			//stream will get published only when it is true and also if the user has given permission to access his microphone/camera devices	
			var mItem:MessageItem;
			// based on the type of stream, create a value object from the streamdescriptor with itemID as uniqueID which is also streamdescriptor's id.
			if ( p_streamDescriptor.groupName == null ) {
				publishStreamItem(p_streamDescriptor);	
			} else {
				if ( !isGroupDefined(p_streamDescriptor.groupName) ) {
					createGroup(p_streamDescriptor.groupName);
				}
				publishStreamItem(p_streamDescriptor,p_streamDescriptor.groupName);	
			}	
	
		}	
		
		/**
		 * Publishes the already created <code>streamDescriptor</code> with the given type, streampublisher ID
		 * and group name, if any.
		 * 
		 * @param p_streamType The <code>streamDescriptor</code>'s type.
		 * @param p_streamPublisherID The <code>streamDescriptor</code>'s ID.
		 * @param p_groupName The <code>streamDescriptor</code>'s group name.
		 */
		public function publishStream(p_streamType:String , p_streamPublisherID:String , p_groupName:String = null,p_recipientIDs:Array = null ):void
		{
			var streamDescriptor:StreamDescriptor = copyDescriptor(getStreamDescriptor(p_streamType,p_streamPublisherID,p_groupName)) ;
		
			if ( streamDescriptor == null ) {
				throw new Error("The stream cannot be published because it does not exist.");
				return;
			}
			
			streamDescriptor.finishPublishing = true ; 
			
			if ( _allowPrivateStreams ) {
				streamDescriptor.recipientIDs = p_recipientIDs ;
			}
			
			publishStreamItem(streamDescriptor,p_groupName);
		}

		/**
		 * Deletes the <code>streamDescriptor</code> with the specified type and publisher ID and thereby indicates
		 * that the associated stream will stop publishing. A user with an owner role
		 * may use this method to cancel another user's attempt to publish a stream.
		 * 
		 * @param p_streamType The <code>streamDescriptor</code>'s type.
		 * @param p_streamPublisherID The <code>streamDescriptor</code>'s ID.
		 * @param p_groupName The <code>streamDescriptor</code>'s group name.
		 */
		public function deleteStream(p_streamType:String , p_streamPublisherID:String , p_groupName:String = null ):void
		{
			// _streamTypeDescriptors[p_type][p_id] gives the stream and if it is not null,  based on type, delete the stream i.e. retract the
			//message item from the network
			
			var streamDescriptor:StreamDescriptor ;
			
			//this stream doesnt even exists
			if ( _streamTypeDescriptors[p_streamType][p_streamPublisherID] == null ) 
				return ;
			
			if ( p_groupName == null ) {
				streamDescriptor = _streamTypeDescriptors[p_streamType][p_streamPublisherID][DEFAULT] ;
			}else {
				streamDescriptor = _streamTypeDescriptors[p_streamType][p_streamPublisherID][p_groupName] ;
			}
			
			
			if(p_groupName == null){
				if(p_streamType==AUDIO_STREAM)
					_collectionNode.retractItem(NODE_NAME_AUDIO_STREAM,p_streamPublisherID);
				else if(p_streamType==CAMERA_STREAM)
					_collectionNode.retractItem(NODE_NAME_CAMERA_STREAM, p_streamPublisherID);
				else if(p_streamType==SCREENSHARE_STREAM)
					_collectionNode.retractItem(NODE_NAME_SCREENSHARE_STREAM, p_streamPublisherID);
				else if(p_streamType==REMOTE_CONTROL_STREAM)
					_collectionNode.retractItem(NODE_NAME_REMOTE_CONTROL_STREAM, p_streamPublisherID);
			}else {
				if(p_streamType==AUDIO_STREAM)
					_collectionNode.retractItem(NODE_NAME_AUDIO_STREAM + "_" + p_groupName,p_streamPublisherID);
				else if(p_streamType==CAMERA_STREAM)
					_collectionNode.retractItem(NODE_NAME_CAMERA_STREAM + "_" + p_groupName, p_streamPublisherID);
				else if(p_streamType==SCREENSHARE_STREAM)
					_collectionNode.retractItem(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName, p_streamPublisherID);
				else if(p_streamType==REMOTE_CONTROL_STREAM)
					_collectionNode.retractItem(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName, p_streamPublisherID);
			}
		}
			
		/**
		 * Mutes an audio stream based on type, state (muted or non muted), and publisher ID. 
		 * 
		 * @param p_type The stream type which is one of the streamManager constants.
		 * @param p_state The stream's state; true for muted or false for unmuted.
		 * @param p_publisherID The <code>userID</code> of the stream's publisher.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function muteStream(p_streamType:String,p_state:Boolean=false,p_streamPublisherID:String=null, p_groupName:String = null,p_recipientIDs:Array= null):void
		{
			// This function gets all the streams with a give publisher ID and then finds the stream to mute/unmute
			var streamDesc:StreamDescriptor
			
			if(p_streamType==AUDIO_STREAM){	//executes for audio stream only
				streamDesc = copyDescriptor(getStreamDescriptor(p_streamType,p_streamPublisherID,p_groupName)) ; 
				
				if(streamDesc!=null){
					var mItem:MessageItem;
					streamDesc.mute=p_state;
					
					if ( _allowPrivateStreams ) {
						streamDesc.recipientIDs = p_recipientIDs ;
					}
					
					if ( p_groupName == null ) 
						mItem = new MessageItem(NODE_NAME_AUDIO_STREAM, streamDesc.createValueObject(),streamDesc.streamPublisherID );
					else 
						mItem = new MessageItem(NODE_NAME_AUDIO_STREAM + "_" + p_groupName, streamDesc.createValueObject(),streamDesc.streamPublisherID );
						
					if ( p_streamPublisherID != _userManager.myUserID && p_streamPublisherID != null ) {
						if (_collectionNode.canUserConfigure(_userManager.myUserID)) {
							mItem.associatedUserID = p_streamPublisherID;// if i am allowed then the message item's associated user id is the user id.	
						}else {
							throw new Error("StreamManager.createStream : Insufficient rights to publish for another user");
						}
					} 
					_collectionNode.publishItem(mItem,true);
				}
				else{
					throw new Error("StreamManager.muteStream : The stream to be muted or unmuted does not exist.");
				}
			}
			else {
				throw new Error("StreamManager.muteStream : The stream cannot be muted as it is not audio stream.");
			}
		}
		
		/**
		 * Pauses a video stream based on type, state (paused or non paused), and publisher ID. 
		 *
		 * @param p_type The stream type as specified by one of StreamManager's constants.
		 * @param p_state The stream's state; true for muted or false for unmuted.
		 * @param p_publisherID The <code>userID</code> of the stream's publisher.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function pauseStream(p_streamType:String, p_state:Boolean=false, p_streamPublisherID:String=null, p_groupName:String = null, p_recipientIDs:Array = null):void
		{
			// This function gets all the streams with a give publisher ID and then finds the stream to mute/unmute
			// TODO : nig : why not use the stream ID? Need to open this up so not only camera can be paused.
			var streamDesc:StreamDescriptor;
			
			if(p_streamType==CAMERA_STREAM || p_streamType==SCREENSHARE_STREAM){	//executes for audio stream only
				streamDesc = copyDescriptor(getStreamDescriptor(p_streamType,p_streamPublisherID,p_groupName)) ;
				
				if(streamDesc!=null){
					var mItem:MessageItem;
					streamDesc.pause = p_state;
					
					if ( _allowPrivateStreams ) {
						streamDesc.recipientIDs = p_recipientIDs ;
					}
					
					var nodeName:String 
					
					if ( p_groupName == null ) 
					 	nodeName = (p_streamType==CAMERA_STREAM) ? NODE_NAME_CAMERA_STREAM : NODE_NAME_SCREENSHARE_STREAM;
					else
						nodeName = (p_streamType==CAMERA_STREAM) ? NODE_NAME_CAMERA_STREAM + "_" + p_groupName : NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName;
						
					mItem = new MessageItem(nodeName, streamDesc.createValueObject(),streamDesc.streamPublisherID );
					
					if ( p_streamPublisherID != _userManager.myUserID && p_streamPublisherID != null ) {
						if (_collectionNode.canUserConfigure(_userManager.myUserID)) {
							mItem.associatedUserID = p_streamPublisherID;// if i am allowed then the message item's associated user id is the user id.	
						}else {
							throw new Error("StreamManager.createStream : Insufficient rights to publish for another user.");
						}
					} 
					_collectionNode.publishItem(mItem,true);
				}
				else{
					throw new Error("StreamManager.pauseStream : The stream to be paused or played does not exist.");
				}
			}
			else {
				throw new Error("StreamManager.pauseStream : The stream cannot be paused as it is not camera stream or screen share stream.");
			}
		}
		
		/**
		 * Changes the audio stream volume based on type, volume, and publisher ID.
		 * 
		 * @param p_type The stream type as specified by one of StreamManager's constants.
		 * @param p_volume The streams volume on a scale of 0-100.
		 * @param p_publisherID The <code>userID</code> of the stream's publisher.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function changeVolume(p_streamType:String,p_volume:Number=0,p_streamPublisherID:String=null, p_groupName:String = null,p_recipientIDs:Array = null):void
		{
			// This function gets all the streams with a give publisher ID and then finds the stream to mute/unmute
			var streamDesc:StreamDescriptor
			if(p_streamType==AUDIO_STREAM){	//executes for audio stream only
				streamDesc = copyDescriptor(getStreamDescriptor(p_streamType,p_streamPublisherID,p_groupName)) ;
				
				if(streamDesc!=null){
					streamDesc.volume=p_volume;
					
					if ( _allowPrivateStreams ) {
						streamDesc.recipientIDs = p_recipientIDs ;
					}
					
					if ( p_groupName == null ) 
						_collectionNode.publishItem(new MessageItem(NODE_NAME_AUDIO_STREAM, streamDesc.createValueObject(),streamDesc.streamPublisherID), true);
					else 
						_collectionNode.publishItem(new MessageItem(NODE_NAME_AUDIO_STREAM + "_" + p_groupName, streamDesc.createValueObject(),streamDesc.streamPublisherID ), true);
				}
				else{
					throw new Error("StreamManager.changeVolume : The stream whose volume is to be changed does not exist.");
				}
			}
			else {
				throw new Error("StreamManager.changeVolume : The stream's volume can not be changed as it is not camera stream.");
			}
		}
		/**
		 * Changes a video stream's width and height.
		 *  
		 * @param p_type The stream type as specified by one of StreamManager's constants.
		 * @param p_nativeWidth The stream's native width.
		 * @param p_nativeHeight The stream's native height.
		 * @param p_publisherID The <code>userID</code> of the stream's publisher.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function changeSizeStream(p_streamType:String,p_nativeWidth:Number=0,p_nativeHeight:Number=0,p_streamPublisherID:String=null , p_groupName:String = null, p_recipientIDs:Array = null):void
		{
			// This function gets all the streams with a give publisher ID and then finds the stream to change the size
			var streamDesc:StreamDescriptor;
			
			if(p_streamType == CAMERA_STREAM || p_streamType == SCREENSHARE_STREAM){
				streamDesc = copyDescriptor(getStreamDescriptor(p_streamType,p_streamPublisherID,p_groupName)) ;
				
				if(streamDesc!=null){
					
					if ( _allowPrivateStreams ) {
						streamDesc.recipientIDs	= p_recipientIDs ;
					}
					
					streamDesc.nativeWidth=p_nativeWidth;
					streamDesc.nativeHeight=p_nativeHeight;
					
					if ( p_streamType == CAMERA_STREAM ) {
						if ( p_groupName == null ) 
							_collectionNode.publishItem(new MessageItem(NODE_NAME_CAMERA_STREAM, streamDesc.createValueObject(),streamDesc.streamPublisherID ), true);
						else 
							_collectionNode.publishItem(new MessageItem(NODE_NAME_CAMERA_STREAM + "_" + p_groupName, streamDesc.createValueObject(),streamDesc.streamPublisherID ), true);
					}else {
						if ( p_groupName == null ) 
							_collectionNode.publishItem(new MessageItem(NODE_NAME_SCREENSHARE_STREAM, streamDesc.createValueObject(),streamDesc.streamPublisherID ), true);
						else 
							_collectionNode.publishItem(new MessageItem(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName, streamDesc.createValueObject(),streamDesc.streamPublisherID ), true);
					}
				}
				else{
					throw new Error("StreamManager.changeSizeStream : The stream to be changed in size does not exist.");
				}
			}
			else {
				throw new Error("StreamManager.changeSizeStream : The stream's size cannot be changed as it is not camera stream.");
			}
		}
		
		public function notifyCancelControl(p_streamPublisherID:String=null , p_groupName:String = null):Boolean
		{
			if(!_collectionNode.isNodeDefined(NODE_NAME_REMOTE_CONTROL_NOTIFICATION) ||
				!_collectionNode.canUserPublish(_userManager.myUserID, NODE_NAME_REMOTE_CONTROL_NOTIFICATION)) {
				return false;
			}
			var newStreamDesc:StreamDescriptor = new StreamDescriptor();
			if(p_groupName != null)
				newStreamDesc.groupName = p_groupName;
			newStreamDesc.type = REMOTE_CONTROL_CANCEL_NOTIFICATION;
			if(p_streamPublisherID != null) 
				newStreamDesc.originalScreenPublisher =  p_streamPublisherID;
				
			_collectionNode.publishItem(new MessageItem(NODE_NAME_REMOTE_CONTROL_NOTIFICATION, newStreamDesc.createValueObject(),newStreamDesc.streamPublisherID ), false);
			
			return true;
		}
		/**
		 * @private
		 */
		public function get aspectRatio():String
		{
			return _aspectRatio;
		}

		/**
		 * @private
		 */
		public function get aspectRatioValue():Number
		{
			switch (_aspectRatio) {
				case StreamManager.AR_STANDARD:
					return AR_STANDARD_W/AR_STANDARD_H;
					break;
				case StreamManager.AR_PORTRAIT:
					return AR_PORTRAIT_W/AR_PORTRAIT_H;
					break;
				case StreamManager.AR_LANDSCAPE:
					return AR_LANDSCAPE_W/AR_LANDSCAPE_H;
					break;
			}
			return 0;
		}
		
		/**
		 * @private
		 */
		public function set aspectRatio(p_aspectRatio:String):void
		{
			if (_aspectRatio == p_aspectRatio){
				return;
			}
			
			_collectionNode.publishItem(new MessageItem(NODE_NAME_ASPECT_RATIO, p_aspectRatio));
		}
		
		
		
		/**
		 * Queries a <code>streamDescriptor</code> based on its type and unique ID.
		 * 
		 * @param p_type The stream type as specified by one of StreamManager's constants.
		 * @param p_streamPublisherID The PublisherID of the stream to fetch.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function getStreamDescriptor(p_streamType:String,p_streamPublisherID:String,p_groupName:String = null):StreamDescriptor
		{
			// It gets the stream with given type and uniqueID
			if(_streamTypeDescriptors[p_streamType][p_streamPublisherID] != null ) {
				if ( p_groupName == null ) {
					if(_streamTypeDescriptors[p_streamType][p_streamPublisherID][DEFAULT]!=null){
						return _streamTypeDescriptors[p_streamType][p_streamPublisherID][DEFAULT] as StreamDescriptor; // return type is streamdescriptor, so we are downcasting
					}
				}else {
					if(_streamTypeDescriptors[p_streamType][p_streamPublisherID][p_groupName]!=null){
						return _streamTypeDescriptors[p_streamType][p_streamPublisherID][p_groupName] as StreamDescriptor; // return type is streamdescriptor, so we are downcasting
					}
				}
			}
			return null;
		}
		
		/**
		 * Queries all descriptors within a any group
		 * 
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function getStreamDescriptors(p_groupName:String = null ):Array
		{
			var streamDescriptors:Array = new Array();
			var type:String ;
			var publisher:String ;
			if ( p_groupName == null ) {
				for ( type in _streamTypeDescriptors ) {
					for ( publisher in _streamTypeDescriptors[type] ) {
						streamDescriptors.push(_streamTypeDescriptors[type][publisher][DEFAULT]);
					}
				}
			}else {
				for ( type in _streamTypeDescriptors ) {
					for ( publisher in _streamTypeDescriptors[type] ) {
						streamDescriptors.push(_streamTypeDescriptors[type][publisher][p_groupName]);
					}
				}
			}
			
			return streamDescriptors ;
		}
		
		
		/**
		 * Gets all <code>streamDescriptors</code> of a particular type. These are returned as an 
		 * Object table with the stream IDs as keys.
		 * 
		 * @param p_streamType The stream type which is one of the streamManager constants.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
		 */
		public function getStreamsOfType(p_streamType:String,p_groupName:String = null):Object
		{	
			if(p_streamType ==  AUDIO_STREAM || p_streamType == CAMERA_STREAM || p_streamType == SCREENSHARE_STREAM || p_streamType == REMOTE_CONTROL_STREAM) {
				var streams:Object = new Object();
				var id:String
				if ( p_groupName == null ) {
					for ( id in _streamTypeDescriptors[p_streamType] ) {
						if ( _streamTypeDescriptors[p_streamType][id][DEFAULT] != null ) 
							streams[id] = _streamTypeDescriptors[p_streamType][id][DEFAULT] ;
					}
				}else {
					for ( id in _streamTypeDescriptors[p_streamType] ) {
						if ( _streamTypeDescriptors[p_streamType][id][p_groupName] != null ) 
							streams[id] = _streamTypeDescriptors[p_streamType][id][p_groupName] ;
					}
				}
				
				return streams ;
			}
			else {
				throw new Error("StreamManager.getStreamDescriptor : The stream's type is undefined.");
			}
		}
		
		
		/**
		 * Returns all streams published by the user specified.  If a type is specified, only returns streams of that type.
		 * 
		 * @param p_streamPublisherID The userID of the desired user.
		 * @param p_streamType The stream type which is one of the streamManager constants.
		 * @param p_groupName The <code>groupName</code> of the stream's group.
 		 */
		public function getStreamsForPublisher(p_streamPublisherID:String, p_streamType:String=null,p_groupName:String = null):Array
		{
			var publisherStreams:Array=new Array(); //creates a new array
			var groupType:String ;
			
			if ( p_streamType != null ) {
				if ( _streamTypeDescriptors[p_streamType][p_streamPublisherID] != null ) {
					if ( p_groupName == null ) {
						for ( groupType in _streamTypeDescriptors[p_streamType][p_streamPublisherID] ) {
							publisherStreams.push(_streamTypeDescriptors[p_streamType][p_streamPublisherID][groupType]) ;
						}
					}else {
						publisherStreams.push(_streamTypeDescriptors[p_streamType][p_streamPublisherID][p_groupName]) ;
					}
				}
				
				return publisherStreams ;
			} else {
				var type:String ;
				if ( p_groupName == null ) {
					for(type in _streamTypeDescriptors){
						if ( _streamTypeDescriptors[type][p_streamPublisherID][DEFAULT] != null ) {
							for ( groupType in _streamTypeDescriptors[type][p_streamPublisherID]  ) {
								publisherStreams.push(_streamTypeDescriptors[type][p_streamPublisherID][groupType]) ;
							}
						}
					}
				}else {
					for(type in _streamTypeDescriptors){
						if ( _streamTypeDescriptors[type][p_streamPublisherID][p_groupName] != null ) {
							publisherStreams.push(_streamTypeDescriptors[type][p_streamPublisherID][p_groupName]);
						}
					}
				}
				
				return publisherStreams ;
			}
			
			return publisherStreams;	// return all such streams 
		}
		
		
		/**
		 * Creates a new group, and all the nodes associated with it
		 * 
		 * @param p_groupName The group Name.
 		 */
		public function createGroup(p_groupName:String):void
		{
			if (_collectionNode.isSynchronized) {
				if ( _collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM + "_" + p_groupName) 
		 			&& _collectionNode.isNodeDefined(NODE_NAME_CAMERA_STREAM + "_" + p_groupName) 
		 			&& _collectionNode.isNodeDefined(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName)
		 			&& _collectionNode.isNodeDefined(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName) ) {
		 			_groupNames.push(p_groupName);
		 			return ;
		 		}
				// if the collection node is synchronized, then  create the node configuration
				var nodeConf:NodeConfiguration = new NodeConfiguration();
				nodeConf.accessModel = UserRoles.VIEWER; // currently everyone can access to the model i.e. subscribe to this node configuration
				nodeConf.userDependentItems = true; // when the user leaves the room , the stored items should be removed from the server,default is false
				nodeConf.modifyAnyItem = false; // the user cannot modify other's items
				nodeConf.itemStorageScheme = NodeConfiguration.STORAGE_SCHEME_MANUAL;
				if (_collectionNode.canUserConfigure(_userManager.myUserID)) {
					if (!_collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM + "_" + p_groupName)) {
						// if audio stream node  is not defined then create the node with the above node configuration
						if ( _userRoleForPublish[AUDIO_STREAM][p_groupName] != null ) 
							nodeConf.publishModel = _userRoleForPublish[AUDIO_STREAM][p_groupName]; // only the users with permission level as publisher and above can publish the model
						else 
							nodeConf.publishModel = 50;
							
						_collectionNode.createNode(NODE_NAME_AUDIO_STREAM + "_" + p_groupName ,nodeConf); 
						_streamToNodeNameTable[AUDIO_STREAM][p_groupName] = NODE_NAME_AUDIO_STREAM + "_" + p_groupName ;
					}
					if (!_collectionNode.isNodeDefined(NODE_NAME_CAMERA_STREAM + "_" + p_groupName)){
						// if camera stream node  is not defined then create the node with the above node configuration
						if ( _userRoleForPublish[CAMERA_STREAM][p_groupName] != null ) 
							nodeConf.publishModel = _userRoleForPublish[CAMERA_STREAM][p_groupName];
						else 
							nodeConf.publishModel = 50;
							
						_collectionNode.createNode(NODE_NAME_CAMERA_STREAM + "_" + p_groupName,nodeConf); 
						_streamToNodeNameTable[CAMERA_STREAM][p_groupName] = NODE_NAME_AUDIO_STREAM + "_" + p_groupName ;
					}
					if (!_collectionNode.isNodeDefined(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName)){
						// if screen share stream node  is not defined then create the node with the node configuration below
						var nodeConfForSharing:NodeConfiguration = new NodeConfiguration();
						nodeConfForSharing.accessModel = UserRoles.VIEWER;
						
						if ( _userRoleForPublish[SCREENSHARE_STREAM][p_groupName] != null ) 
							nodeConfForSharing.publishModel = _userRoleForPublish[SCREENSHARE_STREAM][p_groupName];
						else 
							nodeConfForSharing.publishModel = 50;
						
						
						nodeConfForSharing.userDependentItems = true;
						nodeConfForSharing.modifyAnyItem = true; // participants can steal sharing!
						nodeConfForSharing.itemStorageScheme = NodeConfiguration.STORAGE_SCHEME_MANUAL;
						_collectionNode.createNode(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName,nodeConfForSharing); 
						_streamToNodeNameTable[SCREENSHARE_STREAM][p_groupName] = NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName ;
					}
					if (!_collectionNode.isNodeDefined(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName)){
						// if screen share stream node  is not defined then creathe node with the above node configuration
						if ( _userRoleForPublish[REMOTE_CONTROL_STREAM][p_groupName] != null ) 
							nodeConf.publishModel = _userRoleForPublish[REMOTE_CONTROL_STREAM][p_groupName];
						else 
							nodeConf.publishModel = 50;
							
						_collectionNode.createNode(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName,nodeConf);
						_streamToNodeNameTable[REMOTE_CONTROL_STREAM][p_groupName] = NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName ; 
					}
					_creatingGroup = true ;
					_tempGroupName = p_groupName ;					
				}
			} 
		}
		
		
		/**
		 * Removes a group if it doesn't exist, and the nodes associated with it
		 * 
		 * @param p_groupName The group Name.
 		 */
		public function removeGroup(p_groupName:String):void
		{
			if (_collectionNode.isSynchronized && isGroupDefined(p_groupName)) {
				
				if (_collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM + "_" + p_groupName))
					_collectionNode.removeNode(NODE_NAME_AUDIO_STREAM + "_" + p_groupName);
				
				if (_collectionNode.isNodeDefined(NODE_NAME_CAMERA_STREAM + "_" + p_groupName))
					_collectionNode.removeNode(NODE_NAME_CAMERA_STREAM + "_" + p_groupName);
				
				if (_collectionNode.isNodeDefined(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName))
					_collectionNode.removeNode(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName);
					
				if (_collectionNode.isNodeDefined(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName))
					_collectionNode.removeNode(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName);
				
				for (var i:int = 0 ; i < _groupNames.length ; i++ ) {
					if ( _groupNames[i] == p_groupName ) {
						_groupNames.splice(i,1);
						break;
					}
				}
			}
		}
		
		/**
		 * Returns true if the group is defined; otherwise, it returns false.
		 * 
		 * @param p_groupName The group Name.
		 *
		 * @return true if the group exists
 		 */
		public function isGroupDefined(p_groupName:String):Boolean
		{
			for ( var i:int = 0 ; i < _groupNames.length ; i++ ) {
				if ( _groupNames[i] == p_groupName ) {
					return true ;
				}
			}
			
			return false ;
		}
		
		
		/**
		 * Returns all the group names.
		 *
		 * @return An array of group names.
 		 */
		public function getGroupNames():Array
		{
			return _groupNames ;
		}
		
		/**
		 * @private
		 */
		protected function initializeModel():void
		{
			_aspectRatio = AR_STANDARD;
			_screenSharingSettings = new Object();
			_cameraSettings = new Object();
			_on2ParamsTable = new Object();
			// creates the stream type object and four different types of it , which in turn contains streams of that type
			_streamTypeDescriptors=new Object();
			_streamTypeDescriptors[AUDIO_STREAM]=new Object(); // creates the audio stream object which holds all audio streams in model
			_streamTypeDescriptors[CAMERA_STREAM]=new Object();// creates the audio stream object which holds all camera streams in model
			_streamTypeDescriptors[SCREENSHARE_STREAM]=new Object();// creates the audio stream object which holds all screenshare streams in model
			_streamTypeDescriptors[REMOTE_CONTROL_STREAM]=new Object();// creates the audio stream object which holds all screenshare streams in model

			_userRoleForPublish = new Object() ;
			_userRoleForPublish[AUDIO_STREAM]= new Object();
			_userRoleForPublish[CAMERA_STREAM]= new Object();
			_userRoleForPublish[SCREENSHARE_STREAM]= new Object();
			_userRoleForPublish[REMOTE_CONTROL_STREAM]= new Object();
			
			_userRoleForPublish[AUDIO_STREAM][DEFAULT]=50;
			_userRoleForPublish[CAMERA_STREAM][DEFAULT]=50;
			_userRoleForPublish[SCREENSHARE_STREAM][DEFAULT]=50;
			_userRoleForPublish[REMOTE_CONTROL_STREAM][DEFAULT]=50;
			
			_streamToNodeNameTable = new Object();
			_streamToNodeNameTable[AUDIO_STREAM]=new Object(); // creates the audio stream node name table to map to type to the node name for a group
			_streamToNodeNameTable[CAMERA_STREAM]=new Object();// creates the camera stream node name table to map to type to the node name for a group
			_streamToNodeNameTable[SCREENSHARE_STREAM]=new Object();// creates the screen share stream node name table to map to type to the node name for a group
			_streamToNodeNameTable[REMOTE_CONTROL_STREAM]=new Object();// creates the remote control stream node name table to map to type to the node name for a group

			_streamToNodeNameTable[AUDIO_STREAM][DEFAULT] = NODE_NAME_AUDIO_STREAM ;
			_streamToNodeNameTable[CAMERA_STREAM][DEFAULT] = NODE_NAME_CAMERA_STREAM ; 
			_streamToNodeNameTable[SCREENSHARE_STREAM][DEFAULT] = NODE_NAME_SCREENSHARE_STREAM ; 
			_streamToNodeNameTable[REMOTE_CONTROL_STREAM][DEFAULT] = NODE_NAME_REMOTE_CONTROL_STREAM ;
		}
		
		
		/**
		 * @private
		 */
		protected function initializeGroupModel(p_groupName:String):void
		{
			if ( p_groupName == null ) 
				return ;
			
			_userRoleForPublish[AUDIO_STREAM][p_groupName] = 50;
			_userRoleForPublish[CAMERA_STREAM][p_groupName] = 50;
			_userRoleForPublish[SCREENSHARE_STREAM][p_groupName] = 50;
			_userRoleForPublish[REMOTE_CONTROL_STREAM][p_groupName] = 50;
			
			
			_streamToNodeNameTable[AUDIO_STREAM][p_groupName] = NODE_NAME_AUDIO_STREAM + "_" + p_groupName;
			_streamToNodeNameTable[CAMERA_STREAM][p_groupName] = NODE_NAME_CAMERA_STREAM + "_" + p_groupName; 
			_streamToNodeNameTable[SCREENSHARE_STREAM][p_groupName] = NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName; 
			_streamToNodeNameTable[REMOTE_CONTROL_STREAM][p_groupName] = NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName;
		}
		
		/**
		 * @private
		 * Adds the given <code>streamDescriptor</code> to the Model.StreamDescriptor 
		 * Model Object which is indexed by the descriptor's ID.
		 * 
		 * @param p_streamDescriptor The StreamDescriptor for adding to the Model.
		 */
		protected function addStreamToModel(p_streamDescriptor:StreamDescriptor):void
		{	
			// checks if the stream Descripto is not null, then adds it the the model i.e. in streamTypeDescriptors
			if(p_streamDescriptor!=null){
				_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID] = new Object();
				if ( p_streamDescriptor.groupName == null ) {
					_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][DEFAULT] = p_streamDescriptor ;
				}else {
					_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][p_streamDescriptor.groupName] = p_streamDescriptor ;
				}
			}
			else{
				throw new Error("StreamManager.addStreamToModel : It is not possible to add a null stream to the model.");
			}
		}
		
		/**
		 * @private
		 * Removes the given <code>streamDescriptor</code> from the Model.StreamDescriptor Model 
		 * 
		 * @param p_streamDescriptor The StreamDescriptor for adding to Model.
		 */
		protected function removeStreamFromModel(p_streamDescriptor:StreamDescriptor):void
		{
			if ( p_streamDescriptor.groupName == null ) {
				if(_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][DEFAULT] != null)
					delete _streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][DEFAULT];
				else {
					throw new Error("StreamManager.removeStreamFromModel : Trying to delete a non existing stream from model.");
				}
			} else {
				if(_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][p_streamDescriptor.groupName] != null)
					delete _streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][p_streamDescriptor.groupName] ;
				else {
					throw new Error("StreamManager.removeStreamFromModel : Trying to delete a non existing stream from model.");
				}
			}
		}

		/**
		 * @private
		 * Modifies the stream descriptor in the model.
		 * 
		 * @param p_streamDescriptor The StreamDescriptor for modifying to Model.
		 */
		protected function modifyStreamInModel(p_streamDescriptor:StreamDescriptor):void
		{	
			//checks if the stream is not null and if so,then it modifies the stream in the model
			if(p_streamDescriptor!=null){
				if ( p_streamDescriptor.groupName == null ) {
					_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][DEFAULT] = p_streamDescriptor ;
				}else {
					_streamTypeDescriptors[p_streamDescriptor.type][p_streamDescriptor.streamPublisherID][p_streamDescriptor.groupName] = p_streamDescriptor ;
				}
			}
			else{
				throw new Error("StreamManager.addStreamToModel : Trying to modify a null stream in the model.");
			}
		}
		
		
		/**
		 * @private
		 * Event handler for the synchronization change on NodeCollection
		 */
		protected function onSynchronizationChange(event:CollectionNodeEvent):void
		{
			//synchronization change handler
			if (_collectionNode.isSynchronized) {
				// if the collection node is synchronized, then  create the node configuration
				var nodeConf:NodeConfiguration = new NodeConfiguration();
				nodeConf.accessModel = UserRoles.VIEWER; // currently everyone can access to the model i.e. subscribe to this node configuration
				nodeConf.userDependentItems = true; // when the user leaves the room , the stored items should be removed from the server,default is false
				nodeConf.modifyAnyItem = false; // the user cannot modify other's items
				nodeConf.itemStorageScheme = NodeConfiguration.STORAGE_SCHEME_MANUAL;
				if (_collectionNode.canUserConfigure(_userManager.myUserID)) {
					if (!_collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM)) {
						// if audio stream node  is not defined then create the node with the above node configuration
						nodeConf.publishModel = _userRoleForPublish[AUDIO_STREAM][DEFAULT]; // only the users with permission level as publisher and above can publish the model
						_collectionNode.createNode(NODE_NAME_AUDIO_STREAM,nodeConf); 
					}
					
					if (!_collectionNode.isNodeDefined(NODE_NAME_CAMERA_STREAM)){
						// if camera stream node  is not defined then create the node with the above node configuration
						nodeConf.publishModel = _userRoleForPublish[CAMERA_STREAM][DEFAULT];
						_collectionNode.createNode(NODE_NAME_CAMERA_STREAM,nodeConf); 
					}
					
					var nodeConfForSharing:NodeConfiguration = new NodeConfiguration();
					nodeConfForSharing.accessModel = UserRoles.VIEWER;	
					nodeConfForSharing.userDependentItems = true;
					nodeConfForSharing.modifyAnyItem = true; // participants can steal sharing!
					nodeConfForSharing.itemStorageScheme = NodeConfiguration.STORAGE_SCHEME_MANUAL;
					
					if (!_collectionNode.isNodeDefined(NODE_NAME_SCREENSHARE_STREAM)){
						// if screen share stream node  is not defined then create the node with the node configuration below
						nodeConfForSharing.publishModel = _userRoleForPublish[SCREENSHARE_STREAM][DEFAULT];
						_collectionNode.createNode(NODE_NAME_SCREENSHARE_STREAM,nodeConfForSharing); 
					}
					if (!_collectionNode.isNodeDefined(NODE_NAME_REMOTE_CONTROL_STREAM)){
						// if screen share stream node  is not defined then creathe node with the above node configuration
						nodeConf.publishModel = _userRoleForPublish[REMOTE_CONTROL_STREAM][DEFAULT];
						_collectionNode.createNode(NODE_NAME_REMOTE_CONTROL_STREAM,nodeConf); 
					}
					
					if (!_collectionNode.isNodeDefined(NODE_NAME_ASPECT_RATIO)) {
						//create the node by publishing the default value
						_collectionNode.publishItem(new MessageItem(NODE_NAME_ASPECT_RATIO, _aspectRatio));
					}	
										
				}
				
				if ( _collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM)) {
					_allowPrivateStreams = _collectionNode.getNodeConfiguration(NODE_NAME_AUDIO_STREAM).allowPrivateMessages ;
 				}
				
				//adding the various groups ....
				var nodeNames:Array = _collectionNode.nodeNames ;
				var groupName:Object = new Object();
				for ( var i:int = 0 ; i < nodeNames.length ; i++ ) {
					if ( (nodeNames[i] as String).search("_") != -1 ) {
						var subStr:String = (nodeNames[i] as String).substr((nodeNames[i] as String).search("_")+1);
						if ( groupName[subStr] == null ) {
							groupName[subStr] = true ;
							initializeGroupModel(subStr);
							createGroup(subStr);
						}
					}
				}
				
			} else {
				_collectionNode.removeEventListener(CollectionNodeEvent.SYNCHRONIZATION_CHANGE, onSynchronizationChange); 
				_collectionNode.removeEventListener(CollectionNodeEvent.ITEM_RECEIVE, onItemReceive);
				_collectionNode.removeEventListener(CollectionNodeEvent.ITEM_RETRACT, onItemRetract);
				_collectionNode.removeEventListener(CollectionNodeEvent.MY_ROLE_CHANGE,onMyRoleChange);
				_collectionNode.removeEventListener(CollectionNodeEvent.USER_ROLE_CHANGE,onUserRoleChange);
				_collectionNode.removeEventListener(CollectionNodeEvent.NODE_CREATE,onNodeCreate);
				_collectionNode.unsubscribe();
			}
			
			dispatchEvent(event); //bubble it up
		}
		
		/**
		 * @private
		 * handles the onuser role change event
		 */
		protected function onMyRoleChange(p_evt:CollectionNodeEvent):void
		{
			dispatchEvent(p_evt);	// bubble it up
		}
		
		
		/**
		 * @private
		 * Handles and Bubbles up the node creation event 
		 */
		 protected function onNodeCreate(p_evt:CollectionNodeEvent):void
		 {
		 	if ( _creatingGroup ) {
		 		if ( _collectionNode.isNodeDefined(NODE_NAME_AUDIO_STREAM + "_" + _tempGroupName) 
		 			&& _collectionNode.isNodeDefined(NODE_NAME_CAMERA_STREAM + "_" + _tempGroupName) 
		 			&& _collectionNode.isNodeDefined(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + _tempGroupName)
		 			&& _collectionNode.isNodeDefined(NODE_NAME_SCREENSHARE_STREAM + "_" + _tempGroupName) ) {
		 				_groupNames.push(_tempGroupName);
		 				_creatingGroup = false ;
		 				_tempGroupName = null ;		
		 			}
		 	} 
		 	dispatchEvent(p_evt);
		 }
		
		/**
		 * @private
		 * handles the onuser role change event
		 */
		protected function onUserRoleChange(p_evt:CollectionNodeEvent):void
		{
			dispatchEvent(p_evt);	// bubble it up
		}
		
		/**
		 * @private
		 * Event handler for ItemReceive event for NodeCollection
		 */
		protected function onItemReceive(p_event:CollectionNodeEvent):void
		{
			var theItem:MessageItem = p_event.item;
			var streamObject:Object;
			var streamDescriptor:StreamDescriptor;
			var event:StreamEvent;
			
			// checks if the node name is same as aspect ratio, then it sets the aspect ratio and dispatches an change event 
			if ( _connectSession && _connectSession.roomManager.roomState == RoomSettings.ROOM_STATE_ENDED ) {
				// if the room is ended , we dont want to add streams to it...
				return ;
			}
			
			if (p_event.nodeName == NODE_NAME_ASPECT_RATIO) {
				_aspectRatio = p_event.item.body;
				dispatchEvent(new StreamEvent(StreamEvent.ASPECT_RATIO_CHANGE));
				return;
			}
								
			if(p_event.nodeName == SCREEN_SHARING_SETTINGS) {			
				//This is moved to local share object	
				//_screenSharingSettings[p_event.item.itemID] =  p_event.item.body;			
				
				return;
			}
			
			if(p_event.nodeName == NODE_NAME_REMOTE_CONTROL_NOTIFICATION) {
				streamDescriptor=buildStreamDescriptor(p_event.item);
				
				if(streamDescriptor.type == REMOTE_CONTROL_CANCEL_NOTIFICATION) {
					var e:ScreenShareEvent = new ScreenShareEvent(ScreenShareEvent.CONTROL_REQUEST_CANCELED);
					e.streamDescriptor = streamDescriptor;
					dispatchEvent(e);
				} 
				return;
			}
			
			if(p_event.nodeName == CAMERA_SETTINGS) {
				//by default the accessModel, everyone gets camera setting.
				_cameraSettings[p_event.item.itemID] = p_event.item.body;
				
				var o:On2ParametersDescriptor;
				
				switch (p_event.item.itemID) {
									
					case "slowImages":										
						_on2ParamsTable[CameraModel.SLOW_IMAGES] = new On2ParametersDescriptor();
						o = (_on2ParamsTable[CameraModel.SLOW_IMAGES] as On2ParametersDescriptor);
						o.quality=Number(_cameraSettings.slowImages.quality);
						o.performance=Number(_cameraSettings.slowImages.performance);
						o.keyframeInterval=Number(_cameraSettings.slowImages.kf);
						o.fps=Number(_cameraSettings.slowImages.fps);
						o.captureWidthHeightFactor=Number(_cameraSettings.slowImages.factor);					
						break;
				
					case "fastImages":
						_on2ParamsTable[CameraModel.FAST_IMAGES] = new On2ParametersDescriptor();
						o = (_on2ParamsTable[CameraModel.FAST_IMAGES] as On2ParametersDescriptor);			
						o.quality=Number(_cameraSettings.fastImages.quality);
						o.performance=Number(_cameraSettings.fastImages.performance);
						o.keyframeInterval=Number(_cameraSettings.fastImages.kf);
						o.fps=Number(_cameraSettings.fastImages.fps);
						o.captureWidthHeightFactor=Number(_cameraSettings.fastImages.factor);
						break;
					
					case "highqImages":
						_on2ParamsTable[CameraModel.HIGH_QUALITY] = new On2ParametersDescriptor();
						o = (_on2ParamsTable[CameraModel.HIGH_QUALITY] as On2ParametersDescriptor);
						o.quality=Number(_cameraSettings.highqImages.quality);
						o.performance=Number(_cameraSettings.highqImages.performance);
						o.keyframeInterval=Number(_cameraSettings.highqImages.kf);
						o.fps=Number(_cameraSettings.highqImages.fps);
						o.captureWidthHeightFactor=Number(_cameraSettings.highqImages.factor);
						break;
					
					case "highbwImages":
						_on2ParamsTable[CameraModel.HIGH_BW] = new On2ParametersDescriptor();
						o = (_on2ParamsTable[CameraModel.HIGH_BW] as On2ParametersDescriptor);
						o.quality=Number(_cameraSettings.highbwImages.quality);
						o.performance=Number(_cameraSettings.highbwImages.performance);
						o.keyframeInterval=Number(_cameraSettings.highbwImages.kf);
						o.fps=Number(_cameraSettings.highbwImages.fps);
						o.captureWidthHeightFactor=Number(_cameraSettings.highbwImages.factor);
						break;
						
					default:
						break;
				}
		
				return;
			}
			
			streamDescriptor=buildStreamDescriptor(p_event.item);	
			var oldStreamDescriptor:StreamDescriptor=getStreamDescriptor(streamDescriptor.type,streamDescriptor.streamPublisherID,streamDescriptor.groupName);
			if (oldStreamDescriptor==null){
				// it's a brand new stream
				if (_streamTypeDescriptors[streamDescriptor.type]==null) {
					// not a stream we know, die!
					return;
				}

				if (theItem.associatedUserID==_userManager.myUserID && streamDescriptor.type==StreamManager.AUDIO_STREAM) {
					// it's my audio, publish it to my userDescriptor
					_userManager.setCustomUserField(_userManager.myUserID, StreamManager.AUDIO_STREAM, true);
				}else if (theItem.associatedUserID==_userManager.myUserID && streamDescriptor.type==StreamManager.CAMERA_STREAM) {
					// it's my audio, publish it to my userDescriptor
					_userManager.setCustomUserField(_userManager.myUserID, StreamManager.CAMERA_STREAM, true);
				}else if (theItem.associatedUserID==_userManager.myUserID && streamDescriptor.type==StreamManager.SCREENSHARE_STREAM) {
					// it's my audio, publish it to my userDescriptor
					_userManager.setCustomUserField(_userManager.myUserID, StreamManager.SCREENSHARE_STREAM, true);
				}
				// now addd this new item to the model and then dispatch stream received event with its descriptor being the received message item's descriptor
				addStreamToModel(streamDescriptor);
				event=new StreamEvent(StreamEvent.STREAM_RECEIVE);
				event.streamDescriptor=streamDescriptor;
				dispatchEvent(event);
			}
			else{
				// it's an existing stream, what changed?
				if (oldStreamDescriptor.mute!=streamDescriptor.mute){
					// if value of mute has changed in the stream , then modify the stream in the model
					modifyStreamInModel(streamDescriptor);
					// add streamdescriptor to the event and dispatch streamEvent 
					event=new StreamEvent(StreamEvent.STREAM_PAUSE);
					event.streamDescriptor=streamDescriptor;
					dispatchEvent(event);
					if (theItem.associatedUserID==_userManager.myUserID) {
						// it's my audio, add or remove it from my userDescriptor
						_userManager.setCustomUserField(_userManager.myUserID, StreamManager.AUDIO_STREAM, !streamDescriptor.mute);
					}
				}
				if (oldStreamDescriptor.pause!=streamDescriptor.pause){
					// if value of mute has changed in the stream , then modify the stream in the model
					modifyStreamInModel(streamDescriptor);
					if (theItem.associatedUserID==_userManager.myUserID) {
						// it's my audio, add or remove it from my userDescriptor
						_userManager.setCustomUserField(_userManager.myUserID, StreamManager.CAMERA_STREAM, !streamDescriptor.pause);
					}
					// add streamdescriptor to the event and dispatch streamEvent 
					event=new StreamEvent(StreamEvent.STREAM_PAUSE);
					event.streamDescriptor=streamDescriptor;
					dispatchEvent(event);
				}
				if (oldStreamDescriptor.nativeWidth!=streamDescriptor.nativeWidth || oldStreamDescriptor.nativeHeight!=streamDescriptor.nativeHeight){
					// if value of native Height or native Width has changed , then modify the stream in the model with the updated value
					modifyStreamInModel(streamDescriptor);
					// add streamdescriptor to the event and dispatch streamEvent 
					event=new StreamEvent(StreamEvent.DIMENSIONS_CHANGE);
					event.streamDescriptor=streamDescriptor;
					dispatchEvent(event);
				}	
				if (oldStreamDescriptor.volume!=streamDescriptor.volume){
					// if value of mute has changed in the stream , then modify the stream in the model
					modifyStreamInModel(streamDescriptor);
					// add streamdescriptor to the event and dispatch streamEvent 
					event=new StreamEvent(StreamEvent.VOLUME_CHANGE);
					event.streamDescriptor=streamDescriptor;
					dispatchEvent(event);
				}
				if (oldStreamDescriptor.kBps!=streamDescriptor.kBps){
					// if value of kbps has changed , then modify the stream in the model
					modifyStreamInModel(streamDescriptor);
					// add streamdescriptor to the event and dispatch streamEvent 
					event=new StreamEvent(StreamEvent.BANDWIDTH_CHANGE);
					event.streamDescriptor=streamDescriptor;
					dispatchEvent(event);
				}
				if (oldStreamDescriptor.finishPublishing != streamDescriptor.finishPublishing ){
					// if value of finishedPublishing (i.e. whether the stream has finished publishing) has changed in the stream , then modify the stream in the model
//					streamDescriptor.finishPublishing=true;
					modifyStreamInModel(streamDescriptor);
					// add streamdescriptor to the event and dispatch streamEvent 
					event=new StreamEvent(StreamEvent.STREAM_RECEIVE);
					event.streamDescriptor=streamDescriptor;
					dispatchEvent(event);
				}
			}
		}
		/**
		 * @private
		 * Event handler for ItemRetract event for NodeCollection
		 */
		protected function onItemRetract(p_event:CollectionNodeEvent):void
		{
			var sD:StreamDescriptor = buildStreamDescriptor(p_event.item);
			var event:StreamEvent=new StreamEvent(StreamEvent.STREAM_DELETE);
			if (p_event.item.associatedUserID==_userManager.myUserID && sD.type==StreamManager.AUDIO_STREAM) {
				// it's my audio, remove it from my userDescriptor
				_userManager.setCustomUserField(_userManager.myUserID, StreamManager.AUDIO_STREAM, false);
			} else if (p_event.item.associatedUserID==_userManager.myUserID && sD.type==StreamManager.CAMERA_STREAM) {
				// it's my audio, remove it from my userDescriptor
				_userManager.setCustomUserField(_userManager.myUserID, StreamManager.CAMERA_STREAM, false);
			} else if (p_event.item.associatedUserID==_userManager.myUserID && sD.type==StreamManager.SCREENSHARE_STREAM) {
				// it's my audio, remove it from my userDescriptor
				_userManager.setCustomUserField(_userManager.myUserID, StreamManager.SCREENSHARE_STREAM, false);
			}
			else if (p_event.item.associatedUserID==_userManager.myUserID && sD.type==StreamManager.REMOTE_CONTROL_STREAM) {
				// it's my audio, remove it from my userDescriptor
				_userManager.setCustomUserField(_userManager.myUserID, StreamManager.REMOTE_CONTROL_STREAM, false);
			}
			event.streamDescriptor = sD;
			removeStreamFromModel(sD);
			dispatchEvent(event);
		}
		
		/**
		 * @private
		 * helper function - builds a streamDescriptor from a MessageItem. (Useful for stuffing associatedUserID into 
		 * the streamPublisherID field of the descriptor).
		 * @param p_item
		 * @return 
		 */
		protected function buildStreamDescriptor(p_item:MessageItem):StreamDescriptor
		{
			// builds a stream descriptor from the received message item value Object and other message item attributes
			// and returns it
			var sD:StreamDescriptor = new StreamDescriptor();
			sD.readValueObject(p_item.body);
			sD.streamPublisherID = p_item.associatedUserID;
			sD.initiatorID = p_item.publisherID;
			return sD;
		}
		
		/**
		 * @private
		 * Copies a streamDescriptor into another
		 * @param p_streamDescriptor
		 * @return 
		 * 
		 */		
		protected function copyDescriptor(p_streamDescriptor:StreamDescriptor):StreamDescriptor
		{
			if(p_streamDescriptor == null ){
				return null;
			}
			// copies the p_streamDescriptor into a new stream descriptor and returns it 
			var streamDesc:StreamDescriptor=new StreamDescriptor();
			streamDesc.id=p_streamDescriptor.id;
			streamDesc.streamPublisherID=p_streamDescriptor.streamPublisherID;
			streamDesc.nativeWidth=p_streamDescriptor.nativeWidth;
			streamDesc.nativeHeight=p_streamDescriptor.nativeHeight;
			streamDesc.volume=p_streamDescriptor.volume;
			streamDesc.type=p_streamDescriptor.type;
			streamDesc.mute=p_streamDescriptor.mute;
			streamDesc.pause=p_streamDescriptor.pause;
			streamDesc.finishPublishing=p_streamDescriptor.finishPublishing;
			streamDesc.groupName = p_streamDescriptor.groupName ;
			streamDesc.recipientIDs = p_streamDescriptor.recipientIDs ;
			return streamDesc;
		}
		
		/**
		 * @private
		 */
		protected function onUserManagerSync(p_evt:UserEvent):void
		{
			if (_userManager.isSynchronized) {
				// Create userManager custom fields for all the stream types we support
				if (!_userManager.isCustomFieldDefined(StreamManager.AUDIO_STREAM) && _userManager.canUserConfigure(_userManager.myUserID)) {
					_userManager.registerCustomUserField(StreamManager.AUDIO_STREAM);
				}
				
				if (!_userManager.isCustomFieldDefined(StreamManager.CAMERA_STREAM) && _userManager.canUserConfigure(_userManager.myUserID)) {
					_userManager.registerCustomUserField(StreamManager.CAMERA_STREAM);
				}
				
				if (!_userManager.isCustomFieldDefined(StreamManager.SCREENSHARE_STREAM) && _userManager.canUserConfigure(_userManager.myUserID)) {
					_userManager.registerCustomUserField(StreamManager.SCREENSHARE_STREAM);
				}
				
				if (!_userManager.isCustomFieldDefined(REMOTE_CONTROL_STREAM) && _userManager.canUserConfigure(_userManager.myUserID)) {
					_userManager.registerCustomUserField(REMOTE_CONTROL_STREAM);
				}

			}
		}
		
		/**
		 * @private
		 */
		protected function publishStreamItem(p_streamDescriptor:StreamDescriptor , p_groupName:String =null):void
		{
			var mItem:MessageItem;
			
			if ( p_streamDescriptor.groupName == null ) {
				if(p_streamDescriptor.type == AUDIO_STREAM) {
					mItem = new MessageItem(NODE_NAME_AUDIO_STREAM, p_streamDescriptor.createValueObject(),p_streamDescriptor.streamPublisherID);
				} else if(p_streamDescriptor.type == CAMERA_STREAM) {
					mItem = new MessageItem(NODE_NAME_CAMERA_STREAM, p_streamDescriptor.createValueObject(), p_streamDescriptor.streamPublisherID);
				} else if(p_streamDescriptor.type == SCREENSHARE_STREAM) {
					mItem = new MessageItem(NODE_NAME_SCREENSHARE_STREAM, p_streamDescriptor.createValueObject(), p_streamDescriptor.streamPublisherID);
				} else if(p_streamDescriptor.type == REMOTE_CONTROL_STREAM) {
					mItem = new MessageItem(NODE_NAME_REMOTE_CONTROL_STREAM, p_streamDescriptor.createValueObject(), p_streamDescriptor.streamPublisherID);
				} else {
					throw new Error("Stream type cannot be found. The stream cannot be created");
					return;
				}	
			}else {
				if(p_streamDescriptor.type == AUDIO_STREAM) {
					mItem = new MessageItem(NODE_NAME_AUDIO_STREAM + "_" + p_groupName, p_streamDescriptor.createValueObject(),p_streamDescriptor.streamPublisherID);
				} else if(p_streamDescriptor.type == CAMERA_STREAM) {
					mItem = new MessageItem(NODE_NAME_CAMERA_STREAM + "_" + p_groupName, p_streamDescriptor.createValueObject(),p_streamDescriptor.streamPublisherID);
				} else if(p_streamDescriptor.type == SCREENSHARE_STREAM) {
					mItem = new MessageItem(NODE_NAME_SCREENSHARE_STREAM + "_" + p_groupName, p_streamDescriptor.createValueObject(),p_streamDescriptor.streamPublisherID);
				} else if(p_streamDescriptor.type == REMOTE_CONTROL_STREAM) {
					mItem = new MessageItem(NODE_NAME_REMOTE_CONTROL_STREAM + "_" + p_groupName, p_streamDescriptor.createValueObject(),p_streamDescriptor.streamPublisherID);
				} else {
					throw new Error("The stream type can not be found. The stream can not be created.");
					return;
				}	
			}
			
			
			if (p_streamDescriptor.streamPublisherID!=_userManager.myUserID && p_streamDescriptor.streamPublisherID != null ) {
				// I'm asking someone else to publish, am I allowed?
				if (_collectionNode.canUserConfigure(_userManager.myUserID)) {
					mItem.associatedUserID = p_streamDescriptor.streamPublisherID;// if i am allowed then the message item's associated user id is the user id.
				} else {
					throw new Error("StreamManager.createStream : Insufficient rights to publish for another user.");
				}
			}
			
			if ( p_streamDescriptor.recipientIDs != null ) {
				mItem.recipientIDs = p_streamDescriptor.recipientIDs ;
			}

			_collectionNode.publishItem(mItem);
			
		}
		
		
		/**
		 * @private
		 * Internal function for generating the unique Ids
		 */
		private function createUID():String
	    {
	        var uid:Array = new Array(36);
	        var index:int = 0;
	        
	        var i:int;
	        var j:int;
	        
	        for (i = 0; i < 8; i++)
	        {
	            uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
	        }
	
	        for (i = 0; i < 3; i++)
	        {
	            uid[index++] = 45; // charCode for "-"
	            
	            for (j = 0; j < 4; j++)
	            {
	                uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
	            }
	        }
	        
	        uid[index++] = 45; // charCode for "-"
	
	        var time:Number = new Date().getTime();
	        // Note: time is the number of milliseconds since 1970,
	        // which is currently more than one trillion.
	        // We use the low 8 hex digits of this number in the UID.
	        // Just in case the system clock has been reset to
	        // Jan 1-4, 1970 (in which case this number could have only
	        // 1-7 hex digits), we pad on the left with 7 zeros
	        // before taking the low digits.
	        var timeString:String = ("0000000" + time.toString(16).toUpperCase()).substr(-8);
	        
	        for (i = 0; i < 8; i++)
	        {
	            uid[index++] = timeString.charCodeAt(i);
	        }
	        
	        for (i = 0; i < 4; i++)
	        {
	            uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
	        }
	        
	        return String.fromCharCode.apply(null, uid);
	    }
		
		
	}
}
