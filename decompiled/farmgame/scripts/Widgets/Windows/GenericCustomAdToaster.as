package Widgets.Windows
{
   import flash.events.Event;
   
   public class GenericCustomAdToaster extends GenericAdToaster
   {
      
      protected var m_closeCallback:Function;
      
      protected var m_actionCallback:Function;
      
      public function GenericCustomAdToaster(title:String, message:String, duration:Number, actionCallback:Function = null, closeCallback:Function = null)
      {
         super(null);
         this.m_title = title;
         this.m_message = message;
         this.m_closeCallback = closeCallback;
         this.m_actionCallback = actionCallback;
         this.duration = duration * 1000;
      }
      
      override public function close() : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close();
      }
      
      override protected function onHitBoxAction(event:Event) : void
      {
         if(this.m_actionCallback != null)
         {
            this.m_actionCallback();
         }
         super.onHitBoxAction(event);
      }
   }
}

