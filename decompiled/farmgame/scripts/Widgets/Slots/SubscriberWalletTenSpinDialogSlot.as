package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.SubscriberWalletManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.SubscriberWalletTenSpinDialog;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SubscriberWalletTenSpinDialogSlot extends ZwSlotFrame
   {
      
      private static const CHECKED:int = 2;
      
      private static const UNCHECKED:int = 1;
      
      private var m_featureName:String;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_itemCode:String;
      
      private var m_check_mc:MovieClip;
      
      private var m_rewardIndex:int;
      
      private var m_checkedFlag:Boolean;
      
      private var m_freezeState:Boolean;
      
      private var m_mainWindow:SubscriberWalletTenSpinDialog;
      
      public function SubscriberWalletTenSpinDialogSlot(element:DisplayObject, featureName:String, mainWindow:SubscriberWalletTenSpinDialog)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_isIconPreviewAdded = false;
         this.m_mainWindow = mainWindow;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var scene:int = 0;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.rewardItemName);
         if(data.type == "common")
         {
            scene = 1;
         }
         else if(data.type == "rare")
         {
            scene = 2;
            (m_element["rareTag"] as MovieClip).visible = true;
         }
         else if(data.type == "superrare")
         {
            (m_element["superRareTag"] as MovieClip).visible = true;
            scene = 3;
         }
         else if(data.type == "ultrarare")
         {
            (m_element["UltraRareTag"] as MovieClip).visible = true;
            scene = 4;
         }
         this.m_itemCode = data.rewardItemName;
         this.m_rewardIndex = data.index;
         this.m_icon_mc = new FarmIcon(m_element["icon_mc"],item.iconUrl);
         this.m_icon_mc.visible = true;
         this.m_icon_mc.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
         this.m_check_mc = m_element["checkmark_mc"] as MovieClip;
         if(data.checked == true)
         {
            this.m_check_mc.gotoAndStop(CHECKED);
         }
         else
         {
            this.m_check_mc.gotoAndStop(UNCHECKED);
         }
         this.m_check_mc.visible = !data.freeze;
         if(!data.checked && SubscriberWalletManager.getInstance().getTenRewardExchangeButtonClickFlag() == true)
         {
            (m_element as MovieClip).alpha = 0.5;
         }
         else if(data.freeze == true)
         {
            (m_element as MovieClip).alpha = 0.5;
         }
         else
         {
            (m_element as MovieClip).alpha = 1;
         }
         this.m_freezeState = data.freeze;
         this.m_checkedFlag = data.checked;
         this.m_check_mc.addEventListener(MouseEvent.CLICK,this.updateOnRewardSelection);
      }
      
      private function updateOnRewardSelection(event:MouseEvent) : void
      {
         if(this.m_freezeState == false)
         {
            if(this.m_check_mc.currentFrame == 1)
            {
               this.m_check_mc.gotoAndStop(CHECKED);
            }
            else
            {
               this.m_check_mc.gotoAndStop(UNCHECKED);
            }
            this.m_checkedFlag = !this.m_checkedFlag;
            SubscriberWalletManager.getInstance().updateRewardState(this.m_rewardIndex,this.m_checkedFlag);
         }
      }
      
      override public function release() : void
      {
         this.m_icon_mc.detachTooltip();
         this.m_icon_mc = null;
         super.release();
      }
   }
}

