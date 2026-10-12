package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PurchaseLimitHitFrame extends ZwFrame
   {
      
      private var m_messageTextField:ZwTextField;
      
      private var m_bagsTimeRemaining:ZwTextField;
      
      private var m_uid:String;
      
      private var m_moreBagsFrame:ZwFrame;
      
      public function PurchaseLimitHitFrame(element:MovieClip)
      {
         super(element);
         this.m_messageTextField = new ZwTextField(m_element.shopingLimit_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ShoppingLimit"));
         addWidget(this.m_messageTextField);
         this.m_moreBagsFrame = new ZwFrame(m_element.shoppingLimitCountdown_mc);
         this.m_moreBagsFrame.addWidget(new ZwTextField(m_element.shoppingLimitCountdown_mc.return_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ShoppingLimitCTA")));
         this.m_bagsTimeRemaining = new ZwTextField(m_element.shoppingLimitCountdown_mc.timeLeft_tf,CraftingManager.getInstance().getFriendlyTimeToMoreBags());
         this.m_bagsTimeRemaining.registerEventListener(Event.ENTER_FRAME,this.timeRemainingEventHandler);
         this.m_moreBagsFrame.addWidget(this.m_bagsTimeRemaining);
         addWidget(this.m_moreBagsFrame,true);
      }
      
      private function timeRemainingEventHandler(event:Event) : void
      {
         this.m_bagsTimeRemaining.text = CraftingManager.getInstance().getFriendlyTimeToMoreBags();
      }
      
      public function set message(value:String) : void
      {
         this.m_messageTextField.text = value;
      }
      
      public function refresh() : void
      {
         this.m_bagsTimeRemaining.text = CraftingManager.getInstance().getFriendlyTimeToMoreBags();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_messageTextField = null;
         this.m_bagsTimeRemaining = null;
         this.m_moreBagsFrame = null;
      }
   }
}

