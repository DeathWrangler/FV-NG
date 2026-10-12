package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SubscriptionDailyBenefitsMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_interestedFrame:ZwFrame;
      
      private var m_motdStageNum:Number;
      
      private var m_interestedAmount:Number;
      
      public function SubscriptionDailyBenefitsMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
         if(displayParams["motdStage"])
         {
            this.m_motdStageNum = displayParams["motdStage"];
         }
         if(displayParams["interestedAmount"])
         {
            this.m_interestedAmount = displayParams["interestedAmount"];
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window["mainWindow"])
         {
            if(!SubscriptionsManager.isRevampTrialActive() && Boolean(m_window.mainWindow["title_tf"]))
            {
               (getWidget(m_window.mainWindow["title_tf"]) as FarmTextField).text = ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_STANDARD_Title");
            }
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 2 || Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 3)
            {
               (getWidget(m_window.mainWindow["body_tf"]) as FarmTextField).text = ZLocUtils.t_pk("Dialogs:MOTD_VIP_BENEFITS_2016_variant");
            }
            if(m_window.mainWindow["subtitle_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow["subtitle_tf"],ZLocUtils.t_pk(m_currentMOTD["subtitle"])));
            }
            if(m_window.mainWindow["benefits_mc"])
            {
               (m_window.mainWindow["benefits_mc"] as MovieClip).gotoAndStop(this.m_motdStageNum);
            }
            if(m_window.mainWindow["interested_mc"])
            {
               addWidget(this.m_interestedFrame = new ZwFrame(m_window.mainWindow["interested_mc"]),false);
               if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 1 || Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 3)
               {
                  this.m_interestedFrame.visible = true;
                  this.m_interestedFrame.addWidget(new FarmTextField(m_window.mainWindow.interested_mc["count_tf"],this.m_interestedAmount.toString()));
                  this.m_interestedFrame.addWidget(new FarmTextField(m_window.mainWindow.interested_mc["description_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_BENEFITS_2016_LikeText")));
               }
            }
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 1 || Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 3)
         {
            FarmStatsManager.count("MOTD","impressions","MOTD_subs_trialv2_stage1_" + this.m_motdStageNum + "_a");
         }
         else
         {
            FarmStatsManager.count("MOTD","impressions","MOTD_subs_trialv2_stage1_" + this.m_motdStageNum + "_b");
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.close();
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 1 || Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_INTERESTED_STAT) == 3)
         {
            FarmStatsManager.count("MOTD","click","MOTD_subs_trialv2_stage1_" + this.m_motdStageNum + "_a");
         }
         else
         {
            FarmStatsManager.count("MOTD","click","MOTD_subs_trialv2_stage1_" + this.m_motdStageNum + "_b");
         }
         UI.displayPopup(new SubscriptionAllBenefitsMOTDWindow());
      }
   }
}

