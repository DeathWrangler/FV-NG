package Widgets.View.Icons
{
   import Widgets.Parser.XMLDialogParser;
   import Widgets.View.Core.ElementBase;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.Timer;
   
   public class IconImageBase extends ElementBase
   {
      
      public static const SPINNER_COLOR_DIM:Number = 7829367;
      
      public static const SPINNER_COLOR_LIT:Number = 13421772;
      
      public static const SPINNER_COLOR_FAIL:Number = 14540253;
      
      public static const SPINNER_DOT_OFFSET:Number = 12;
      
      public static const SPINNER_DOT_RADIUS:Number = 3;
      
      public static const SPINNER_OFFSET_X:Number = 4;
      
      public static const SPINNER_ANIMATION_DELAY:Number = 500;
      
      public var m_loader:Loader = null;
      
      public var m_loaderContext:LoaderContext = null;
      
      public var m_url:String = null;
      
      public var m_spinner:Sprite = null;
      
      public var m_spinTimer:Timer = null;
      
      public var m_toolTip:String = null;
      
      public function IconImageBase(aKeyValuePairs:Array, aTokenValues:Array)
      {
         var xScale:Number = NaN;
         super(aKeyValuePairs);
         var nHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var sTip:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_TOOLTIP_TEXT);
         var sUrl:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_REL_URL);
         var nWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         var x:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_POS_X);
         xScale = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_SCALE_X);
         var y:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_POS_Y);
         var yScale:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_SCALE_Y);
         this.m_widthNoShadow = nWidth;
         this.m_heightNoShadow = nHeight;
         this.m_url = sUrl;
         this.scaleX = xScale;
         this.scaleY = yScale;
         this.m_toolTip = sTip;
         this.m_loader = new Loader();
         this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
         this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoaderError);
         this.m_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoaderError);
         if(replaceTokens(this.m_url,aTokenValues) == "")
         {
            return;
         }
         this.m_url = replaceTokens(this.m_url,aTokenValues);
         this.m_loaderContext = new LoaderContext();
         this.m_loader.load(new URLRequest(this.m_url),this.m_loaderContext);
         addChild(this.m_loader);
         this.createSpinner();
         if(this.m_toolTip != null)
         {
            this.m_toolTip = replaceTokens(this.m_toolTip,aTokenValues);
            addToolTip(this.m_toolTip);
         }
      }
      
      public function createSpinner() : void
      {
         var nHalfW:Number = getWidth() * 0.5;
         var nHalfH:Number = getHeight() * 0.5;
         this.m_spinner = new Sprite();
         this.m_spinner.x = nHalfW;
         this.m_spinner.y = nHalfH;
         addChild(this.m_spinner);
         this.m_spinner.graphics.beginFill(SPINNER_COLOR_LIT,1);
         this.m_spinner.graphics.drawCircle(SPINNER_DOT_OFFSET,0,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.endFill();
         this.m_spinner.graphics.beginFill(SPINNER_COLOR_DIM,1);
         this.m_spinner.graphics.drawCircle(-SPINNER_DOT_OFFSET,0,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(0,SPINNER_DOT_OFFSET,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(0,-SPINNER_DOT_OFFSET,SPINNER_DOT_RADIUS);
         var nSpinner_DotOffset:Number = SPINNER_DOT_OFFSET * 0.7;
         this.m_spinner.graphics.drawCircle(nSpinner_DotOffset,nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(-nSpinner_DotOffset,nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(-nSpinner_DotOffset,-nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(nSpinner_DotOffset,-nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.endFill();
         this.m_spinTimer = new Timer(SPINNER_ANIMATION_DELAY);
         this.m_spinTimer.addEventListener(TimerEvent.TIMER,this.onSpinTimer);
         this.m_spinTimer.start();
      }
      
      public function drawSpinnerFail() : void
      {
         if(this.m_spinner == null)
         {
            return;
         }
         this.m_spinner.rotation = 0;
         var nHalfW:Number = getWidth() * 0.5;
         var nHalfH:Number = getHeight() * 0.5;
         this.m_spinner.graphics.clear();
         this.m_spinner.graphics.beginFill(SPINNER_COLOR_LIT,1);
         this.m_spinner.graphics.lineStyle(3,SPINNER_COLOR_LIT,1);
         this.m_spinner.graphics.moveTo(SPINNER_OFFSET_X,SPINNER_OFFSET_X);
         this.m_spinner.graphics.lineTo(-SPINNER_OFFSET_X,-SPINNER_OFFSET_X);
         this.m_spinner.graphics.moveTo(SPINNER_OFFSET_X,-SPINNER_OFFSET_X);
         this.m_spinner.graphics.lineTo(-SPINNER_OFFSET_X,SPINNER_OFFSET_X);
         this.m_spinner.graphics.endFill();
         this.m_spinner.graphics.beginFill(SPINNER_COLOR_FAIL,1);
         this.m_spinner.graphics.lineStyle();
         this.m_spinner.graphics.drawCircle(SPINNER_DOT_OFFSET,0,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(-SPINNER_DOT_OFFSET,0,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(0,SPINNER_DOT_OFFSET,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(0,-SPINNER_DOT_OFFSET,SPINNER_DOT_RADIUS);
         var nSpinner_DotOffset:Number = SPINNER_DOT_OFFSET * 0.7;
         this.m_spinner.graphics.drawCircle(nSpinner_DotOffset,nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(-nSpinner_DotOffset,nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(-nSpinner_DotOffset,-nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.drawCircle(nSpinner_DotOffset,-nSpinner_DotOffset,SPINNER_DOT_RADIUS);
         this.m_spinner.graphics.endFill();
      }
      
      public function killSpinner() : void
      {
         if(this.m_spinner == null)
         {
            return;
         }
         removeChild(this.m_spinner);
         this.m_spinner.graphics.clear();
         this.m_spinner = null;
      }
      
      public function onSpinTimer(event:TimerEvent) : void
      {
         this.m_spinner.rotation += 45;
      }
      
      public function killSpinTimer() : void
      {
         if(this.m_spinTimer == null)
         {
            return;
         }
         this.m_spinTimer.stop();
         this.m_spinTimer = null;
      }
      
      protected function onLoaderComplete(event:Event) : void
      {
         var info:LoaderInfo = event.currentTarget as LoaderInfo;
         dtrace("image load complete: " + this.m_url);
         this.killSpinTimer();
         this.killSpinner();
      }
      
      protected function onLoaderError(event:ErrorEvent) : void
      {
         var info:LoaderInfo = event.currentTarget as LoaderInfo;
         this.killSpinTimer();
         this.drawSpinnerFail();
         addToolTip("ERROR: IconImageBase load failed: " + this.m_url);
      }
   }
}

