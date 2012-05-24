/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
.pragma library

/* emojify by @knobtviker */
function emojify(inputText) {
    var replacedText;
        var regx = /([\ue001-\ue537])/g
        replacedText = inputText.replace(regx, function(s, eChar){
            return '<img src="pics/emoji/emoji-' + eChar.charCodeAt(0).toString(16).toUpperCase() + '.png" />';
        });
    return replacedText
}

function emojify2(inputText) { //for textArea
    var replacedText;
        var regx = /([\ue001-\ue537])/g
        replacedText = inputText.replace(regx, function(s, eChar){
            return "<img src='/opt/waxmppplugin/bin/wazapp/UI/pics/emoji/emoji-"+eChar.charCodeAt(0).toString(16).toUpperCase() + ".png'>";
        });
    return replacedText
}

function emojifyBig(inputText) {
    var replacedText;
        var regx = /([\ue001-\ue537])/g
        replacedText = inputText.replace(regx, function(s, eChar){
            return '<img src="pics/emoji-big/' + eChar.charCodeAt(0).toString(16).toLowerCase() + '.png" />';
        });
    return replacedText
}



/* linkify by @knobtviker */
function linkify(inputText) {
            var replacedText, replacePattern1, replacePattern2, replacePattern3;

            //URLs starting with http://, https://, or ftp://
            replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
            replacedText = inputText.replace(replacePattern1, '<a href="$1" target="_blank">$1</a>');

            //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
            replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
            replacedText = replacedText.replace(replacePattern2, '$1<a href="http://$2" target="_blank">$2</a>');

            //Change email addresses to mailto:: links.
            replacePattern3 = /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/gim;
            replacedText = replacedText.replace(replacePattern3, '<a href="mailto:$1">$1</a>');

            return replacedText
    }
