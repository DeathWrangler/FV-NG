package Classes.util
{
   import Display.StrokeTextField;
   import Engine.Utilities;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
   public class ZCacheTracker extends Sprite
   {
      
      private static const UPDATE_INTERVAL:Number = 1000;
      
      private var fontSize:Number;
      
      private var lastUpdate:Number;
      
      private var m_timer:Timer;
      
      private var m_displayTextField:TextField;
      
      public function ZCacheTracker(textColor:Number = 16777215, fontSize:Number = 16)
      {
         super();
         var textFormat:TextFormat = new TextFormat(null,fontSize,textColor,true);
         this.m_displayTextField = new StrokeTextField(0,0.8);
         this.m_displayTextField.setTextFormat(textFormat);
         this.m_displayTextField.autoSize = TextFieldAutoSize.LEFT;
         this.m_displayTextField.defaultTextFormat = textFormat;
         this.m_displayTextField.selectable = false;
         Utilities.toggleInputOnlySelf(this.m_displayTextField,false);
         addChild(this.m_displayTextField);
         this.m_timer = new Timer(UPDATE_INTERVAL,0);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.update);
      }
      
      override public function set visible(value:Boolean) : void
      {
         super.visible = value;
         if(GlobalZCache.instance)
         {
            if(value && !this.m_timer.running)
            {
               this.m_timer.start();
            }
            else if(this.m_timer.running)
            {
               this.m_timer.stop();
            }
         }
      }
      
      private function update(event:TimerEvent) : void
      {
         var text:String = null;
         var stats:Object = null;
         var mem:Number = NaN;
         if(GlobalZCache.instance)
         {
            text = "";
            stats = GlobalZCache.instance.stats;
            text += stats.cardinality + " objects\n";
            mem = Number(stats.size / 1024 / 1024);
            text += mem.toFixed(2) + " MB\n";
            text += stats.gets + " / " + stats.puts + " GETs/PUTs\n";
            if(GlobalZCache.instance.allowed)
            {
               text += Number(stats.hits / stats.gets * 100).toFixed(2) + "% SUCCESS";
            }
            else
            {
               text += "DISABLED";
            }
            this.m_displayTextField.text = text;
         }
      }
   }
}

