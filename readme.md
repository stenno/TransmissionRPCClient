#TransmissionRPCClient

TransmissionRPCClient (hereafter TRPCC) is a Client written in Ruby for comfortably controlling the Transmission Remote Interface via RPC.
The TRPCC comes with a small set of methods, which will be explained in this document.


##Initialization
Before you can use the TRPCC, you need to *require* the file.
>	`require 'trpcc'`

You can initialize TRPCC with:

>	`TransmissionRPCClient.new`

The constructor takes two arguments *host* and *port*, which are **localhost** and **9091** by default.

##Doing stuff

*	Getting a list of all the torrents:
>		list_torrents

	This method returns an array, with the entries being hashes with the keys *id*, *name*, and *percentDone*.
*	Getting information about a specific torrent:
>		get_info(id)

	This returns a hash with the keys *id*, *name*,  *percentDone*, and *files*. 
	*files* itself is an array, with the entries being hashes with the keys *key*, *bytesCompleted*, *length* and *name*.
*	Starting a torrent which is paused:
>		start_torrent(id)

*	Adding a torrent with a local *.torrent*-file:
>		add_torrent(id)

*	Adding a torrent via an IO object:
>		add_metainfo(io_object)

	This requires an IO Object which responds to the *read* method. base64 encoding is done by the client

##Going a little bit deeper
	
If you want to manipulate the arguments without hacking the source code, you might want to use *do_action*
>		do_action(userHash)

with *userHash* being a hash with the keys *method* and *arguments*, of which *method* being one of
>		add		start	stop	set		get		delete

and *arguments* being itself a hash with the corresponding arguments for the RPC method.

If you want to refresh your *X-Transmission-Session-id*, call
>		get_sid

This method is also called during initialization.

##Examples

This will simply display all the torrents

>		require 'trpcc'
>		client = TransmissionRPCClient.new
>		puts client.list_torrents

This example adds a torrent from a file via an IO object

>		require 'trpcc'
>		client = TransmissionRPCClient.new
>		myTorrent = File.open("example.torrent")
>		client.add_metainfo myTorrent

This will set the peer limit for the torrent with the id *0* to 23

>		require 'trpcc'
>		client = TransmissionRPCClient.new
>		client.do_action {"method" => "set", "arguments" => {"ids" => [0], "peer-limit" => 23}}

##Further information

Especially for *do_action*, you may want to read [the specs](http://trac.transmissionbt.com/browser/trunk/doc/rpc-spec.txt) of the RPC of Transmission.