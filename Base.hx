import flash.events.NetStatusEvent;
import flash.media.Microphone;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.text.TextField;

class Base {

  static var rtmp = "rtmp://localhost";
  static var server = "http://localhost:3000";

  static var nc : NetConnection;
  static var ns : NetStream;
  static var mic : Microphone;

  static var httpExp : EReg = ~/^http:\/\//;
  static var bpos : Float = 2;

  static function privacyPane() {
    Security.showSettings(SecurityPanel.PRIVACY);
  }

  static function micPane() {
    Security.showSettings(SecurityPanel.MICROPHONE);
  }

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

  static function startConnect(host, func) {
    nc = new NetConnection();
    nc.addEventListener(NetStatusEvent.NET_STATUS, func);
    nc.connect(host);
  }

  static function play(filename) {
    var host : String = rtmp;
    if (httpExp.match(filename))
      host = null;
    Base.startConnect(host, function(e) {
      if (e.info.code == "NetConnection.Connect.Success") {
        ns = new NetStream(nc);
        ns.play(filename);
      }
    });
  }

  static function record(filename, func) {
    NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
    mic = Microphone.getMicrophone(-1);
    mic.rate = 44;
    Base.startConnect(rtmp, function(e) {
      if (e.info.code == "NetConnection.Connect.Success") {
        ns = new NetStream(nc);
        ns.addEventListener(NetStatusEvent.NET_STATUS, function(e) {});
        ns.attachAudio(mic);
        ns.publish(filename);
        func(ns);
      }
    });
  }

  static function stop() {
    ns.close();
    nc.close();
  }

  static function elapsedTime() {
    return ns.time;
  }
}
