require 'vendor/gems/environment.rb'
Bundler.require_env

class TransmissionRPCClient
	attr_reader :sid, :host, :port, :root_path
	def initialize(host="localhost",port="9091")
		@host = host
		@port = port
		@root_path = "/transmission/rpc"
		get_sid
	end
	def get_sid
		@sid =  Net::HTTP.new(@host,@port).head(@root_path)["X-Transmission-Session-Id"]
	end
	def do_action userHash
	 actionHash = {}
	 if not ["add","start","stop","set","get","delete"].include? userHash["method"] 
	   puts "Could not find method #{userHash[:method]}"
	   return false
	 end	 
	 case userHash["method"]
	 when "add"
	   if not (userHash["arguments"].has_key?("filename") or userHash["arguments"].has_key?("metainfo"))
	     puts "Could not find metainfo oder filename argument"
	     return false
	   end
	 when "start","stop","set"
	   if not userHash["arguments"].has_key?("ids")
	     puts "No ids found, assume all!"
     end
   when "get"
     if not userHash["arguments"].has_key?("fields")
       puts "No fields array found"
       return false
     end
   end
   actionHash["arguments"] = userHash["arguments"]
   actionHash["method"] = "torrent-" + userHash["method"]

   resp = JSON.parse(RestClient.post(@host + ":" + @port + @root_path, actionHash.to_json, "X-Transmission-Session-Id" => @sid, "content-type" => "application/json"))
   if not resp["result"] == "success"
     puts "request failed"
     puts resp["result"]
     return false
   end
   return resp
	end
	def start_torrent id
    return do_action({"method" => "start", "arguments" => {"ids" => [id]}})
  end
  def add_torrent filename
    return do_action({"method" => "add", "arguments" => {"filename" => filename}})
  end
  def add_metainfo io_object
    metainfo = ""
    begin
      metainfo << io_object.read
    rescue EOFError
    end
    return do_action({"method" => "add", "arguments" => {"metainfo" => Base64.encode64(metainfo)}})
 end
    
  def list_torrents 
    torrentlist = []
    resp = do_action({"method" => "get", "arguments" => {"fields" => ["id","name","percentDone"]}})
    resp["arguments"].each do |argument|
      argument[1].each do |data|
        torrentlist << data
      end
    end
    return torrentlist
  end
  def get_info id
    resp = do_action({"method" => "get", "arguments" => {"fields" => ["id","name", "percentDone", "files"], "ids" => [id]}})
    return resp["arguments"]["torrents"][0]
  end
end

