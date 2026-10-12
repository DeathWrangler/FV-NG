package Widgets.Windows.RewardCards
{
   import Classes.RewardCard;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.RewardCardsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RewardCardsCongratulationsWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Rewards_Congrats.swf";
      
      private var m_category:String;
      
      private var m_rewardItemName:String;
      
      private var m_callback:Function;
      
      public function RewardCardsCongratulationsWindow(category:String, callback:Function, rewardItemName:String = null)
      {
         super(ASSET_PATH);
         this.m_rewardItemName = rewardItemName;
         this.m_callback = callback;
         this.m_category = category;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var raysMC:ZwBaseWidget = null;
         var farmItem:FarmItem = null;
         var farmIcon:FarmIcon = null;
         var farmItemName:String = null;
         var categoryPlural:String = null;
         var cardWidget:ZwBaseWidget = null;
         super.onLoadComplete(event);
         var categoryFriendlyName:String = ZLocUtils.t("Dialogs","RewardCards_Type_" + this.m_category);
         addWidget(new ZwTextField(m_window.header_mc,ZLocUtils.t("Dialogs","Congrats")));
         addWidget(new ZwTextField(m_window.line1_tf,ZLocUtils.t("Dialogs","RewardCards_CongratsSubHeader")));
         if(m_window.hasOwnProperty("rays_mc"))
         {
            raysMC = new ZwBaseWidget(m_window.rays_mc);
            (raysMC.element as MovieClip).play();
            addWidget(raysMC);
         }
         if(this.m_rewardItemName != null)
         {
            FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"congratulations","prize","impressions");
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardItemName);
            if(farmItem != null)
            {
               addWidget(new ZwFrame(m_window.item_mc));
               farmIcon = new FarmIcon(m_window.item_mc.icon_mc);
               farmIcon.loadIcon(farmItem.icon);
               addWidget(farmIcon);
               farmIcon.setIconSize(ICON_SIZE,ICON_SIZE);
               if(farmItem != null)
               {
                  farmItemName = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
                  addWidget(new ZwTextField(m_window.line2_tf,farmItemName));
                  categoryPlural = ZLocUtils.t("Dialogs","RewardCards_TypePlural_" + this.m_category);
                  addWidget(new ZwTextField(m_window.line3_tf,ZLocUtils.t("Dialogs","RewardCards_CongratsBody_Item",{
                     "category":categoryFriendlyName,
                     "itemName":categoryFriendlyName,
                     "categoryPlural":categoryPlural
                  })));
               }
               addWidget(new FarmAnimatedTextButton(m_window.generic_bt,ZLocUtils.t("Dialogs","RewardCards_GoToMarket"),this.onGoToMarket));
            }
         }
         else
         {
            FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"congratulations","choice","impressions");
            m_closeButton.visible = false;
            if(m_window.hasOwnProperty(this.m_category + "Card_mc"))
            {
               cardWidget = new ZwBaseWidget(m_window[this.m_category + "Card_mc"]);
               (cardWidget.element as MovieClip).play();
               addWidget(cardWidget);
            }
            addWidget(new ZwTextField(m_window.line2_tf,categoryFriendlyName));
            addWidget(new ZwTextField(m_window.line3_tf,ZLocUtils.t("Dialogs","RewardCards_CongratsBody_NoItem",{
               "category":categoryFriendlyName,
               "category2":categoryFriendlyName
            })));
            addWidget(new FarmAnimatedTextButton(m_window.generic_bt,ZLocUtils.t("Dialogs","RewardCards_FreeItem"),this.onGetFreeItem));
         }
      }
      
      private function onGetFreeItem(event:Event) : void
      {
         FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"congratulations","choice","get_item");
         if(this.m_callback != null)
         {
            this.m_callback();
         }
         close();
      }
      
      private function onGoToMarket(event:Event) : void
      {
         FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"congratulations","prize","go_to_market");
         var rewardCard:RewardCard = RewardCardsManager.getInstance().getRewardCard(this.m_category);
         if(rewardCard)
         {
            rewardCard.openMarketForPurchase();
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"congratulations","prize","close");
         super.onClose(event);
      }
   }
}

