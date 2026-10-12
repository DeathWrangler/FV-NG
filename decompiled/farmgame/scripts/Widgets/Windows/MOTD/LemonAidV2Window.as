package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedAdjustableCashButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class LemonAidV2Window extends SocialCharityWindow
   {
      
      protected static const REWARD_SLOT:String = "slot_3_mc";
      
      private var m_mainExperiment:String;
      
      private var m_progressBarExperiment:String;
      
      private var m_showProgressBar:Boolean;
      
      private var m_showEveryMotherCountsDetails:Boolean;
      
      private var m_showSaveTheChildrenDetails:Boolean;
      
      private var m_shouldAddDialogSuffix:Boolean;
      
      public function LemonAidV2Window(buildingName:String = "", source:String = "feed")
      {
         var assets:Dictionary = null;
         var assetXML:XML = null;
         var campaignConfig:XML = SocialCharityWindow.getCampaignConfigFromBuildingName(SocialCharityWindow.FEATURE_NAME,buildingName);
         var dialogPrefix:String = "";
         var dialogSuffix:String = "";
         if(campaignConfig)
         {
            this.m_mainExperiment = campaignConfig.@experiment;
            this.m_progressBarExperiment = campaignConfig.@progressBarExperiment;
            dialogPrefix = campaignConfig.@dialogPrefix;
            dialogSuffix = campaignConfig.@dialogSuffix;
            this.loadLemonAidV2ExperimentVariantsAndFlags();
            assets = new Dictionary();
            for each(assetXML in campaignConfig.assetConfig.asset)
            {
               assets[String(assetXML.@name)] = String(assetXML.@path);
            }
         }
         var overrideDialogPrefix:String = this.m_shouldAddDialogSuffix ? dialogPrefix + dialogSuffix : dialogPrefix;
         var overrideAssetName:String = this.m_showProgressBar ? assets["mainWindowA"] : assets["mainWindowB"];
         super(buildingName,source,overrideAssetName,overrideDialogPrefix);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.getZLocString("Dialogs",m_dialogPrefix,DEFAULT_PREFIX,"window_title")));
         }
         if(m_window.hasOwnProperty("logo_1_mc") && this.m_showEveryMotherCountsDetails)
         {
            addWidget(new ZwWidget(m_window.logo_1_mc));
         }
         if(m_window.hasOwnProperty("logo_2_mc") && this.m_showSaveTheChildrenDetails)
         {
            addWidget(new ZwWidget(m_window.logo_2_mc));
         }
      }
      
      private function loadLemonAidV2ExperimentVariantsAndFlags() : void
      {
         var mainWindowVariant:int = Global.experimentManager.getExperimentVariant(this.m_mainExperiment);
         switch(mainWindowVariant)
         {
            case 2:
               this.m_showEveryMotherCountsDetails = false;
               this.m_showSaveTheChildrenDetails = true;
               break;
            case 3:
               this.m_showEveryMotherCountsDetails = true;
               this.m_showSaveTheChildrenDetails = false;
               this.m_shouldAddDialogSuffix = true;
               break;
            default:
               this.m_showEveryMotherCountsDetails = false;
               this.m_showSaveTheChildrenDetails = false;
         }
         var progressBarVariant:int = Global.experimentManager.getExperimentVariant(this.m_progressBarExperiment);
         switch(progressBarVariant)
         {
            case 1:
               this.m_showProgressBar = false;
               break;
            case 2:
            case 3:
               this.m_showProgressBar = true;
               break;
            default:
               this.m_showProgressBar = false;
         }
      }
      
      override protected function addRewardItemWithoutProgressBar() : void
      {
         var frame:ZwFrame = null;
         if(!this.m_showProgressBar)
         {
            if(m_window[REWARD_SLOT] != null)
            {
               frame = new ZwFrame(m_window[REWARD_SLOT]);
               this.addRewardElement(frame);
               addWidget(frame);
            }
         }
      }
      
      private function addRewardElement(frame:ZwFrame) : void
      {
         var item:FarmItem = null;
         var slotIcon:ObjectPreviewFrame = null;
         var contributeFrame:FarmAnimatedAdjustableCashButton = null;
         var buyButton:FarmAnimatedCashButton = null;
         if(frame.element.icon_mc != null)
         {
            item = m_reward.item;
            slotIcon = new ObjectPreviewFrame(frame.element.icon_mc,item,null,null,[100]);
            frame.addWidget(slotIcon);
         }
         if(Boolean(m_redeemButton && !m_redeemButton.visible && m_reward.checkVariablePricing) && Boolean(frame.element.hasOwnProperty("contribute_mc")) && m_showFlexibleContributionButton)
         {
            contributeFrame = new FarmAnimatedAdjustableCashButton(frame.element.contribute_mc,m_adjustedPricing[m_reward.item.name].anchorPrice,2,ZLocUtils.getZLocString("Dialogs",m_dialogPrefix,DEFAULT_PREFIX,"donateButton"),m_adjustedPricing[m_reward.item.name].displayedPrice,getBuyCallback(m_reward.item,m_reward.checkVariablePricing));
            m_buyButtons[m_reward.item.name] = contributeFrame;
            frame.addWidget(contributeFrame);
         }
         else if(Boolean(m_redeemButton) && Boolean(!m_redeemButton.visible) && frame.element.hasOwnProperty("buy_bt"))
         {
            buyButton = new FarmAnimatedCashButton(frame.element.buy_bt,ZLocUtils.getZLocString("Dialogs",m_dialogPrefix,DEFAULT_PREFIX,"donateButton"),m_reward.price.toString(),getBuyCallback(m_reward.item,m_reward.checkVariablePricing));
            m_buyButtons[m_reward.item.name] = buyButton;
            frame.addWidget(buyButton);
         }
      }
      
      override protected function addIntro() : void
      {
         var introString:String = this.getTutorialToShow();
         if(m_window[introString] != null)
         {
            m_introFrame = new ZwFrame(m_window[introString]);
            if(m_introFrame.element.accept_bt != null)
            {
               m_introFrame.addWidget(new FarmAnimatedTextButton(m_introFrame.element.accept_bt,ZLocUtils.getZLocString("Dialogs",m_dialogPrefix,DEFAULT_PREFIX,"intro_accept"),onHideIntroClick));
            }
            addWidget(m_introFrame);
            m_introFrame.visible = false;
            if(!Global.player.getSeenFlag(m_tutorialSeenFlag))
            {
               showIntroClip();
            }
         }
      }
      
      private function getTutorialToShow() : String
      {
         var widgetToShow:String = "";
         if(!this.m_showProgressBar && !m_showFlexibleContributionButton)
         {
            widgetToShow = "intro_4_mc";
         }
         if(!this.m_showProgressBar && m_showFlexibleContributionButton)
         {
            widgetToShow = "intro_3_mc";
         }
         if(this.m_showProgressBar && !m_showFlexibleContributionButton)
         {
            widgetToShow = "intro_2_mc";
         }
         if(this.m_showProgressBar && m_showFlexibleContributionButton)
         {
            widgetToShow = "intro_1_mc";
         }
         return widgetToShow;
      }
   }
}

