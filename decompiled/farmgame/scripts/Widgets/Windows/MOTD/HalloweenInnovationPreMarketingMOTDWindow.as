package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenInnovationPreMarketingMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public static const SERVICE_CLASS:String = "GrantRewardService";
      
      public static const SEEN_FLAG:String = "HalloweenInnovationMarketingRewardGrantFlag";
      
      private static const ITEM1_NAME:String = "xtr_spookybraintree";
      
      private static const ITEM1_INDEX:int = 0;
      
      private static const ITEM1_QTY:int = 1;
      
      private static const ITEM2_NAME:String = "xtr_floatinglanternwraith";
      
      private static const ITEM2_INDEX:int = 1;
      
      private static const ITEM2_QTY:int = 1;
      
      private static const ITEM3_NAME:String = "duck_xtr_devil";
      
      private static const ITEM3_INDEX:int = 2;
      
      private static const ITEM3_QTY:int = 1;
      
      private static const ITEM4_NAME:String = "xtr_lonelymanor";
      
      private static const ITEM4_INDEX:int = 3;
      
      private static const ITEM4_QTY:int = 1;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_titleTf:ZwTextField;
      
      private var m_itemName:String;
      
      private var m_bundleName:String;
      
      private var m_rewardsMc:MovieClip;
      
      private var m_slots:MovieClip;
      
      protected var m_select0Mc:ZwWidget;
      
      protected var m_select1Mc:ZwWidget;
      
      protected var m_select2Mc:ZwWidget;
      
      protected var m_select3Mc:ZwWidget;
      
      private var m_closeBt:FarmButton;
      
      private var m_rewardItem:String;
      
      private var m_itemIndex:int;
      
      public function HalloweenInnovationPreMarketingMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
            }
            if(m_window.mainWindow.hasOwnProperty(this.TITLE_TF))
            {
               this.m_titleTf = addWidget(new ZwTextField(m_window.mainWindow[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HalloweenusaPremarketingMOTD_txt")),true) as ZwTextField;
            }
            if(m_window.mainWindow.animation_mc["slots_mc"])
            {
               this.m_slots = m_window.mainWindow.animation_mc["slots_mc"] as MovieClip;
               this.m_slots.visible = false;
            }
            if(m_window.mainWindow.animation_mc["rewards_mc"])
            {
               this.m_rewardsMc = m_window.mainWindow.animation_mc["rewards_mc"] as MovieClip;
               this.m_rewardsMc.visible = true;
            }
            if(m_window.mainWindow.animation_mc.rewards_mc["play0_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.rewards_mc["play0_bt"],"Select",this.onPlay0ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.rewards_mc["play1_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.rewards_mc["play1_bt"],"Select",this.onPlay1ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.rewards_mc["play2_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.rewards_mc["play2_bt"],"Select",this.onPlay2ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.rewards_mc["play3_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.rewards_mc["play3_bt"],"Select",this.onPlay3ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc["select0_mc"])
            {
               this.m_select0Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select0_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select1_mc"])
            {
               this.m_select1Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select1_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select2_mc"])
            {
               this.m_select2Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select2_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select3_mc"])
            {
               this.m_select3Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select3_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select0_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select0_bt"],"Rock",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select1_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select1_bt"],"Paper",this.onStone1ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select2_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select2_bt"],"Scissors",this.onStone2ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc["close_bt"])
            {
               this.m_closeBt = addWidget(new FarmButton(m_window.mainWindow.animation_mc["close_bt"],onClose)) as FarmButton;
            }
            if(m_window.mainWindow["accept_bt"])
            {
               this.m_closeBt = addWidget(new FarmAnimatedButton(m_window.mainWindow["accept_bt"],onClose),false) as FarmButton;
            }
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
         }
      }
      
      protected function onPlay0ButtonClick(event:MouseEvent) : void
      {
         this.m_slots.visible = true;
         this.m_rewardsMc.visible = false;
         this.m_rewardItem = ITEM1_NAME;
         this.m_itemIndex = ITEM1_INDEX;
      }
      
      protected function onPlay1ButtonClick(event:MouseEvent) : void
      {
         this.m_slots.visible = true;
         this.m_rewardsMc.visible = false;
         this.m_rewardItem = ITEM2_NAME;
         this.m_itemIndex = ITEM2_INDEX;
      }
      
      protected function onPlay2ButtonClick(event:MouseEvent) : void
      {
         this.m_slots.visible = true;
         this.m_rewardsMc.visible = false;
         this.m_rewardItem = ITEM3_NAME;
         this.m_itemIndex = ITEM3_INDEX;
      }
      
      protected function onPlay3ButtonClick(event:MouseEvent) : void
      {
         this.m_slots.visible = true;
         this.m_rewardsMc.visible = false;
         this.m_rewardItem = ITEM4_NAME;
         this.m_itemIndex = ITEM4_INDEX;
      }
      
      protected function onStone0ButtonClick(event:MouseEvent) : void
      {
         this.m_select0Mc.visible = true;
         this.updatePrizeItemImage(this.m_itemIndex);
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(this.m_rewardItem,ITEM1_QTY,this.m_itemIndex);
         this.m_closeBt.visible = true;
      }
      
      protected function onStone1ButtonClick(event:MouseEvent) : void
      {
         this.m_select1Mc.visible = true;
         this.updatePrizeItemImage(this.m_itemIndex);
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(this.m_rewardItem,ITEM2_QTY,this.m_itemIndex);
         this.m_closeBt.visible = true;
      }
      
      protected function onStone2ButtonClick(event:MouseEvent) : void
      {
         this.m_select2Mc.visible = true;
         this.updatePrizeItemImage(this.m_itemIndex);
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(this.m_rewardItem,ITEM3_QTY,this.m_itemIndex);
         this.m_closeBt.visible = true;
      }
      
      private function updatePrizeItemImage(frameIndex:int) : void
      {
         if(m_window.mainWindow.animation_mc["prize_mc"])
         {
            m_window.mainWindow.animation_mc.prize_mc.gotoAndStop(frameIndex + 1);
         }
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
      
      private function grantReward(itemName:String, quantity:int, itemIndex:int) : void
      {
         if(!Global.player.getSeenFlag(SEEN_FLAG))
         {
            Global.player.addGift(itemName,"0",quantity);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantHalloweenPremarketingReward",this.onGrantReward,[itemIndex]));
         }
      }
   }
}

