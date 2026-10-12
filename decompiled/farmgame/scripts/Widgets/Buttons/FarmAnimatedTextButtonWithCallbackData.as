package Widgets.Buttons
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmAnimatedTextButtonWithCallbackData extends FarmAnimatedTextButton
   {
      
      private var m_callbackData:Object;
      
      public function FarmAnimatedTextButtonWithCallbackData(element:MovieClip, text:String = "", callback:Function = null, autoSize:Boolean = false, htmlText:Boolean = false, callbackData:Object = null)
      {
         super(element,text,callback,autoSize,htmlText);
         this.m_callbackData = callbackData;
      }
      
      public function set callbackData(data:Object) : void
      {
         this.m_callbackData = data;
      }
      
      override public function preCallback(e:Event) : void
      {
         m_callback(e,this.m_callbackData);
      }
   }
}

