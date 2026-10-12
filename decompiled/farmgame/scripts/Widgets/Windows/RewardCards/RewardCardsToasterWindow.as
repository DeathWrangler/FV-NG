package Widgets.Windows.RewardCards
{
   import Classes.RewardCard;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.RewardCardsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.Event;
   
   public class RewardCardsToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Rewards_Toaster.swf";
      
      private var m_cardType:String;
      
      public function RewardCardsToasterWindow(cardType:String)
      {
         super(ASSET_PATH);
         this.m_cardType = cardType;
      }
      
      override protected function onShow() : void
      {
         RewardCardsManager.getInstance().setShowToaster(true);
         FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"credit_toaster","impressions",this.m_cardType);
         super.onShow();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var cardFrame:ZwFrame = null;
         var owned:int = 0;
         var left:int = 0;
         var leftText:String = null;
         var i:int = 0;
         var stampSlot:ZwBaseWidget = null;
         super.onLoadComplete(event);
         var rewardCardData:RewardCard = RewardCardsManager.getInstance().getRewardCard(this.m_cardType);
         if(rewardCardData != null && m_window.hasOwnProperty(this.m_cardType + "Card_mc"))
         {
            cardFrame = new ZwFrame(m_window[this.m_cardType + "Card_mc"]);
            addWidget(cardFrame);
            owned = rewardCardData.freeCredits + rewardCardData.purchaseCount;
            left = Math.max(0,rewardCardData.credits - owned);
            leftText = ZLocUtils.t("Dialogs","RewardCardsToasterDescription",{"left":left});
            if(m_window[this.m_cardType + "Card_mc"].hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(m_window[this.m_cardType + "Card_mc"].title_tf,ZLocUtils.t("Dialogs","RewardCards_" + this.m_cardType)));
            }
            if(m_window[this.m_cardType + "Card_mc"].hasOwnProperty("body_tf"))
            {
               addWidget(new ZwTextField(m_window[this.m_cardType + "Card_mc"].body_tf,leftText));
            }
            i = 0;
            while(i < owned && m_window[this.m_cardType + "Card_mc"]["slot_" + i + "_mc"] != null)
            {
               stampSlot = new ZwBaseWidget(m_window[this.m_cardType + "Card_mc"]["slot_" + i + "_mc"]);
               cardFrame.addWidget(stampSlot);
               i++;
            }
            if(m_window.hasOwnProperty("blank_bt"))
            {
               if(left > 0)
               {
                  addWidget(new FarmAnimatedTextButton(m_window.blank_bt,"",this.onShopNow));
               }
               else
               {
                  addWidget(new FarmAnimatedTextButton(m_window.blank_bt,"",this.onRedeemNow));
               }
            }
            if(left > 0)
            {
               cardFrame.addWidget(new FarmAnimatedTextButton(m_window[this.m_cardType + "Card_mc"].shopNow_bt,ZLocUtils.t("Dialogs","RewardCardsShopNow"),this.onShopNow));
            }
            else
            {
               cardFrame.addWidget(new FarmAnimatedTextButton(m_window[this.m_cardType + "Card_mc"].shopNow_bt,ZLocUtils.t("Dialogs","RewardCardsRedeemNow"),this.onRedeemNow));
            }
         }
      }
      
      private function onShopNow(event:Event) : void
      {
         FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"credit_toaster","look_now",this.m_cardType);
         var rewardCard:RewardCard = RewardCardsManager.getInstance().getRewardCard(this.m_cardType);
         if(rewardCard != null)
         {
            rewardCard.openMarketForPurchase();
         }
         close();
      }
      
      private function onRedeemNow(event:Event) : void
      {
         var rewardCard:RewardCard = RewardCardsManager.getInstance().getRewardCard(this.m_cardType);
         if(rewardCard != null)
         {
            rewardCard.openMarketForRedeem();
         }
         close();
      }
   }
}

