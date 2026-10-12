package Classes.Idle
{
   import Classes.LESaleBundle;
   import Display.UI;
   import Managers.LEBundleManager;
   import Widgets.Windows.LESet.LEBundleWindow;
   
   public class LEBundleIdleTask extends BaseIdleTask
   {
      
      private var m_saleBundle:LESaleBundle = null;
      
      public function LEBundleIdleTask(saleBundle:LESaleBundle)
      {
         super();
         this.m_saleBundle = saleBundle;
         m_displaysPopup = true;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         var result:Boolean = false;
         if(!LEBundleManager.hasOutstandingTransactions())
         {
            result = true;
         }
         return result;
      }
      
      override public function get singletonClobber() : Boolean
      {
         return true;
      }
      
      override public function fire() : void
      {
         var dialog:LEBundleWindow = null;
         if(Boolean(this.m_saleBundle) && Boolean(this.m_saleBundle.discount))
         {
            dialog = new LEBundleWindow(this.m_saleBundle);
            UI.displayPopup(dialog,false,"LEBundleSale");
         }
      }
   }
}

