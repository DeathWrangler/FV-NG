package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Market.MarketWindow;
   import flash.events.Event;
   
   public class RewardCardsMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Rewards_MOTD.swf";
      
      public function RewardCardsMOTDWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         addWidget(new ZwFrame(m_window.zCache_mc));
         addWidget(new ZwTextField(m_window.zCache_mc.body_tf,ZLocUtils.t("Dialogs","RewardCards_MOTDText")));
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","RewardCardsStartNow"),this.onClickAccept));
         if(m_closeButton != null)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function onClickAccept(event:Event) : void
      {
         if(m_acceptCallback != null)
         {
            m_acceptCallback.call();
         }
         UI.displayMarketDialog("unknown","seed",null,"all",null,null,null,null,-1,null,MarketWindow.REWARDS_CARDS_ITEM);
         super.onClose(event);
      }
   }
}

