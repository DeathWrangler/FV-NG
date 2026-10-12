package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.XMASInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.XMASInnovationGiftFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class XMASInnovationGiftSlot extends ZwSlotFrame
   {
      
      private const ICON_MC:String = "icon_mc";
      
      private const TRADE_BT:String = "trade_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const CON1_MC:String = "con1_mc";
      
      private const CON2_MC:String = "con2_mc";
      
      private const CON3_MC:String = "con3_mc";
      
      private const TEXT_REDEEM:String = "_ChristmasUIWindow_RedeemButton_Text";
      
      private var m_featureName:String;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_conMc:Array = null;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      private var m_data:Object;
      
      private var m_slotIndex:Number = 0;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_windowPageFrame:XMASInnovationGiftFrame;
      
      public function XMASInnovationGiftSlot(element:DisplayObject, featureName:String, windowPageFrame:XMASInnovationGiftFrame)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_conMc = new Array();
         this.m_windowPageFrame = windowPageFrame;
         if(m_element.hasOwnProperty(this.TRADE_BT))
         {
            this.m_buyButton = new FarmAnimatedTextButton(m_element[this.TRADE_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_REDEEM),this.onBuyItem);
            this.m_buyButton.visible = true;
            this.m_buyButton.enabled = true;
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkMark = m_element[this.CHECKMARK_MC] as MovieClip;
         }
         this.m_isIconPreviewAdded = false;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.rewardItemName);
         this.m_slotIndex = this.m_data.slotIndex;
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            if(this.m_isIconPreviewAdded == true)
            {
               removeWidget(this.m_iconPreview);
               this.m_iconPreview.detachTooltip();
            }
            addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_element[this.ICON_MC],item,null,null,[100]),true);
            this.m_iconPreview.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
         }
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = XMASInnovationManager.getInstance(this.m_featureName).isRewardRedeemed(this.m_data.rewardItemName);
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = XMASInnovationManager.getInstance().getTimeRemainingForRedeemUnlock() < 0;
            this.m_buyButton.enabled = XMASInnovationManager.getInstance().isRewardRedeemable(this.m_slotIndex);
         }
         var xmasManagerObject:XMASInnovationManager = XMASInnovationManager.getInstance(this.m_featureName);
         this.fillConsumableMc(this.CON1_MC,xmasManagerObject.c1countList[this.m_slotIndex]);
         this.fillConsumableMc(this.CON2_MC,xmasManagerObject.c2countList[this.m_slotIndex]);
         this.fillConsumableMc(this.CON3_MC,xmasManagerObject.c3countList[this.m_slotIndex]);
         this.m_isIconPreviewAdded = true;
      }
      
      private function fillConsumableMc(mcName:String, conCount:int) : void
      {
         if(m_element.hasOwnProperty(mcName))
         {
            this.m_conMc[mcName] = m_element[mcName] as MovieClip;
            this.m_conMc[mcName].visible = true;
            if(this.m_conMc[mcName].hasOwnProperty(this.COUNT_TF))
            {
               this.m_conMc[mcName][this.COUNT_TF].visible = true;
               this.m_conMc[mcName][this.COUNT_TF].text = conCount;
            }
         }
      }
      
      private function onBuyItem(event:Event) : void
      {
         XMASInnovationManager.getInstance(this.m_featureName).buyItem(this.m_data.rewardItemName,this.m_slotIndex,this.m_windowPageFrame);
      }
   }
}

