import flash.display.BitmapData;
import flash.net.NetStream;
import flash.text.TextField;
import haxe.Timer;

class ShoesPng extends BitmapData {
}

class Rec extends Base {

  static var seconds : Float = 8;

  static var url : String;
	static var stat : TextField;
  static var clock : Timer;
  static var start : Float = 0;

  static function timeRecording() {
    var used : Float;
    stat.text = "" + Base.elapsedTime();
    if (Base.elapsedTime() > 0) {
      if (start == 0) {
        start = Timer.stamp();
      }

      used = (Timer.stamp() - start);
      stat.text = "" + used;
      if (used >= seconds) {
        stopRecording();
        clock.stop();
      }
    }
  }

  static function startRecording() {
    stat.text = "Connecting...";
    Base.record("new.flv", function(ns) {
      start = 0;
      clock = new Timer(200);
      clock.run = timeRecording;
    });
  }

  static function playRecording() {
    stat.text = "Playing.";
    Base.play("new.flv");
  }

  static function stopRecording() {
    stat.text = "Stopped";
    Base.stop();
    clock.stop();
  }

  static function main() {
    var png1 : BitmapData = new ShoesPng(0, 0);
    flash.Lib.current.addChild(new flash.display.Bitmap(png1, flash.display.PixelSnapping.AUTO, true));

    url = flash.Lib.current.loaderInfo.loaderURL;
    trace(url);

    Base.addButton("Start", startRecording);
    Base.addButton("Stop", stopRecording);
    Base.addButton("Play", playRecording);

		stat = new TextField();
		stat.text = "Stopped.";
		stat.width = 380;
		stat.height = 18;
		stat.selectable = false;
		stat.x = 2;
    stat.y = 30;
		flash.Lib.current.addChild(stat);
  }
}
