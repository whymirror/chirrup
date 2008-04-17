import flash.events.NetStatusEvent;
import flash.media.Microphone;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.text.TextField;
import flash.text.TextFormat;

class Base {

  static var rtmp = "rtmp://chirrp.net";
  static var server = "http://chirrp.net";

  static var nc : NetConnection;
  static var ns : NetStream;
  static var mic : Microphone;

  static var httpExp : EReg = ~/^http:\/\//;

  static var DEGTORAD:Float = Math.PI/180;
  static var a:Float = Math.tan( 22.5 * DEGTORAD);

  static var UID_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  
  public static function random(?size : Int) : String
  {
    if(size == null) size = 32;
    var nchars = UID_CHARS.length;
    var uid = "";
    for (i in 0 ... size){
      uid += UID_CHARS.charAt( Std.int(Math.random() * nchars) );
    }
    return uid;
  }

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

  static function addBitmap( bmp ) {
    flash.Lib.current.addChild(new flash.display.Bitmap(bmp, flash.display.PixelSnapping.AUTO, true));
  }

  static function movieBitmap( bmp ) {
		var mc = new flash.display.MovieClip();
    mc.addChild(new flash.display.Bitmap(bmp, flash.display.PixelSnapping.AUTO, true));
    return mc;
  }

  static function addBitmapButton( bmpOff, bmpOn, bmpHit, onClick )
  {
		var sb = new flash.display.SimpleButton();
		sb.upState = movieBitmap(bmpOff);
		sb.overState = movieBitmap(bmpOff);
		sb.downState = movieBitmap(bmpOn);
		sb.hitTestState = bmpHit;
		sb.useHandCursor = true;
		sb.addEventListener(flash.events.MouseEvent.CLICK, onClick);
		flash.Lib.current.addChild(sb);
    return sb;
  }

  static function drawCircle( mc:flash.display.MovieClip, x:Float, y:Float, r:Float )
  {
    mc.graphics.moveTo( x + r, y );

    for (i in 0...8) {
      var endX = x + r * Math.cos( (i + 1) * 45 * DEGTORAD);
      var endY = y + r * Math.sin( (i + 1) * 45 * DEGTORAD);
      var controlX = endX + r * a * Math.cos( ((i + 1) * 45 - 90) * DEGTORAD);
      var controlY = endY + r * a * Math.sin( ((i + 1) * 45 - 90) * DEGTORAD);
      mc.graphics.curveTo( controlX, controlY, endX, endY);
    }
  }

	static function addLink( text, onClick ) {
    var f = new TextFormat();
    f.font = "Verdana";
    f.size = 12;
    f.color = 0x5599AA;
    f.underline = true;

    var f2 = new TextFormat();
    f2.font = "Verdana";
    f2.size = 12;
    f2.color = 0xAA9955;
    f2.underline = true;

		var t = new TextField();
		t.text = text;
		t.width = t.textWidth + 36;
		t.height = 18;
		t.selectable = false;
    t.setTextFormat(f);
		t.x = 2;

		var t2 = new TextField();
		t2.text = text;
		t2.width = t.textWidth + 36;
		t2.height = 18;
		t2.selectable = false;
    t2.setTextFormat(f2);
		t2.x = 2;

		var a = new flash.display.MovieClip();
		a.addChild(t);

		var b = new flash.display.MovieClip();
		b.graphics.beginFill(0);
		b.graphics.drawRect(0,0,t.width,18);

		var c = new flash.display.MovieClip();
		c.addChild(t2);

		var sb = new flash.display.SimpleButton();
		sb.upState = a;
		sb.overState = c;
		sb.downState = c;
		sb.hitTestState = b;
		sb.useHandCursor = true;
		sb.addEventListener(flash.events.MouseEvent.CLICK, onClick);
    return sb;
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
