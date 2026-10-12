package Display
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import flash.events.MouseEvent;
   
   public class RetentionItemPopup extends GenericPopup
   {
      
      protected var m_itemNames:Array;
      
      protected var m_counterName:String;
      
      public function RetentionItemPopup(message:String, itemNames:Array, counterName:String)
      {
         this.m_itemNames = itemNames;
         this.m_counterName = counterName;
         super(message,GenericPopup.TYPE_OK,this.onAccept);
      }
      
      public static function conditionallyShow() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_FREE_ORCHARD) == 2)
         {
            TransactionManager.addTransaction(new TGenericTransaction("UserService","onGiveRetentionItem",onComplete),true);
         }
      }
      
      protected static function onComplete(result:Object) : void
      {
         var itemName:String = null;
         var variant:int = 0;
         var message:String = null;
         if(result)
         {
            if(Boolean(result.hasOwnProperty("gifts")) && Boolean(result.gifts) && result.gifts.length > 0)
            {
               for each(itemName in result.gifts)
               {
                  Global.player.addGift(itemName);
               }
               variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_FREE_ORCHARD);
               message = ZLocUtils.t("Dialogs","RetentionFreeItemMessage_variant" + variant);
               if(message != null && message != "")
               {
                  UI.displayPopup(new RetentionItemPopup(message,result.gifts,"retention_orchard"),true);
               }
            }
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         close();
         if(this.m_itemNames[0])
         {
            Global.world.enterForcePlaceMode(this.m_itemNames[0]);
            StatsManager.count(this.m_counterName,"dialog","place",this.m_itemNames[0]);
         }
      }
   }
}

