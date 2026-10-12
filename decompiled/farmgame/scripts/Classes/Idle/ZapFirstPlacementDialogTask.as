package Classes.Idle
{
   import Managers.ZapPromoManager;
   
   public class ZapFirstPlacementDialogTask extends BaseIdleTask
   {
      
      protected static var m_nextFireTime:Number = 0;
      
      protected static var m_itemName:String = "";
      
      protected var m_mouseDelay:Number = 500;
      
      public function ZapFirstPlacementDialogTask(itemName:String)
      {
         m_itemName = itemName;
         super();
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.m_mouseDelay;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > m_nextFireTime;
      }
      
      override public function fire() : void
      {
         ZapPromoManager.tryShowFirstPlacementDialog(Global.farmGameSettingsManager.getFarmItemByName(m_itemName));
      }
   }
}

