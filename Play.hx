import flash.external.ExternalInterface;
import flash.media.Video;
import flash.net.NetStream;

class Play extends Base {

  static var url : String;
  static var file : String;
  static var re : EReg = ~/\/(\w{2}\/\w+)$/;
  static var re2 : EReg = ~/^(\w{2})(\w+)$/;

  static function playRecording(e) {
    Base.play(Base.server + "/" + file + ".flv");
  }

  static function main() {
    url = ExternalInterface.call("window.location.href.toString");
		file = flash.Lib.current.loaderInfo.parameters.file;
    if (file == null && re.match(url))
      file = re.matched(1);
    else if (re2.match(file))
      file = re2.matched(1) + "/" + re2.matched(2);
		flash.Lib.current.addChild(Base.addLink("chirrp", playRecording));
  }
}
