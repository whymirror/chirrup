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
  static var countclip : MovieClip;
	static var soundsgood : MovieClip;

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
    stopButton.visible = true;
    recButton.visible = false;
    Base.record(uuid + ".flv", function(ns) {
      start = 0;
      clock = new Timer(200);
      clock.run = timeRecording;
    });
  }

  static function playRecording(e) {
    Base.play(uuid + ".flv");
  }

  static function reRecord(e) {
    recButton.visible = true;
    stopButton.visible = false;
    playButton.visible = false;
    countdown.text = "8";
    countdown.setTextFormat(countfont);
    countclip.visible = true;
    soundsgood.visible = false;
  }

  static function stopRecording(e) {
    Base.stop();
    clock.stop();
    stopButton.visible = false;
    playButton.visible = true;
    countclip.visible = false;
    soundsgood.visible = true;
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

    countclip = new MovieClip();
    var mct = new TextField();
    mct.text = "You have";
    mct.setTextFormat(mcmed);
    countclip.addChild(mct);

    countdown = new TextField();
    countdown.text = "8";
    countdown.setTextFormat(countfont);
    countclip.addChild(countdown);
    countdown.x = 10;
    countdown.y = 4;
		flash.Lib.current.addChild(countclip);

    var mct2 = new TextField();
    mct2.text = "seconds";
    mct2.setTextFormat(mcmed);
    mct2.x = 3;
    mct2.y = 72;
    countclip.addChild(mct2);

    countclip.x = 220;
    countclip.y = 20;

    //
    // Sounds good?
    //
    var med = new TextFormat();
    med.font = "Verdana";
    med.size = 25;
    med.bold = true;
    med.color = 0;

    var soundstxt = new TextField();
    soundstxt.text = "Sounds good?";
    soundstxt.width = 250;
    soundstxt.height = 50;
    soundstxt.setTextFormat(med);

    var okLink = Base.addLink("OK, make it tweet!", function(e) {});
    var noLink = Base.addLink("Nah, record it again.", reRecord);

    soundsgood = new MovieClip();
    soundsgood.addChild(soundstxt);
    soundsgood.addChild(okLink);
    soundsgood.addChild(noLink);

    okLink.x = 30;
    okLink.y = 40;
    noLink.x = 20;
    noLink.y = 62;

		flash.Lib.current.addChild(soundsgood);
    soundsgood.visible = false;
    soundsgood.x = 170;
    soundsgood.y = 20;
  }
}
