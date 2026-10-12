package Display
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class QueuedIconIncrementer
   {
      
      private var m_queuedIcon:QueuedIcon;
      
      private var m_iconTextField:TextField;
      
      private var m_currentCount:int = 0;
      
      public function QueuedIconIncrementer(queuedIcon:QueuedIcon, initialCount:int = 0)
      {
         super();
         this.m_queuedIcon = queuedIcon;
         if(this.m_queuedIcon)
         {
            this.m_queuedIcon.contentManip = this.onLoadIcon;
         }
         this.m_currentCount = initialCount;
      }
      
      private function onLoadIcon(content:DisplayObject) : void
      {
         var mc:MovieClip = content as MovieClip;
         if(Boolean(mc) && Boolean(mc.friendNumber_tf))
         {
            this.m_iconTextField = mc.friendNumber_tf as TextField;
            if(this.m_iconTextField)
            {
               this.setValue(this.m_currentCount);
            }
         }
      }
      
      public function decrementCount(delta:int = 1, hideOnZero:Boolean = false) : void
      {
         this.m_currentCount -= delta;
         this.setValue(this.m_currentCount);
         if(this.m_currentCount <= 0 && hideOnZero)
         {
            this.m_queuedIcon.tweenOut();
         }
      }
      
      public function incrementCount(delta:int = 1) : void
      {
         this.m_currentCount += delta;
         this.setValue(this.m_currentCount);
      }
      
      private function setValue(count:int = 0) : void
      {
         var countString:String = null;
         if(this.m_iconTextField)
         {
            count = Math.max(0,count);
            countString = count.toString();
            if(countString.length < 2)
            {
               countString = "x" + countString;
            }
            this.m_iconTextField.text = countString;
         }
      }
   }
}

