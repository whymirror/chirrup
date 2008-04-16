import flash.external.ExternalInterface;
import flash.media.Video;
import flash.net.NetStream;

class Play extends Base {

  static var url : String;
  static var file : String;
  static var re : EReg = ~/\/(\w+)\/(\w+)$/;

  static function playRecording() {
    Base.play(Base.server + "/new.flv");
  }

  static function main() {
    url = ExternalInterface.call("window.location.href.toString");
		file = flash.Lib.current.loaderInfo.parameters.file;
    if (file == null && re.match(url))
      file = re.matched(1) + re.matched(2);
    Base.addButton("Play", playRecording);
  }
}
