package Widgets.Windows
{
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   
   public class BringBackWinterBuyWindow extends DragonBreedingBuyCraftWindow
   {
      
      private var m_owner:BringBackEasterWindow;
      
      private var m_callback:Function = null;
      
      public function BringBackWinterBuyWindow(dialogPath:String, featureName:String = null, craftItem:String = "", window:BringBackEasterWindow = null, callBack:Function = null)
      {
         this.m_owner = window;
         this.m_callback = callBack;
         super(dialogPath,featureName,craftItem);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("frame_mc"))
         {
            addWidget(new ZwFrame(m_window["frame_mc"]),true) as ZwFrame;
         }
      }
      
      override protected function setupBuySlot(index:Number, mc:MovieClip) : void
      {
         /*
          * Decompilation error
          * Code may be obfuscated
          * Tip: You can try enabling "Deobfuscate code" option in Settings
          * Error type: IndexOutOfBoundsException (Index -1 out of bounds for length 0)
          */
         throw new flash.errors.IllegalOperationError("Not decompiled due to error");
      }
      
      override public function close() : void
      {
         super.close();
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}

