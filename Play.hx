import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.external.ExternalInterface;
import flash.media.Video;
import flash.net.NetStream;
import haxe.Timer;

class PlayOnPng extends BitmapData {}
class PlayOffPng extends BitmapData {}

class Play extends Base {

  static var url : String;
  static var file : String;
  static var re : EReg = ~/\/(\w{2}\/\w+)$/;
  static var re2 : EReg = ~/^(\w{2})(\w+)$/;
  static var solid : MovieClip;
  static var fader : Timer;
  static var start : Float = 0;

  static function playRecording(e) {
    solid.alpha = 1.0;
    fader = new Timer(100);
    start = Timer.stamp();
    fader.run = function() {
      var used = Timer.stamp() - start;
      solid.alpha = 1.0 - (used / 1.0);
      if (used >= 1.0)
      {
        solid.alpha = 0.0;
        fader.stop();
      }
    };
    Base.play(Base.server + "/" + file + ".flv");
  }

  static function main() {
    //
    // Figure out the file's chirrp id
    //
    url = ExternalInterface.call("window.location.href.toString");
		file = flash.Lib.current.loaderInfo.parameters.file;
    if (file == null && re.match(url))
      file = re.matched(1);
    else if (re2.match(file))
      file = re2.matched(1) + "/" + re2.matched(2);

    //
    // Play button
    //
    var play_off = new PlayOffPng(0, 0);
    var play_on = new PlayOnPng(0, 0);
		var play_hit = new MovieClip();
		play_hit.graphics.beginFill(0);
    play_hit.graphics.drawRect(0, 0, 70, 15);

    var playButton =
      Base.addBitmapButton(
        play_off,
        play_on,
        play_hit,
        playRecording
      );

    var mc = Base.movieBitmap(play_off);
    playButton.upState = mc;
    playButton.overState = mc;
    solid = Base.movieBitmap(play_on);
    solid.alpha = 0;
    mc.addChild(solid);

		flash.Lib.current.addChild(playButton);
  }
}
