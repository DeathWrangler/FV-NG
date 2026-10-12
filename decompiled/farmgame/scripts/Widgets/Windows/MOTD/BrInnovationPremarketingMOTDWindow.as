package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import flash.events.MouseEvent;
   
   public class BrInnovationPremarketingMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      public static const SERVICE_CLASS:String = "WinterPremarketingService";
      
      public static const SEEN_FLAG:String = "BRInnovationMarketingRewardGrantFlag";
      
      private static var CUSTOM_ACTION_TYPE:String = "customActionType";
      
      private static const ITEM1_NAME:String = "pkg_unwither_1";
      
      private static const ITEM1_INDEX:int = 0;
      
      private static const ITEM1_QTY:int = 1;
      
      private static const ITEM2_NAME:String = "pkg_instagrow_1pack";
      
      private static const ITEM2_INDEX:int = 1;
      
      private static const ITEM2_QTY:int = 1;
      
      private static const ITEM3_NAME:String = "consume_turbo_charger";
      
      private static const ITEM3_INDEX:int = 2;
      
      private static const ITEM3_QTY:int = 1;
      
      private static const ITEM4_NAME:String = "consume_organic_fertilizer";
      
      private static const ITEM4_INDEX:int = 3;
      
      private static const ITEM4_QTY:int = 1;
      
      protected var m_select0Mc:ZwWidget;
      
      protected var m_select1Mc:ZwWidget;
      
      protected var m_select2Mc:ZwWidget;
      
      protected var m_select3Mc:ZwWidget;
      
      private var m_closeBt:FarmButton;
      
      private var m_giftName:String = "";
      
      private var m_seenFlag:String = "";
      
      private var m_configs:Object;
      
      public function BrInnovationPremarketingMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      private function setParams() : void
      {
         var actionParams:Object = null;
         if(m_currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS))
         {
            actionParams = m_currentMOTD[CUSTOM_ACTION_PARAMS];
            if(Boolean(actionParams) && actionParams.hasOwnProperty(CUSTOM_ACTION_TYPE))
            {
               this.m_seenFlag = actionParams[CUSTOM_ACTION_TYPE];
            }
            if(Boolean(actionParams) && actionParams.hasOwnProperty("featureName"))
            {
               this.m_giftName = actionParams["featureName"];
            }
         }
         this.m_configs = new Object();
         this.m_configs["WinterPremarketingGrantFlag1"] = new Object();
         this.m_configs["WinterPremarketingGrantFlag2"] = new Object();
         this.m_configs["WinterPremarketingGrantFlag3"] = new Object();
         this.m_configs["WinterPremarketingGrantFlag1"]["names"] = new Array("Mystical Egg Tree","White Tiger Tree","Aurora Ice Tree","Magic Twirl Tree");
         this.m_configs["WinterPremarketingGrantFlag1"]["answer"] = 2;
         this.m_configs["WinterPremarketingGrantFlag2"]["names"] = new Array("18","21","20","24");
         this.m_configs["WinterPremarketingGrantFlag2"]["answer"] = 2;
         this.m_configs["WinterPremarketingGrantFlag3"]["names"] = new Array("Super Skier Duck","Caroling Rooster","Blue Mitt Penguin");
         this.m_configs["WinterPremarketingGrantFlag3"]["answer"] = 1;
      }
      
      override protected function postLoadComplete() : void
      {
         this.setParams();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
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
            if(m_window.mainWindow.animation_mc["select3_mc"])
            {
               this.m_select3Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select3_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select0_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select0_bt"],this.m_configs[this.m_seenFlag]["names"][0],this.onStone0ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select1_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select1_bt"],this.m_configs[this.m_seenFlag]["names"][1],this.onStone1ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select2_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select2_bt"],this.m_configs[this.m_seenFlag]["names"][2],this.onStone2ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select3_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select3_bt"],this.m_configs[this.m_seenFlag]["names"][3],this.onStone3ButtonClick)) as FarmAnimatedTextButton;
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
      
      private function checkAnswer(answer:int) : void
      {
         if(this.m_configs[this.m_seenFlag]["answer"] == answer)
         {
            this.m_select0Mc.visible = true;
            this.grantReward();
         }
         else
         {
            this.m_select1Mc.visible = true;
         }
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.m_closeBt.visible = true;
      }
      
      protected function onStone0ButtonClick(event:MouseEvent) : void
      {
         this.checkAnswer(0);
      }
      
      protected function onStone1ButtonClick(event:MouseEvent) : void
      {
         this.checkAnswer(1);
      }
      
      protected function onStone2ButtonClick(event:MouseEvent) : void
      {
         this.checkAnswer(2);
      }
      
      protected function onStone3ButtonClick(event:MouseEvent) : void
      {
         this.checkAnswer(3);
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(this.m_seenFlag);
         }
      }
      
      private function grantReward() : void
      {
         if(!Global.player.getSeenFlag(this.m_seenFlag))
         {
            Global.player.addGift(this.m_giftName,"0",1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward1",this.onGrantReward,[this.m_seenFlag]));
         }
      }
   }
}

