package Classes.Idle
{
   import Classes.NPCConfigData;
   import Managers.NPCManager;
   import Managers.ToasterManager;
   import Widgets.Windows.Promotions.PromoToasterWindow;
   
   public class NPCPromoTask extends BaseIdleTask
   {
      
      protected var m_initialized:Boolean = false;
      
      private var m_npcData:NPCConfigData = null;
      
      protected var m_NPCDelay:Number = 0;
      
      protected var m_creationTime:Number = 0;
      
      public function NPCPromoTask(npcData:NPCConfigData, delayTime:Number = 30000)
      {
         this.m_npcData = npcData;
         this.m_NPCDelay = delayTime;
         m_displaysPopup = true;
         super();
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         if(!this.m_initialized || this.m_creationTime < 0)
         {
            this.m_creationTime = GlobalEngine.currentTime;
            this.m_initialized = true;
         }
         var canFire:Boolean = false;
         if(this.m_creationTime > 0 && this.m_creationTime + this.m_NPCDelay < GlobalEngine.currentTime)
         {
            canFire = true;
         }
         return canFire;
      }
      
      override public function fire() : void
      {
         var toasterAsset:String = null;
         if(NPCManager.getInstance().canDisplayToaster(this.m_npcData))
         {
            toasterAsset = Global.farmGameSettingsManager.getString("promoFarmToasterAsset_" + this.m_npcData.name);
            ToasterManager.getInstance().addImmediate(new PromoToasterWindow(toasterAsset,this.m_npcData,this.toasterClickCallback));
            NPCManager.getInstance().setToasterSeenFlag(this.m_npcData);
         }
      }
      
      private function toasterClickCallback(npcData:NPCConfigData) : void
      {
         if(npcData != null)
         {
            NPCManager.getInstance().visitFarm(npcData.id);
         }
      }
   }
}

