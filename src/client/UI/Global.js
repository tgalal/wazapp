/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
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


function getCode(inputText) {
	var replacedText;
    var regx = /<img src="\/opt\/waxmppplugin\/bin\/wazapp\/UI\/pics\/emoji-20\/emoji-(\w{4}).png" \/>/g
    replacedText = inputText.replace( regx, function(s, eChar){
		var n=String.fromCharCode('0x'+eChar);
        return n;
    });
    regx = /<img src="pics\/emoji-20\/emoji-(\w{4}).png" \/>/g
    replacedText = replacedText.replace( regx, function(s, eChar){
		var n=String.fromCharCode('0x'+eChar);
        return n;
    });
    return replacedText
}

/* emojify by @knobtviker */
function emojify(inputText) {
    var replacedText;
        var regx = /([\ue001-\ue537])/g
        replacedText = inputText.replace(regx, function(s, eChar){
            return '<img src="pics/emoji-20/emoji-' + eChar.charCodeAt(0).toString(16).toUpperCase() + '.png" />';
        });
    return replacedText
}

function emojify2(inputText) { //for textArea
    var replacedText;
        var regx = /([\ue001-\ue537])/g
        replacedText = inputText.replace(regx, function(s, eChar){
            return "<img src='/opt/waxmppplugin/bin/wazapp/UI/pics/emoji-20/emoji-"+eChar.charCodeAt(0).toString(16).toUpperCase() + ".png'>";
        });
    return replacedText
}

function emojifyBig(inputText) {
    var replacedText;
        var regx = /([\ue001-\ue537])/g
        replacedText = inputText.replace(regx, function(s, eChar){
            return '<img src="pics/emoji-32/emoji-' + eChar.charCodeAt(0).toString(16).toUpperCase() + '.png" />';
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


var emoji_code = [
                        '415','056','057','414','405','106','418','417','40D','40A','404','105','409','40E','402','108','403','058','407','401','40F',
                        '40B','406','413','411','412','410','107','059','416','408','40C','11A','10C','32C','32A','32D','328','32B','022','023','327',
                        '329','32E','335','334','337','336','13C','330','331','326','03E','11D','05A','00E','421','420','00D','010','011','41E','012',
                        '422','22E','22F','231','230','427','41D','00F','41F','14C','201','115','428','51F','429','424','423','253','426','111','425',
                        '31E','31F','31D','001','002','005','004','51A','519','518','515','516','517','51B','152','04E','51C','51E','11C','536','003',
                        '41C','41B','419','41A',
                        '04A','04B','049','048','04C','13D','443','43E','04F','052','053','524','52C','52A','531','050','527','051','10B','52B','52F',
                        '109','528','01A','134','530','529','526','52D','521','523','52E','055','525','10A','522','019','054','520','306','030','304',
                        '110','032','305','303','118','447','119','307','308','444','441',
                        '436','437','438','43A','439','43B','117','440','442','446','445','11B','448','033','112','325','312','310','126','127','008',
                        '03D','00C','12A','00A','00B','009','316','129','141','142','317','128','14B','211','114','145','144','03F','313','116','10F',
                        '104','103','101','102','13F','140','11F','12F','031','30E','311','113','30F','13B','42B','42A','018','016','015','014','42C',
                        '42D','017','013','20E','20C','20F','20D','131','12B','130','12D','324','301','148','502','03C','30A','042','040','041','12C',
                        '007','31A','13E','31B','006','302','319','321','322','314','503','10E','318','43C','11E','323','31C','034','035','045','338',
                        '047','30C','044','30B','043','120','33B','33F','341','34C','344','342','33D','33E','340','34D','339','147','343','33C','33A',
                        '43F','34B','046','345','346','348','347','34A','349',
                        '036','157','038','153','155','14D','156','501','158','43D','037','504','44A','146','154','505','506','122','508','509','03B',
                        '04D','449','44B','51D','44C','124','121','433','202','135','01C','01D','10D','136','42E','01B','15A','159','432','430','431',
                        '42F','01E','039','435','01F','125','03A','14E','252','137','209','133','150','320','123','132','143','50B','514','513','50C',
                        '50D','511','50F','512','510','50E',
                        '50A',
                        '21C','21D','21E','21F','220','221','222','223','224','225','210','232','233','235','234','236','237','238','239','23B','23A',
                        '23D','23C','24D','212','24C','213','214','507','203','20B','22A','22B','226','227','22C','22D','215','216','217','218','228',
                        '151','138','139','13A','208','14F','20A','434','309','315','30D','207','229','206','205','204','12E','250','251','14A','149',
                        '23F','240','241','242','243','244','245','246','247','248','249','24A','24B','23E','532','533','534','535','21A','219','21B',
                        '02F','024','025','026','027','028','029','02A','02B','02C','02D','02E','332','333','537'];



function newlinefy(inputText) {
    var replacedText, replacePattern1;

        replacePattern1 = /\n/g;
        replacedText = inputText.replace(replacePattern1, '<br/>');

        return replacedText
}


function convertUtf16CodesToString(utf16_codes) {
  var unescaped = '';
  for (var i = 0; i < utf16_codes.length; ++i) {
    unescaped += String.fromCharCode(utf16_codes[i]);
  }
  return unescaped;
}

function convertUnicodeCodePointsToUtf16Codes(unicode_codes) {
  var utf16_codes = [];
  for (var i = 0; i < unicode_codes.length; ++i) {
    var unicode_code = unicode_codes[i];
    if (unicode_code < (1 << 16)) {
      utf16_codes.push(unicode_code);
    } else {
      var first = ((unicode_code - (1 << 16)) / (1 << 10)) + 0xD800;
      var second = (unicode_code % (1 << 10)) + 0xDC00;
      utf16_codes.push(first)
      utf16_codes.push(second)
    }
  }
  return utf16_codes;
}

function convertUnicodeCodePointsToString(unicode_codes) {
  var utf16_codes = convertUnicodeCodePointsToUtf16Codes(unicode_codes);
  return convertUtf16CodesToString(utf16_codes);
}
