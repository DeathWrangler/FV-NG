package Classes.feed
{
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class OilBarronFeed extends FarmFeed
   {
      
      protected var m_iconUrl:String;
      
      protected var m_popupIconUrl:String;
      
      protected const REQUIRE_VALID_REWARDURL:Boolean = true;
      
      public function OilBarronFeed(targetId:String, rewardUrl:String)
      {
         super();
         var feedVariant:int = Global.experimentManager.getExperimentVariant("fv_fb_feed_changes");
         m_bundleId = "feed_OilBarronW2W_" + String(feedVariant);
         m_params.rewardLink = rewardUrl;
         m_params.first_name = Global.player.firstName;
         this.m_targetUids = [targetId];
         this.m_iconUrl = Global.getAssetURL("assets/newsfeed/fuelgift1.png");
         this.m_popupIconUrl = Global.getAssetURL("assets/equipment/equip_gas_can_icon.png");
         m_params.images = [{
            "src":this.m_iconUrl,
            "href":"{SN_APP_URL}" + rewardUrl
         }];
      }
      
      public function startFeedFlow() : void
      {
         var message:String = null;
         var baronPrompt:GenericIconPopup = null;
         var userName:String = Global.worldManager.getVisitName(true);
         var userGender:String = Global.worldManager.getVisitGender();
         if(!this.REQUIRE_VALID_REWARDURL || Boolean(m_params.rewardLink && m_params.rewardLink != "") && Boolean(this.REQUIRE_VALID_REWARDURL))
         {
            message = ZLocUtils.t("Dialogs","OilBarronPrompt",{
               "user":ZLocUtils.tn(userName,ZLocUtils.tg(userGender)),
               "user_same":userName
            });
            baronPrompt = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onPromptClose,this.m_popupIconUrl);
            baronPrompt.setTrackerKey("fbexperiment-w2w_neighbor_fuel_0");
            UI.displayPopup(baronPrompt,true,"baron");
            FarmStatsManager.featureSample("Fuel","Disc_Friend_Farm","ask_permission_flow","ask_permission_dialog","impressions");
         }
      }
      
      public function onPromptClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            this.publish();
            FarmStatsManager.featureSample("Fuel","Disc_Friend_Farm","ask_permission_flow","ask_permission_dialog","click_share");
         }
      }
   }
}

