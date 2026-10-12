package Classes.feed
{
   import Classes.Equipment;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.IntVector2;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   
   public class VehicleLevelUpFeed extends FarmFeed
   {
      
      private var m_vehicle:Equipment;
      
      public function VehicleLevelUpFeed(rewardUrl:String, vehicle:Equipment)
      {
         super();
         m_bundleId = "feed_garage_upgrade";
         m_params.rewardLink = rewardUrl;
         m_params.vehicle = vehicle.getItem().friendlyName;
         this.m_vehicle = vehicle;
         m_params.images = [{
            "src":vehicle.getItem().icon,
            "href":"{SN_APP_URL}" + rewardUrl
         }];
      }
      
      public function startFeedFlow() : void
      {
         var size:IntVector2 = null;
         var promptKey:String = null;
         var message:String = null;
         var prompt:GenericPopup = null;
         if(Boolean(m_params.rewardLink) && m_params.rewardLink != "")
         {
            size = this.m_vehicle.getActionSize();
            promptKey = "VehicleFeedPrompt_" + this.m_vehicle.getItem().className;
            if(this.m_vehicle.getItem().className.indexOf("Rotatable") >= 0)
            {
               promptKey = promptKey.replace("Rotatable","");
            }
            message = ZLocUtils.t("Dialogs",promptKey,{
               "item":ZLocUtils.tk_pk(m_params.vehicle),
               "quantityX":size.x,
               "quantityY":size.y
            });
            prompt = new GenericPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onPromptClose);
            prompt.setTrackerKey("equipment-" + this.m_vehicle.getItem().className);
            UI.displayPopup(prompt,true,"feed");
            FarmStatsManager.count("feed_garage_upgrade","impressions");
         }
      }
      
      public function onPromptClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            this.publish();
            FarmStatsManager.count("shortfeed","feed_garage_vehicle_upgrade");
            FarmStatsManager.count("feed_garage_upgrade","impressions");
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([m_params.rewardLink]));
         }
      }
   }
}

