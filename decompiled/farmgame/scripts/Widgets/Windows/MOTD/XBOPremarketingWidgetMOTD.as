package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.ExpansionAccess;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.XBOPremarketingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   import flash.events.Event;
   
   public class XBOPremarketingWidgetMOTD extends ExpansionOnboardingWindow
   {
      
      private var m_rewardFrame:ZwFrame;
      
      private var m_chestMC:ZwWidget;
      
      protected var m_keyMC:ZwWidget;
      
      private var m_discountOnly_mc:ZwWidget;
      
      private var m_decoMC:ZwWidget;
      
      private var m_discount_mc:ZwWidget;
      
      private const STATS_COUNTER_EA:String = "EAPremarketingMOTD";
      
      private const STATS_COUNTER_GA:String = "GAPremarketingMOTD";
      
      private const STATS_COUNTER_CLOSE:String = "close";
      
      private const STATS_COUNTER_BUY_AND_GO:String = "buy_and_go";
      
      private const TITLE_SUFFIX:String = "_title";
      
      private const PRE_EXPANSION_DESCRIPTION_SUFFIX:String = "_pre_expansion_MOTD_desc";
      
      private const KEY_TEXT_SUFFIX:String = "_key_text";
      
      public function XBOPremarketingWidgetMOTD(assetPath:String, acceptText:String = "", acceptCallback:Function = null, cancelCallback:Function = null, accessConfig:ExpansionAccess = null, worldId:String = null, ftueCallback:Function = null, featureName:String = null)
      {
         super(assetPath,acceptText,acceptCallback,cancelCallback,accessConfig,worldId,ftueCallback,featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         var title:String = null;
         if(m_window)
         {
            if(m_window.rewards_mc)
            {
               addWidget(this.m_rewardFrame = new ZwFrame(m_window.rewards_mc));
               title = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_title");
               if(this.m_rewardFrame.element.title_tf)
               {
                  addWidget(new ZwTextField(this.m_rewardFrame.element.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + this.TITLE_SUFFIX)));
               }
               if(this.m_rewardFrame.element.description_tf)
               {
                  addWidget(new ZwTextField(this.m_rewardFrame.element.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + this.PRE_EXPANSION_DESCRIPTION_SUFFIX)));
               }
               if(this.m_rewardFrame.element.chestReward_mc)
               {
                  addWidget(this.m_chestMC = new ZwWidget(this.m_rewardFrame.element["chestReward_mc"]),false);
               }
               if(this.m_rewardFrame.element.ok_bt)
               {
                  addWidget(new FarmAnimatedTextButton(this.m_rewardFrame.element.ok_bt,m_acceptText,this.onOkBtnClick),true);
               }
               if(this.m_rewardFrame.element.close_bt)
               {
                  addWidget(new FarmButton(m_window.rewards_mc.close_bt,this.cancelPrompt)) as FarmButton;
               }
               if(this.m_rewardFrame.element.key_mc)
               {
                  addWidget(this.m_keyMC = new ZwWidget(this.m_rewardFrame.element.key_mc));
                  addWidget(new ZwTextField(this.m_keyMC.element["key_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + this.KEY_TEXT_SUFFIX)));
               }
               if(this.m_rewardFrame.element.discountOnly_mc)
               {
                  addWidget(this.m_discountOnly_mc = new ZwWidget(this.m_rewardFrame.element.discountOnly_mc),false);
               }
               if(this.m_rewardFrame.element.deco_mc)
               {
                  addWidget(this.m_decoMC = new ZwWidget(this.m_rewardFrame.element.deco_mc),false);
               }
               if(this.m_rewardFrame.element.discount_mc)
               {
                  addWidget(this.m_discount_mc = new ZwWidget(this.m_rewardFrame.element.discount_mc),false);
               }
               if(this.manager.isEAAvailable)
               {
                  this.displayEarlyAccessSpecificObject();
               }
               else
               {
                  this.displayGeneralAccessSpecificObject();
               }
            }
         }
      }
      
      override protected function cancelPrompt(event:Event) : void
      {
         super.cancelPrompt(event);
         if(this.manager.isEAAvailable)
         {
            FarmStatsManager.count(m_featureName,this.STATS_COUNTER_EA,this.STATS_COUNTER_CLOSE);
         }
         else
         {
            FarmStatsManager.count(m_featureName,this.STATS_COUNTER_GA,this.STATS_COUNTER_CLOSE);
         }
      }
      
      private function onOkBtnClick(event:Object) : void
      {
         this.close();
         Global.hud.travelNameDisplay.showNewTravelWindow();
         if(this.manager.isEAAvailable)
         {
            FarmStatsManager.count(m_featureName,this.STATS_COUNTER_EA,this.STATS_COUNTER_BUY_AND_GO);
         }
         else
         {
            FarmStatsManager.count(m_featureName,this.STATS_COUNTER_GA,this.STATS_COUNTER_BUY_AND_GO);
         }
      }
      
      private function displayEarlyAccessSpecificObject() : void
      {
         switch(this.manager.currentMilestone)
         {
            case 0:
               this.m_discountOnly_mc.visible = true;
               this.m_keyMC.visible = false;
               break;
            case this.manager.maxMilestone:
               this.m_decoMC.visible = true;
               this.m_discount_mc.visible = true;
               this.setChestSize();
               break;
            default:
               this.m_discount_mc.visible = true;
               this.displayRewardIcons();
               this.setChestSize();
         }
      }
      
      private function displayGeneralAccessSpecificObject() : void
      {
         switch(this.manager.currentMilestone)
         {
            case 0:
               m_cancelCallback();
               this.m_keyMC.visible = false;
               return;
            case this.manager.maxMilestone:
               this.m_decoMC.visible = true;
               this.setChestSize();
               break;
            default:
               this.displayRewardIcons();
               this.setChestSize();
         }
      }
      
      private function displayRewardIcons() : void
      {
         for(var i:int = 0; i < this.manager.currentMilestone; i++)
         {
            m_window.rewards_mc["icon_" + i + "_mc"].visible = true;
         }
      }
      
      private function setChestSize() : void
      {
         if(this.m_chestMC)
         {
            if(this.m_chestMC.element.chestReward_mc)
            {
               this.m_chestMC.visible = true;
               this.m_chestMC.element.chestReward_mc.gotoAndStop(this.manager.currentMilestone + 1);
            }
         }
      }
      
      private function get manager() : XBOPremarketingManager
      {
         return XBOPremarketingManager.instance(m_featureName);
      }
   }
}

