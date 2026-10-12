package Classes.Idle
{
   import Widgets.Windows.FreeGiftSelectionWindow;
   
   public class LoadFreeGiftsTask extends BaseIdleTask
   {
      
      private static const PRELOAD_RUNTIME_FLAG:String = "FREE_GIFTS_PRELOAD";
      
      public function LoadFreeGiftsTask(params:Object = null)
      {
         super();
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return false;
      }
      
      override public function get shouldAdd() : Boolean
      {
         var result:Boolean = false;
         if(Global.flashHotParams[PRELOAD_RUNTIME_FLAG] == true)
         {
            result = !(FreeGiftSelectionWindow.giftsLoaded() || FreeGiftSelectionWindow.giftsLoading());
         }
         return result;
      }
      
      override public function fire() : void
      {
         FreeGiftSelectionWindow.loadFreeGifts();
      }
   }
}

