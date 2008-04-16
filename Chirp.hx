import flash.display.BitmapData;
import flash.events.NetStatusEvent;
import flash.media.Microphone;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.text.TextField;
import haxe.Timer;

class ShoesPng extends BitmapData {
}

class Chirp {

  static var host = "rtmp://code.whytheluckystiff.net";
  static var seconds : Float = 8;

  static var mic : Microphone;
  static var nc : NetConnection;
  static var ns : NetStream;
	static var stat : TextField;
  static var clock : Timer;
  static var start : Float = 0;

  static var bpos : Float = 2;

	static function doTrace( v : Dynamic, ?pos : haxe.PosInfos ) {
		trace(pos.fileName+"("+pos.lineNumber+") : "+Std.string(v));
	}

	static function doClick( onClick, e ) {
		try {
			onClick();
		} catch( e : Dynamic ) {
			doTrace(e);
		}
	}

	static function addButton( text, onClick ) {
		var t = new TextField();
		t.text = text;
		t.width = t.textWidth + 6;
		t.height = 18;
		t.selectable = false;
		t.x = 2;

		var b = new flash.display.MovieClip();
		b.graphics.beginFill(0xFFEEDD);
		b.graphics.lineStyle(2,0x000000);
		b.graphics.drawRect(0,0,t.width,18);
		b.addChild(t);

		var sb = new flash.display.SimpleButton();
		sb.upState = b;
		sb.overState = b;
		sb.downState = b;
		sb.hitTestState = b;
		sb.useHandCursor = true;
		sb.addEventListener(flash.events.MouseEvent.CLICK, callback(doClick, onClick));
		flash.Lib.current.addChild(sb);

		sb.x = bpos;
		sb.y = 2;
		bpos += t.width + 5;
	}

  static function privacyPane() {
    Security.showSettings(SecurityPanel.PRIVACY);
  }

  static function micPane() {
    Security.showSettings(SecurityPanel.MICROPHONE);
  }

  static function startConnect(func) {
    nc = new NetConnection();
    nc.addEventListener(NetStatusEvent.NET_STATUS, func);
    nc.connect(host);
  }

  static function timeRecording() {
    var used : Float;
    stat.text = "" + ns.time;
    if (ns.time > 0) {
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
    mic = Microphone.getMicrophone(-1);
    mic.rate = 11;
    startConnect(onMicConnect);
  }

  static function playRecording() {
    stat.text = "Playing.";
    startConnect(onPlayConnect);
  }

  static function stopRecording() {
    stat.text = "Stopped";
    ns.close();
    nc.close();
    clock.stop();
  }

  static function onRecordConnect(e) {
  }

  static function onMicConnect(e) {
    if (e.info.code == "NetConnection.Connect.Success") {
      ns = new NetStream(nc);
      ns.addEventListener(NetStatusEvent.NET_STATUS, onRecordConnect);
      ns.attachAudio(mic);
      ns.publish("new.flv");

      start = 0;
      clock = new Timer(200);
      clock.run = timeRecording;
    }
  }

  static function onPlayConnect(e) {
    if (e.info.code == "NetConnection.Connect.Success") {
      ns = new NetStream(nc);
      ns.play("new.flv");
    }
  }

  static function main() {
    var png1 : BitmapData = new ShoesPng(0, 0);
    flash.Lib.current.addChild(new flash.display.Bitmap(png1, flash.display.PixelSnapping.AUTO, true));

    NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
    addButton("Start", startRecording);
    addButton("Stop", stopRecording);
    addButton("Play", playRecording);

    mic = Microphone.getMicrophone(-1);
    mic.rate = 11;

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
