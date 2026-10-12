package Widgets.Windows
{
   import Classes.Constants.OrganicStatsConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.OrganicRewardBadgeFrame;
   import Widgets.Frames.OrganicRewardFrame;
   import flash.events.Event;
   
   public class OrganicCertificationRewardWindow extends FarmWindow
   {
      
      private static const DIALOG_UTIL_PKG:String = "Dialogs";
      
      private static const ORGANIC_TEXT:String = "OrganicCertification";
      
      private static const organicWindowAsset:String = "assets/dialogs/FV_PlanetOrganic_Prize.swf";
      
      private static const TITLE_TEXT_POSTFIX:String = "_TitleText";
      
      private static const SUBTITLE_TEXT_POSTFIX:String = "_SubtitleText";
      
      private static const THIRDTITLE_TEXT_POSTFIX:String = "_ThirdTitleText";
      
      private static const ACCEPTBUTTON_TEXT_POSTFIX:String = "_AcceptButtonText";
      
      private var m_certificationCount:int = 0;
      
      private var m_rewards:Array;
      
      private var m_rewardQuantities:Array;
      
      public function OrganicCertificationRewardWindow(certificationCount:int, rewards:Array, rewardQuantities:Array)
      {
         super(organicWindowAsset);
         this.m_rewards = rewards;
         this.m_rewardQuantities = rewardQuantities;
         this.m_certificationCount = certificationCount;
      }
      
      override protected function postLoadComplete() : void
      {
         var titleKey:String = null;
         var subtitleKey:String = null;
         var thirdTitleKey:String = null;
         var acceptButtonKey:String = null;
         if(m_window["generic_tf"])
         {
            titleKey = ORGANIC_TEXT + TITLE_TEXT_POSTFIX;
            addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG + ":" + titleKey)),true);
         }
         if(m_window["generic2_tf"])
         {
            subtitleKey = ORGANIC_TEXT + SUBTITLE_TEXT_POSTFIX;
            addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG + ":" + subtitleKey)),true);
         }
         if(m_window["generic3_tf"])
         {
            thirdTitleKey = ORGANIC_TEXT + THIRDTITLE_TEXT_POSTFIX;
            addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.t_pk(DIALOG_UTIL_PKG + ":" + thirdTitleKey)),true);
         }
         if(m_window["share_bt"])
         {
            acceptButtonKey = ORGANIC_TEXT + ACCEPTBUTTON_TEXT_POSTFIX;
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t_pk(DIALOG_UTIL_PKG + ":" + acceptButtonKey),this.onAccept),true);
         }
         if(m_window["numberCertified_mc"])
         {
            addWidget(new OrganicRewardBadgeFrame(m_window.numberCertified_mc,this.m_certificationCount),true);
         }
         switch(this.m_rewards.length)
         {
            case 1:
               if(m_window.hasOwnProperty("slotsX1_mc"))
               {
                  addWidget(new ZwFrame(m_window.slotsX1_mc));
                  if(m_window.slotsX1_mc.hasOwnProperty("slot_0_mc"))
                  {
                     addWidget(new OrganicRewardFrame(m_window.slotsX1_mc.slot_0_mc,this.getIconUrl(this.m_rewards[0]),this.m_rewardQuantities[0]));
                  }
               }
               FarmStatsManager.count(OrganicStatsConstants.ORGANIC_CERT,OrganicStatsConstants.ORGANIC_CERT_KINGDOM,OrganicStatsConstants.ORGANIC_CERT_PHYLUM_VIEW);
               break;
            case 3:
               if(m_window.hasOwnProperty("slotsX3_mc"))
               {
                  addWidget(new ZwFrame(m_window.slotsX3_mc));
                  if(m_window.slotsX3_mc.hasOwnProperty("slot_0_mc"))
                  {
                     addWidget(new OrganicRewardFrame(m_window.slotsX3_mc.slot_0_mc,this.getIconUrl(this.m_rewards[0]),this.m_rewardQuantities[0]));
                  }
                  if(m_window.slotsX3_mc.hasOwnProperty("slot_1_mc"))
                  {
                     addWidget(new OrganicRewardFrame(m_window.slotsX3_mc.slot_1_mc,this.getIconUrl(this.m_rewards[1]),this.m_rewardQuantities[1]));
                  }
                  if(m_window.slotsX3_mc.hasOwnProperty("slot_2_mc"))
                  {
                     addWidget(new OrganicRewardFrame(m_window.slotsX3_mc.slot_2_mc,this.getIconUrl(this.m_rewards[2]),this.m_rewardQuantities[2]));
                  }
               }
               FarmStatsManager.count(OrganicStatsConstants.ORGANIC_CERT,OrganicStatsConstants.ORGANIC_CERT_KINGDOM,OrganicStatsConstants.ORGANIC_CERT_PHYLUM_MILESTONE);
         }
      }
      
      private function getIconUrl(itemCode:String) : String
      {
         var itemXml:XML = null;
         var childrenList:XMLList = null;
         var image:XML = null;
         var result:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = Global.farmGameSettingsManager.getFarmItemByCode(itemCode).getImageByName("icon",false);
         }
         else
         {
            itemXml = Global.farmGameSettingsManager.getItemXMLByCode(itemCode);
            childrenList = itemXml.child("image");
            for each(image in childrenList)
            {
               if(image.attribute("name") == "icon")
               {
                  result = image.attribute("url");
                  break;
               }
            }
         }
         return result;
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
         FarmStatsManager.count(OrganicStatsConstants.ORGANIC_CERT,OrganicStatsConstants.ORGANIC_CERT_KINGDOM,OrganicStatsConstants.ORGANIC_CERT_PHYLUM_CLICK);
         Global.player.openOrganicMiniMarket();
      }
      
      override public function close() : void
      {
         FarmStatsManager.count(OrganicStatsConstants.ORGANIC_CERT,OrganicStatsConstants.ORGANIC_CERT_KINGDOM,OrganicStatsConstants.ORGANIC_CERT_PHYLUM_CLOSE);
         super.close();
         if(this.m_certificationCount == 1 || this.m_certificationCount % 10 == 0)
         {
            ToasterManager.getInstance().addImmediate(new OrganicCertificationToasterWindow());
         }
      }
   }
}

