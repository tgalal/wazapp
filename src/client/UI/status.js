//.pragma library

function changeStatus(status)
{
	var uri = "https://s.whatsapp.net/client/iphone/u.php?s="+status+"&me=5491133302246&cc=31";
	RequestStatus(uri);

}

function RequestStatus(uri)
{
    var xhr = new XMLHttpRequest();
	xhr.open("GET",uri,true);
	xhr.setRequestHeader("User-Agent","WhatsApp/2.6.7 iPhone_OS/5.0.1 Device/Unknown_(iPhone4,1)");
	xhr.setRequestHeader("Accept", "*/*");
	xhr.setRequestHeader("Accept-Language", "en-us");
	xhr.setRequestHeader("Accept-Encoding", "gzip, deflate");
	xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE)
        {
            if ( xhr.status == 200)
            {
                var jsonObject = eval('(' + xhr.responseText + ')');
                //loaded(jsonObject)
            }
        }
    }
    xhr.send();
}
