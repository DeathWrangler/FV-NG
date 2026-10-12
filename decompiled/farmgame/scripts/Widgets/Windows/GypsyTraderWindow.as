package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.GypsyTrader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.BringBackWinterManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GypsyTraderSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Slots.GypsyTraderPlantSlot;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GypsyTraderWindow extends BBWinterReskinnableWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private const BODY_TF:String = "copy_tf";
      
      private const NPC_MC:String = "npc_mc";
      
      private const SLOT_MC:String = "slots_mc";
      
      private const CRAFT_MC:String = "craft_mc";
      
      private const TIMELEFT_MC:String = "timeleft_mc";
      
      private const TIME_TF:String = "time_tf";
      
      private const LEFT_TF:String = "left_tf";
      
      private const ITEM1_MC:String = "item_0_mc";
      
      private const ITEM2_MC:String = "item_1_mc";
      
      private const ITEM3_MC:String = "item_2_mc";
      
      private var timeleft_frame:ZwFrame;
      
      private var time_tf:FarmTextField;
      
      private var m_prizeFrame:ZwFrame;
      
      private var m_bonusIcon:ObjectPreviewFrame;
      
      private var m_prizeNameTextField:ZwTextField;
      
      private var m_checkMark:ZwWidget;
      
      protected var m_plantFrame:ZwFrame;
      
      private var slotItems:Array;
      
      public function GypsyTraderWindow(windowURL:String, params:XML, featureName:String = "")
      {
         if(params)
         {
            m_featureName = params.featureName;
         }
         else
         {
            m_featureName = featureName;
         }
         super(m_featureName);
      }
      
      override protected function getNumTutorialScenes() : int
      {
         return NUM_TUTORIAL_SCENES;
      }
      
      override protected function postLoadComplete() : void
      {
         var timeleft_mc:MovieClip = null;
         super.postLoadComplete();
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.bonusItemName);
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            if(this.manager.isFeatureEnd())
            {
               addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_ExpiredBody")),true);
            }
            else
            {
               addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_body")),true);
            }
         }
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            m_window[this.NPC_MC].visible = true;
         }
         if(m_window.hasOwnProperty(this.TIMELEFT_MC))
         {
            timeleft_mc = m_window[this.TIMELEFT_MC] as MovieClip;
            addWidget(this.timeleft_frame = new ZwFrame(timeleft_mc),true);
            if(timeleft_mc.hasOwnProperty(this.TIME_TF))
            {
               this.timeleft_frame.addWidget(this.time_tf = new FarmTextField(timeleft_mc[this.TIME_TF]),true);
               this.updateText();
            }
            if(timeleft_mc.hasOwnProperty(this.LEFT_TF))
            {
               if(this.manager.isFeatureEnd())
               {
                  this.timeleft_frame.addWidget(new ZwTextField(timeleft_mc[this.LEFT_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_ExpiredTimeLeftText")),true);
               }
               else
               {
                  this.timeleft_frame.addWidget(new ZwTextField(timeleft_mc[this.LEFT_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_timeLeftText")),true);
               }
            }
         }
         if(m_window.hasOwnProperty(this.SLOT_MC))
         {
            addWidget(m_slotsFrame = new GypsyTraderSlotFrame(m_window[this.SLOT_MC],m_featureName,this)) as GypsyTraderSlotFrame;
         }
         addWidget(this.m_prizeFrame = new ZwFrame(m_window.prize_mc));
         this.m_prizeFrame.addWidget(this.m_prizeNameTextField = new ZwTextField(m_window.prize_mc.name_tf,ZLocUtils.tk_pk_asTitle(prizeItem.friendlyName)));
         this.m_prizeFrame.addWidget(this.m_bonusIcon = new ObjectPreviewFrame(m_window.prize_mc.icon_mc_1,prizeItem,null,[prizeItem.sizeX == 1 ? 2 : 1.75]));
         if(m_window.prize_mc.hasOwnProperty("checkmark_mc"))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_window.prize_mc.checkmark_mc),false);
         }
      }
      
      override protected function setUpSFBuyWindow() : void
      {
         var collectionSlot:GypsyTraderPlantSlot = null;
         if(m_window.hasOwnProperty(this.CRAFT_MC))
         {
            addWidget(this.m_plantFrame = new ZwFrame(m_window[this.CRAFT_MC]));
            if(this.m_plantFrame.element.hasOwnProperty(this.ITEM1_MC))
            {
               collectionSlot = new GypsyTraderPlantSlot(this.m_plantFrame.element[this.ITEM1_MC],m_featureName,BringBackWinterManager.INDEX_PINK_COUNT,this);
               this.m_plantFrame.addWidget(collectionSlot,true);
               m_collectionSlots.push(collectionSlot);
            }
            if(this.m_plantFrame.element.hasOwnProperty(this.ITEM2_MC))
            {
               collectionSlot = new GypsyTraderPlantSlot(this.m_plantFrame.element[this.ITEM2_MC],m_featureName,BringBackWinterManager.INDEX_BLUE_COUNT,this);
               this.m_plantFrame.addWidget(collectionSlot,true);
               m_collectionSlots.push(collectionSlot);
            }
            if(this.m_plantFrame.element.hasOwnProperty(this.ITEM3_MC))
            {
               collectionSlot = new GypsyTraderPlantSlot(this.m_plantFrame.element[this.ITEM3_MC],m_featureName,BringBackWinterManager.INDEX_GREEN_COUNT,this);
               this.m_plantFrame.addWidget(collectionSlot,true);
               m_collectionSlots.push(collectionSlot);
            }
         }
      }
      
      override public function update() : void
      {
         super.update();
         this.updateText();
      }
      
      override public function refreshWindow() : void
      {
         this.update();
      }
      
      override protected function updateSfCollection() : void
      {
         var i:int = 0;
         var collectionSlot:GypsyTraderPlantSlot = null;
         if(m_collectionSlots)
         {
            for(i = 0; i < m_collectionSlots.length; i++)
            {
               if(m_collectionSlots[i])
               {
                  collectionSlot = m_collectionSlots[i] as GypsyTraderPlantSlot;
                  collectionSlot.refreshCollectionCount();
               }
            }
         }
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = this.manager.hasCollectedAllItems();
         }
      }
      
      private function updateText() : void
      {
         var timeRemaining:Array = this.manager.getTimeRemaining();
         if(parseInt(timeRemaining[0]) > 1)
         {
            this.time_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            this.time_tf.text = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         setupFTUE();
         showFTUE();
      }
      
      public function enableWindow(enable:Boolean) : void
      {
         if(m_closeButton)
         {
            m_closeButton.visible = enable;
         }
         else if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.visible = enable;
         }
         m_whatIsThis_mc.enabled = enable;
         m_slotsFrame.enabled = enable;
         this.m_plantFrame.enabled = enable;
         if(enable)
         {
            untintWindow();
         }
         else
         {
            tintWindow();
         }
      }
      
      private function get manager() : GypsyTrader
      {
         return GypsyTrader.getInstance();
      }
   }
}

