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
package com.adobe.rtc.authentication
{
	import com.adobe.rtc.core.session_internal;
	import com.adobe.rtc.session.managers.SessionManagerPlayback;
	
	/**
	 * This class assigns the authentication token, just to allow access to acron APIs.
	 * This class extends AbstractAuthenticator.
	 * @see com.adobe.rtc.authentication.AdobeAuthenticator
	 */

	public class PlaybackAuthenticator extends AbstractAuthenticator
	{
		public function PlaybackAuthenticator()
		{
			session_internal::sessionManager = new SessionManagerPlayback();
			super();
			
			// guest token, just to allow access to Acorn APIs
			authenticationKey = "glt=g:playback";		
		}
	}
		
}
