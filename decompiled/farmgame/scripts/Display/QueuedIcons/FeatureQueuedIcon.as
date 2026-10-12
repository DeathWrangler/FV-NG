package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
   import Classes.FeatureMessagingDefinition;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.MOTD;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FeatureMessageEvent;
   import Managers.FeatureMessagingManager;
   import Managers.ReturningUserExperienceManager;
   import Transactions.TGetMOTD;
   
   public class FeatureQueuedIcon extends QueuedIconWithArrow
   {
      
      private const FOTW_STAT_COUNTER:String = "FOTW_HUD_ICON";
      
      private var m_featureName:String;
      
      private var m_featureDefinition:FeatureMessagingDefinition;
      
      private var m_motdData:Object;
      
      private var m_popMOTDOnLoad:Boolean = false;
      
      private var m_sentForMOTDData:Boolean = false;
      
      public function FeatureQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         super.init();
         this.m_featureName = extraData.featureName;
         this.m_featureDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.m_featureName);
         if(!FeatureMessagingManager.getInstance().isFeatureInitialized(this.m_featureName) && this.m_featureDefinition != null)
         {
            if(this.m_featureDefinition.motd != null && this.m_featureDefinition.motd.length > 0)
            {
               this.m_sentForMOTDData = true;
               TransactionManager.addTransaction(new TGetMOTD(this.m_featureDefinition.motd,this.onGetMOTD),true);
            }
         }
         FeatureMessagingManager.getInstance().addEventListener(FeatureMessageEvent.FEATUREUPDATE,this.onFeatureUpdate,false,0,true);
         this.conditionallyShowNewArrow();
         StatsManager.count(this.m_featureName,this.FOTW_STAT_COUNTER,"created");
      }
      
      override public function finishClick(queue:DynamicIconQueue) : void
      {
         super.finishClick(queue);
         Global.world.setDefaultGameMode();
         if(this.m_featureDefinition.passesPrereqs() && this.m_featureDefinition.passesIconPrereqs())
         {
            if(FeatureMessagingManager.getInstance().isFeatureInitialized(this.m_featureName))
            {
               StatsManager.count(this.m_featureName,this.FOTW_STAT_COUNTER,"click","open_feature_UI");
               FeatureMessagingManager.getInstance().openFeatureUI(this.m_featureName);
            }
            else if(this.m_motdData)
            {
               StatsManager.count(this.m_featureName,this.FOTW_STAT_COUNTER,"click","open_MOTD");
               MOTD.displayMOTD(this.m_motdData,false);
            }
            else
            {
               if(!this.m_sentForMOTDData && this.m_featureDefinition != null)
               {
                  if(this.m_featureDefinition.motd != null && this.m_featureDefinition.motd.length > 0)
                  {
                     this.m_sentForMOTDData = true;
                     TransactionManager.addTransaction(new TGetMOTD(this.m_featureDefinition.motd,this.onGetMOTD),true);
                  }
               }
               this.m_popMOTDOnLoad = true;
            }
         }
         else if(this.m_featureDefinition.customAction)
         {
            this.m_featureDefinition.customAction.perform();
         }
      }
      
      private function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdData = amfResult;
            this.m_sentForMOTDData = false;
            if(this.m_popMOTDOnLoad)
            {
               this.m_popMOTDOnLoad = false;
               StatsManager.count(this.m_featureName,this.FOTW_STAT_COUNTER,"click","open_MOTD");
               MOTD.displayMOTD(this.m_motdData,false);
            }
         }
      }
      
      private function onFeatureUpdate(event:FeatureMessageEvent) : void
      {
         if(event.featureName == this.m_featureName && event.hasCallToActionMessage() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HUD_FOTW_CTA_ARROW) == Experiments.VARIANT_HUD_FOTW_CTA_ARROW_ON)
         {
            m_arrowText = event.callToActionMessage;
            attachArrow(ArrowType.ARROWUPDATE);
         }
      }
      
      private function shouldShowNewArrow() : Boolean
      {
         var lastSeen:Number = NaN;
         var seenCheck:Number = NaN;
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HUD_FOTW_NEW_ARROW) >= Experiments.VARIANT_HUD_FOTW_NEW_ARROW_ON)
         {
            if(!Global.player.getSeenFlag(this.m_featureName + "_hud_new"))
            {
               result = true;
            }
            else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HUD_FOTW_NEW_ARROW) == Experiments.VARIANT_HUD_FOTW_NEW_ARROW_DAY_ON)
            {
               lastSeen = Global.player.getFeatureLastShown(this.m_featureName + "_hud_new");
               seenCheck = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastSeen;
               if(this.m_featureDefinition.icon.hasOwnProperty("repeatableArrow") && this.m_featureDefinition.icon.repeatableArrow == "true")
               {
                  if(this.m_featureDefinition.icon.hasOwnProperty("arrowFrequency"))
                  {
                     result = seenCheck > this.m_featureDefinition.icon.arrowFrequency;
                  }
               }
               else if(Boolean(lastSeen) && seenCheck < FarmGameUtil.NUM_SECS_IN_DAY)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      override public function setExtraData(data:Object) : void
      {
         super.setExtraData(data);
         if(data.removeOnClick)
         {
            removeOnClick = data.removeOnClick;
         }
      }
      
      private function conditionallyShowNewArrow() : void
      {
         var experimentCheck:Boolean = false;
         var key:String = null;
         if(this.shouldShowNewArrow())
         {
            experimentCheck = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HUD_FOTW_NEW_ARROW) == Experiments.VARIANT_HUD_FOTW_NEW_ARROW_DAY_ON;
            if(!Global.player.getSeenFlag(this.m_featureName + "_hud_new"))
            {
               Global.player.setSeenFlag(this.m_featureName + "_hud_new");
               if(experimentCheck)
               {
                  Global.player.setFeatureLastShown(this.m_featureName + "_hud_new",GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
               }
            }
            if(this.m_featureDefinition.icon.hasOwnProperty("repeatableArrow") && this.m_featureDefinition.icon.repeatableArrow == "true")
            {
               if(experimentCheck)
               {
                  Global.player.setFeatureLastShown(this.m_featureName + "_hud_new",GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
               }
            }
            key = "FOTW_NEW_ARROW";
            if(this.m_featureDefinition.icon.arrowKey)
            {
               key = this.m_featureDefinition.icon.arrowKey;
            }
            m_arrowText = Global.flashHotParams[key] ? Global.flashHotParams[key] : ZLocUtils.t("Dialogs",key);
            attachArrow(ArrowType.ARROWNEW);
         }
      }
      
      override protected function canShowArrow() : Boolean
      {
         var result:Boolean = false;
         if(!ReturningUserExperienceManager.shouldHideArrowFlyout("cadence"))
         {
            result = super.canShowArrow();
         }
         return result;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
   }
}

