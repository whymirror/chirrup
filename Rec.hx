import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.net.NetStream;
import flash.text.TextField;
import flash.text.TextFormat;
import haxe.Timer;

class RecOffPng extends BitmapData {}
class RecOnPng extends BitmapData {}
class RecHoverPng extends BitmapData {}
class PlayUpPng extends BitmapData {}
class PlayDownPng extends BitmapData {}

class Rec extends Base {

  static var recButton : SimpleButton;
  static var stopButton : SimpleButton;
  static var playButton : SimpleButton;
	static var countdown : TextField;
	static var countfont : TextFormat;
	static var stat : TextField;

  static var seconds : Float = 8;

  static var uuid : String;
  static var url : String;
  static var clock : Timer;
  static var start : Float = 0;

  static function timeRecording() {
    var used : Float;
    if (Base.elapsedTime() > 0) {
      if (start == 0) {
        start = Timer.stamp();
      }

      used = (Timer.stamp() - start);
      countdown.text = "" + Std.int(seconds - used);
      countdown.setTextFormat(countfont);
      if (used >= seconds) {
        stopRecording(null);
        clock.stop();
      }
    }
  }

  static function startRecording(e) {
    stat.text = "Connecting...";
    stopButton.visible = true;
    recButton.visible = false;
    Base.record(uuid + ".flv", function(ns) {
      start = 0;
      clock = new Timer(200);
      clock.run = timeRecording;
    });
  }

  static function playRecording(e) {
    stat.text = "Playing.";
    Base.play(uuid + ".flv");
  }

  static function stopRecording(e) {
    stat.text = "Stopped";
    Base.stop();
    clock.stop();
    stopButton.visible = false;
    playButton.visible = true;
  }

  static function main() {
    uuid = Base.random(32);

    //
    // Record button
    //
    var rec_off = new RecOffPng(0, 0);
		var rec_hit = new MovieClip();
		rec_hit.graphics.beginFill(0);
    Base.drawCircle(rec_hit, 54, 54, 36);

    recButton =
      Base.addBitmapButton(
        rec_off,
        new RecHoverPng(0, 0),
        rec_hit,
        startRecording
      );

    recButton.x = 40;
    recButton.y = 10;

    //
    // Stop button
    //
    var stop_on = new RecOnPng(0, 0);

    stopButton =
      Base.addBitmapButton(
        stop_on,
        stop_on,
        rec_hit,
        stopRecording
      );

    stopButton.visible = false;
    stopButton.x = 40;
    stopButton.y = 10;

    //
    // Play button
    //
    var play_up = new PlayUpPng(0, 0);
    var play_down = new PlayDownPng(0, 0);

    playButton =
      Base.addBitmapButton(
        play_up,
        play_down,
        rec_hit,
        playRecording
      );

    playButton.visible = false;
    playButton.x = 40;
    playButton.y = 10;

    //
    // Countdown instrument
    //
    countfont = new TextFormat();
    countfont.font = "Verdana";
    countfont.size = 72;
    countfont.bold = true;
    countfont.color = 0;

    var mcmed = new TextFormat();
    mcmed.font = "Verdana";
    mcmed.size = 14;
    mcmed.bold = true;
    mcmed.color = 0;

    var mcc = new MovieClip();
    var mct = new TextField();
    mct.text = "You have";
    mct.setTextFormat(mcmed);
    mcc.addChild(mct);

    countdown = new TextField();
    countdown.text = "8";
    countdown.setTextFormat(countfont);
    mcc.addChild(countdown);
    countdown.x = 10;
    countdown.y = 4;
		flash.Lib.current.addChild(mcc);

    var mct2 = new TextField();
    mct2.text = "seconds";
    mct2.setTextFormat(mcmed);
    mct2.x = 3;
    mct2.y = 72;
    mcc.addChild(mct2);

    mcc.x = 220;
    mcc.y = 20;

    //
    // Sounds good?
    //
		stat = new TextField();
		stat.text = "Stopped.";
		stat.width = 380;
		stat.height = 18;
		stat.selectable = false;
		stat.x = 2;
    stat.y = 124;
		flash.Lib.current.addChild(stat);
  }
}
