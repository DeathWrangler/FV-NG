package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class FarmRun2018PremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public static const SERVICE_CLASS:String = "FarmRun2018PremarketingService";
      
      public static const SEEN_FLAG:String = "FarmRun2018PremarketingGrantFlag";
      
      private static const FARMRUN2018_PREMARKETING_SEEN_FLAG:String = "FarmRunV10_2020_marketing_seen";
      
      private static const ITEM1_NAME:String = "pkg_instagrow_1pack";
      
      private static const ITEM1_INDEX:int = 0;
      
      private static const ITEM1_QTY:int = 1;
      
      private static const ITEM2_NAME:String = "consume_organic_fertilizer";
      
      private static const ITEM2_INDEX:int = 1;
      
      private static const ITEM2_QTY:int = 1;
      
      private static const ITEM3_NAME:String = "pkg_unwither_1";
      
      private static const ITEM3_INDEX:int = 2;
      
      private static const ITEM3_QTY:int = 1;
      
      private static const ITEM4_NAME:String = "consume_turbo_charger";
      
      private static const ITEM4_INDEX:int = 3;
      
      private static const ITEM4_QTY:int = 1;
      
      private var m_itemName:String;
      
      private var m_bundleName:String;
      
      protected var m_title_tf:ZwTextField;
      
      protected var m_text0_tf:ZwTextField;
      
      protected var m_text1_tf:ZwTextField;
      
      protected var m_text2_tf:ZwTextField;
      
      protected var m_text3_tf:ZwTextField;
      
      protected var m_text4_tf:ZwTextField;
      
      protected var m_select0Mc:ZwWidget;
      
      protected var m_select1Mc:ZwWidget;
      
      protected var m_select2Mc:ZwWidget;
      
      protected var m_select3Mc:ZwWidget;
      
      private var m_closeBt:FarmButton;
      
      protected var m_select4Mc:ZwWidget;
      
      public function FarmRun2018PremarketingWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
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
            if(m_window.mainWindow.animation_mc.slots_mc["select0_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select0_bt"],"Select",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select1_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select1_bt"],"Select",this.onStone1ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select2_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select2_bt"],"Select",this.onStone2ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc["close_bt"])
            {
               this.m_closeBt = addWidget(new FarmButton(m_window.mainWindow.animation_mc["close_bt"],onClose)) as FarmButton;
            }
            if(m_window.mainWindow["close_bt"])
            {
               this.m_closeBt = addWidget(new FarmButton(m_window.mainWindow["close_bt"],onClose)) as FarmButton;
            }
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Claim",this.onAccept)) as FarmAnimatedTextButton;
            }
            m_accept_bt.visible = false;
            m_window.gotoAndPlay(1);
         }
      }
      
      protected function onStone0ButtonClick(event:MouseEvent) : void
      {
         this.m_select0Mc.visible = true;
         m_window.gotoAndPlay(2);
         if(m_animationMc)
         {
            m_animationMc.element.gotoAndPlay(2);
         }
         var result:Boolean = this.grantReward(ITEM1_NAME,ITEM1_QTY,ITEM1_INDEX);
         if(result == false)
         {
            this.closeWindow(event);
         }
      }
      
      protected function onStone1ButtonClick(event:MouseEvent) : void
      {
         this.m_select1Mc.visible = true;
         m_window.gotoAndPlay(2);
         if(m_animationMc)
         {
            m_animationMc.element.gotoAndPlay(2);
         }
         var result:Boolean = this.grantReward(ITEM2_NAME,ITEM2_QTY,ITEM2_INDEX);
         if(result == false)
         {
            this.closeWindow(event);
         }
      }
      
      protected function onStone2ButtonClick(event:MouseEvent) : void
      {
         this.m_select2Mc.visible = true;
         if(m_animationMc)
         {
            m_animationMc.element.gotoAndPlay(2);
         }
         var result:Boolean = this.grantReward(ITEM4_NAME,ITEM4_QTY,ITEM4_INDEX);
         if(result == false)
         {
            this.closeWindow(event);
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         var currFrame:int = 0;
         if(Global.player.getSeenFlag(FARMRUN2018_PREMARKETING_SEEN_FLAG))
         {
            super.onClose(event);
         }
         else
         {
            currFrame = 50;
            m_animationMc.element.gotoAndPlay(currFrame + 1);
            this.m_select0Mc.visible = false;
            this.m_select1Mc.visible = false;
            this.m_select2Mc.visible = false;
            m_accept_bt.text = "Awesome";
            Global.player.setSeenFlag(FARMRUN2018_PREMARKETING_SEEN_FLAG);
         }
      }
      
      private function closeWindow(event:MouseEvent) : void
      {
         super.onClose(event);
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
      
      private function grantReward(itemName:String, quantity:int, itemIndex:int) : Boolean
      {
         var result:Boolean = false;
         if(!Global.player.getSeenFlag(SEEN_FLAG))
         {
            Global.player.addGift(itemName,"0",quantity);
            if(itemIndex == 1)
            {
               Global.player.addGift(ITEM3_NAME,"0",ITEM3_QTY);
            }
            m_accept_bt.visible = true;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward,[itemIndex]));
            result = true;
         }
         return result;
      }
   }
}

