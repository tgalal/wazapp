'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 2 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''

import os
from Models.mediatype import Mediatype

class WAConstants():
	
	STORE_PATH = os.path.expanduser('~/.wazapp');
	
	MEDIA_PATH = STORE_PATH+'/media'
	AUDIO_PATH = MEDIA_PATH+'/audio'
	IMAGE_PATH = MEDIA_PATH+'/images'
	VIDEO_PATH = MEDIA_PATH+'/videos'
	VCARD_PATH = MEDIA_PATH+'contacts'
		
	CLIENT_INSTALL_PATH = '/opt/waxmppplugin/bin/wazapp'
	
	DEFAULT_CONTACT_PICTURE = CLIENT_INSTALL_PATH+'/'+'UI/pics/user.png';
	DEFAULT_GROUP_PICTURE = CLIENT_INSTALL_PATH+'/'+'UI/pics/user.png';
	
	DEFAULT_SOUND_NOTIFICATION = "/usr/share/sounds/ring-tones/Message 1.mp3"
	FOCUSED_SOUND_NOTIFICATION = "/usr/share/sounds/ui-tones/snd_default_beep.wav"
	DEFAULT_BEEP_NOTIFICATION = "/usr/share/sounds/ui-tones/snd_default_beep.wav"
	NO_SOUND = "/usr/share/sounds/ring-tones/No sound.wav"
	
	MEDIA_TYPE_TEXT		= Mediatype.TYPE_TEXT
	MEDIA_TYPE_IMAGE	= Mediatype.TYPE_IMAGE
	MEDIA_TYPE_AUDIO	= Mediatype.TYPE_AUDIO
	MEDIA_TYPE_VIDEO	= Mediatype.TYPE_VIDEO
	MEDIA_TYPE_LOCATION	= Mediatype.TYPE_LOCATION
	MEDIA_TYPE_VCARD	= Mediatype.TYPE_VCARD
