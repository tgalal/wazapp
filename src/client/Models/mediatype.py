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

from model import Model;
import os

parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0,parentdir)
from constants import WAConstants

class Mediatype(Model):

	TYPE_TEXT	= WAConstants.MEDIA_TYPE_TEXT
	TYPE_IMAGE	= WAConstants.MEDIA_TYPE_IMAGE
	TYPE_AUDIO	= WAConstants.MEDIA_TYPE_AUDIO
	TYPE_VIDEO	= WAConstants.MEDIA_TYPE_VIDEO
	TYPE_LOCATION	= WAConstants.MEDIA_TYPE_LOCATION
	TYPE_VCARD	= WAConstants.MEDIA_TYPE_VCARD
	
	
	
	
