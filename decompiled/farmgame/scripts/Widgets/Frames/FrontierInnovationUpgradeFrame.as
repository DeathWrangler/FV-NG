package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationUpgradeSlot;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationUpgradeFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var m_titleTf:ZwTextField;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_upgradeBt:FarmAnimatedTextButton;
      
      private var m_barnFullMc:MovieClip;
      
      private const BUY_BT:String = "buy_bt";
      
      private const UPGRADE_BT:String = "upgrade_bt";
      
      private const BARNFULL_MC:String = "barnfull_mc";
      
      private var m_window:FrontierInnovationBarnWindow;
      
      internal var manager:FrontierInnovationManager;
      
      public function FrontierInnovationUpgradeFrame(element:DisplayObject, featureName:String, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_frameName = element.name;
         this.m_frameName = m_element.name;
         if(m_element.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = new ZwTextField(m_element["title_tf"]);
            this.m_titleTf.text = "Upgrade Resources";
            this.m_titleTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.BUY_BT))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element[this.BUY_BT],"Complete","10",this.onClickBuyButton));
            this.m_skipBt.visible = true;
         }
         if(m_element.hasOwnProperty(this.UPGRADE_BT))
         {
            addWidget(this.m_upgradeBt = new FarmAnimatedTextButton(m_element[this.UPGRADE_BT],"",this.onClickUpgradeButton));
            this.m_upgradeBt.text = "Upgrade Barn";
            this.m_upgradeBt.visible = true;
            this.upgradeButtonCheck();
         }
         if(m_element.hasOwnProperty(this.BARNFULL_MC))
         {
            this.m_barnFullMc = m_element[this.BARNFULL_MC] as MovieClip;
            this.m_barnFullMc.visible = this.isBarnCapacityFull();
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationUpgradeSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "item";
      }
      
      override protected function setupData() : void
      {
         var temp:Object = null;
         m_slotData = [];
         var data:Array = this.manager.getSortedUpgradeFrameData();
         for(var i:int = 0; i < data.length; i++)
         {
            temp = data[i];
            m_slotData.push({
               "Count":temp["value"],
               "resourceCode":temp["key"]
            });
         }
      }
      
      public function isBarnCapacityFull() : Boolean
      {
         var barnReachedMaxCapacity:Boolean = this.manager.isBarnCapacityReached();
         if(barnReachedMaxCapacity)
         {
            this.m_upgradeBt.visible = false;
            this.m_skipBt.visible = false;
         }
         return barnReachedMaxCapacity;
      }
      
      public function upgradeButtonCheck() : void
      {
         this.m_skipBt.enabled = true;
         if(this.manager.sufficientUpgradeResources())
         {
            this.m_upgradeBt.enabled = true;
         }
         else
         {
            this.m_upgradeBt.enabled = false;
         }
      }
      
      private function onClickBuyButton(event:Event) : void
      {
         var confirmationText:String = null;
         var isFull:Boolean = this.isBarnCapacityFull();
         if(!this.isBarnCapacityFull())
         {
            confirmationText = ZLocUtils.t("Dialogs","UpgradeBarnCapacity_CashBuyConfirmation",{"price":10});
            if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"upgradeBarnCapacityByFC",true,true))
            {
               this.m_skipBt.enabled = false;
               this.m_window.tintWindow();
               this.m_window.enableInput = false;
            }
         }
         else
         {
            this.m_barnFullMc.visible = isFull;
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.manager.onUpgradeByPayFC();
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.m_window.untintWindow();
            this.m_window.enableInput = true;
         }
      }
      
      private function onClickUpgradeButton(event:Event) : void
      {
         var isFull:Boolean = this.isBarnCapacityFull();
         if(!isFull)
         {
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
            this.manager.upgradeAction();
         }
         else
         {
            this.m_barnFullMc.visible = isFull;
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         var isBarnFull:Boolean = this.isBarnCapacityFull();
         if(isBarnFull)
         {
            this.m_barnFullMc.visible = true;
         }
         else
         {
            this.upgradeButtonCheck();
         }
         super.refresh();
      }
   }
}

