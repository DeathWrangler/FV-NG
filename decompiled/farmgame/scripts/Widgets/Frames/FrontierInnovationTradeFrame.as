package Widgets.Frames
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationBasicLuxuryTradeSlot;
   import Widgets.Slots.FrontierInnovationTradeSlot;
   import Widgets.Slots.FrontierInnovationUpgradeTradeSlot;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FrontierInnovationTradeFrame extends FarmSlotContainerFrame
   {
      
      private var m_upgradeTradeFrame:FrontierInnovationUpgradeTradeFrame;
      
      private var m_basicTradeFrame:FrontierInnovationBasicLuxuryTradeFrame;
      
      private var m_luxuryTradeFrame:FrontierInnovationBasicLuxuryTradeFrame;
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var m_resourceTpe:String;
      
      private var m_r1Resource:String;
      
      private var m_r2Resource:String;
      
      private var m_confirmBt:FarmAnimatedTextButton;
      
      private var m_cancelBt:FarmAnimatedTextButton;
      
      private var m_itemTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_subtext0Tf:ZwTextField;
      
      private var m_subtext1Tf:ZwTextField;
      
      private var m_titleTf:ZwTextField;
      
      private const UPGRADE_TRADE_MC:String = "upgrade_trade_mc";
      
      private const BASICTASK_TRADE_MC:String = "basic_trade_mc";
      
      private const LUXURYTASK_TRADE_MC:String = "luxury_trade_mc";
      
      internal var manager:FrontierInnovationManager;
      
      private const OKAY_BT:String = "okay_bt";
      
      private const CANCEL_BT:String = "cancel_bt";
      
      private const ITEM_TF:String = "item_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const SUBTEXT0_TF:String = "subtext0_tf";
      
      private const SUBTEXT1_TF:String = "subtext1_tf";
      
      private const TITLE_TF:String = "tittle_tf";
      
      private var R1:int;
      
      private var R2:int;
      
      private var emptySlot:int;
      
      private var R1SlotActive:Boolean = false;
      
      private var R2SlotActive:Boolean = false;
      
      private var m_window:FrontierInnovationBarnWindow;
      
      public function FrontierInnovationTradeFrame(element:DisplayObject, featureName:String, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         if(m_element.hasOwnProperty(this.SUBTEXT0_TF))
         {
            this.m_subtext0Tf = addWidget(new ZwTextField(m_element[this.SUBTEXT0_TF],"Choose a resource you want in return")) as ZwTextField;
            this.m_subtext0Tf.visible = true;
         }
         if(m_element.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_element[this.TITLE_TF],"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.SUBTEXT1_TF))
         {
            this.m_subtext1Tf = addWidget(new ZwTextField(m_element[this.SUBTEXT1_TF],"Select an item you want to exchange")) as ZwTextField;
            this.m_subtext1Tf.visible = true;
         }
         if(m_element.hasOwnProperty(this.OKAY_BT))
         {
            addWidget(this.m_confirmBt = new FarmAnimatedTextButton(m_element[this.OKAY_BT],"Confirm Trade",this.onConformButton));
            this.m_confirmBt.visible = false;
         }
         if(m_element.hasOwnProperty(this.CANCEL_BT))
         {
            addWidget(this.m_cancelBt = new FarmAnimatedTextButton(m_element[this.CANCEL_BT],"",this.onCancelButton));
            this.m_cancelBt.visible = true;
         }
         if(m_element.hasOwnProperty(this.UPGRADE_TRADE_MC))
         {
            this.m_upgradeTradeFrame = new FrontierInnovationUpgradeTradeFrame(m_element[this.UPGRADE_TRADE_MC],this.m_featureName,window);
            this.m_upgradeTradeFrame.visible = false;
         }
         if(m_element.hasOwnProperty(this.BASICTASK_TRADE_MC))
         {
            this.m_basicTradeFrame = new FrontierInnovationBasicLuxuryTradeFrame(m_element[this.BASICTASK_TRADE_MC],this.m_featureName,window);
            this.m_basicTradeFrame.visible = false;
         }
         if(m_element.hasOwnProperty(this.LUXURYTASK_TRADE_MC))
         {
            this.m_luxuryTradeFrame = new FrontierInnovationBasicLuxuryTradeFrame(m_element[this.LUXURYTASK_TRADE_MC],this.m_featureName,window);
            this.m_luxuryTradeFrame.visible = false;
         }
      }
      
      public function setEmptySlot(slotNumber:int) : void
      {
         this.emptySlot = slotNumber;
      }
      
      private function initialise() : void
      {
         this.R1 = -1;
         this.R2 = -1;
         this.R1SlotActive = false;
         this.R2SlotActive = false;
         this.m_confirmBt.visible = false;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationTradeSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "item";
      }
      
      override protected function setupData() : void
      {
      }
      
      public function activeConformTradeButton(frameName:String) : void
      {
         this.m_confirmBt.visible = true;
         this.m_confirmBt.enabled = true;
         this.m_frameName = frameName;
      }
      
      private function onCancelButton(event:Event) : void
      {
         this.manager.clearTradeSlot(this.m_frameName);
         this.manager.closeTradeFrame(this.m_frameName);
         this.allTradeFrameClearSlot();
         this.m_confirmBt.visible = false;
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      private function onConformButton(event:Event) : void
      {
         this.m_confirmBt.enabled = false;
         if("upgrade_trade_mc" == this.m_frameName)
         {
            this.m_upgradeTradeFrame.onConform();
         }
         else if("basic_trade_mc" == this.m_frameName)
         {
            this.m_basicTradeFrame.onConform();
         }
         else if("luxury_trade_mc" == this.m_frameName)
         {
            this.m_luxuryTradeFrame.onConform();
         }
      }
      
      public function setTradeTitle(resourceType:String) : void
      {
         var prefix:String = null;
         if("upgrade_mc" == resourceType)
         {
            prefix = "Upgrade";
         }
         else if("basic_mc" == resourceType)
         {
            prefix = "Basic";
         }
         else if("luxury_mc" == resourceType)
         {
            prefix = "Luxury";
         }
         this.m_titleTf.text = prefix + " Resource Trading";
         this.m_titleTf.visible = true;
      }
      
      public function setupFrame(slotNumber:int, itemCode:String, resourceType:String, emptySlot:int) : void
      {
         this.m_frameName = resourceType;
         if("upgrade_mc" == resourceType)
         {
            this.m_upgradeTradeFrame.visible = true;
            this.m_upgradeTradeFrame.setFrameData(true,itemCode);
            (this.m_upgradeTradeFrame["slots"][0] as FrontierInnovationUpgradeTradeSlot).setGivingResource();
            this.m_upgradeTradeFrame.setR2(0,itemCode);
            this.m_upgradeTradeFrame.setEmptySlot(emptySlot);
         }
         else if("basic_mc" == resourceType)
         {
            this.m_basicTradeFrame.visible = true;
            this.m_basicTradeFrame.setFrameData(true,itemCode);
            (this.m_basicTradeFrame["slots"][0] as FrontierInnovationBasicLuxuryTradeSlot).setGivingResource();
            this.m_basicTradeFrame.setR2(0,itemCode);
            this.m_basicTradeFrame.setEmptySlot(emptySlot);
         }
         else if("luxury_mc" == resourceType)
         {
            this.m_luxuryTradeFrame.visible = true;
            this.m_luxuryTradeFrame.setFrameData(true,itemCode);
            (this.m_luxuryTradeFrame["slots"][0] as FrontierInnovationBasicLuxuryTradeSlot).setGivingResource();
            this.m_luxuryTradeFrame.setR2(0,itemCode);
            this.m_luxuryTradeFrame.setEmptySlot(emptySlot);
         }
      }
      
      public function disableFrame(resourceType:*) : void
      {
         if("upgrade_trade_mc" == resourceType)
         {
            this.m_upgradeTradeFrame.visible = false;
         }
         else if("basic_trade_mc" == resourceType)
         {
            this.m_basicTradeFrame.visible = false;
         }
         else if("luxury_trade_mc" == resourceType)
         {
            this.m_luxuryTradeFrame.visible = false;
         }
      }
      
      public function otherSlotsActive(frameName:String) : Boolean
      {
         var flag:Boolean = false;
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            flag = this.m_upgradeTradeFrame.slotActive();
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            flag = this.m_basicTradeFrame.slotActive();
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            flag = this.m_luxuryTradeFrame.slotActive();
         }
         return flag;
      }
      
      public function makeOtherSlotsInactive(frameName:String) : void
      {
         var slotNumber:int = 0;
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            slotNumber = this.m_upgradeTradeFrame.getR1();
            (this.m_upgradeTradeFrame["slots"][slotNumber] as FrontierInnovationUpgradeTradeSlot).clearSlot();
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            slotNumber = this.m_basicTradeFrame.getR1();
            (this.m_basicTradeFrame["slots"][slotNumber] as FrontierInnovationBasicLuxuryTradeSlot).clearSlot();
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            slotNumber = this.m_luxuryTradeFrame.getR1();
            (this.m_luxuryTradeFrame["slots"][slotNumber] as FrontierInnovationBasicLuxuryTradeSlot).clearSlot();
         }
      }
      
      public function setR1SlotActive(R1Slot:int, m_slotResource:String, frameName:String) : void
      {
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            this.m_upgradeTradeFrame.setR1(R1Slot,m_slotResource);
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            this.m_basicTradeFrame.setR1(R1Slot,m_slotResource);
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            this.m_luxuryTradeFrame.setR1(R1Slot,m_slotResource);
         }
      }
      
      public function getR2(frameName:String) : int
      {
         var resource:int = 0;
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            resource = this.m_upgradeTradeFrame.getR2();
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            resource = this.m_basicTradeFrame.getR2();
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            resource = this.m_luxuryTradeFrame.getR2();
         }
         return resource;
      }
      
      public function getR1(frameName:String) : int
      {
         var resource:int = 0;
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            resource = this.m_upgradeTradeFrame.getR1();
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            resource = this.m_basicTradeFrame.getR1();
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            resource = this.m_luxuryTradeFrame.getR1();
         }
         return resource;
      }
      
      public function disableTradeSlotsButton(frameName:String) : void
      {
         var numberOfSlots:int = 0;
         var i:int = 0;
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            numberOfSlots = int(this.m_upgradeTradeFrame["slots"].length);
            for(i = 0; i < numberOfSlots; i++)
            {
               (this.m_upgradeTradeFrame["slots"][i] as FrontierInnovationUpgradeTradeSlot).disableSlotButton();
            }
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            numberOfSlots = int(this.m_basicTradeFrame["slots"].length);
            for(i = 0; i < numberOfSlots; i++)
            {
               (this.m_basicTradeFrame["slots"][i] as FrontierInnovationBasicLuxuryTradeSlot).disableSlotButton();
            }
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            numberOfSlots = int(this.m_luxuryTradeFrame["slots"].length);
            for(i = 0; i < numberOfSlots; i++)
            {
               (this.m_luxuryTradeFrame["slots"][i] as FrontierInnovationBasicLuxuryTradeSlot).disableSlotButton();
            }
         }
      }
      
      public function clearTradeSlots(frameName:String) : void
      {
         var numberOfSlots:int = 0;
         var i:int = 0;
         this.m_confirmBt.visible = false;
         this.m_upgradeTradeFrame.visible = false;
         this.m_basicTradeFrame.visible = false;
         this.m_luxuryTradeFrame.visible = false;
         if(frameName == this.UPGRADE_TRADE_MC)
         {
            this.m_upgradeTradeFrame.visible = true;
            numberOfSlots = int(this.m_upgradeTradeFrame["slots"].length);
            for(i = 0; i < numberOfSlots; i++)
            {
               (this.m_upgradeTradeFrame["slots"][i] as FrontierInnovationUpgradeTradeSlot).clearSlot();
            }
         }
         else if(frameName == this.BASICTASK_TRADE_MC)
         {
            this.m_basicTradeFrame.visible = true;
            numberOfSlots = int(this.m_basicTradeFrame["slots"].length);
            for(i = 0; i < numberOfSlots; i++)
            {
               (this.m_basicTradeFrame["slots"][i] as FrontierInnovationBasicLuxuryTradeSlot).clearSlot();
            }
         }
         else if(frameName == this.LUXURYTASK_TRADE_MC)
         {
            this.m_luxuryTradeFrame.visible = true;
            numberOfSlots = int(this.m_luxuryTradeFrame["slots"].length);
            for(i = 0; i < numberOfSlots; i++)
            {
               (this.m_luxuryTradeFrame["slots"][i] as FrontierInnovationBasicLuxuryTradeSlot).clearSlot();
            }
         }
      }
      
      public function allTradeFrameRefresh() : void
      {
         this.m_upgradeTradeFrame.refresh();
         this.m_basicTradeFrame.refresh();
         this.m_luxuryTradeFrame.refresh();
      }
      
      public function allTradeFrameClearSlot() : void
      {
         super.clearSlots();
         this.m_upgradeTradeFrame.clear();
         this.m_basicTradeFrame.clear();
         this.m_luxuryTradeFrame.clear();
      }
   }
}

