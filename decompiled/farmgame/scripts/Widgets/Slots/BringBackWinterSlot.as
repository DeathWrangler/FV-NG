package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.BringBackWinterManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BBWinterReskinnableWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BringBackWinterSlot extends ZwSlotFrame
   {
      
      private static const OFFSET_OPF_X:int = 50;
      
      private static const OFFSET_OPF_Y:int = 0;
      
      private var m_featureName:String;
      
      private const NO_OF_SLOTS:int = 4;
      
      private var m_window:BBWinterReskinnableWindow;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_icon:ResourcePreviewFrame;
      
      private var m_icon1:ObjectPreviewFrame;
      
      private var m_icon2:FarmIcon;
      
      private var m_data:Object;
      
      private var m_windowName:String;
      
      private var sfRequired:Array;
      
      private var sfIcon_mc:Array;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_eggMc:MovieClip;
      
      private var m_redeemItem:FarmItem;
      
      private const X:String = "x";
      
      private const whatIsHappening:String = "This had better work!";
      
      private var m_slotIndex:int;
      
      public function BringBackWinterSlot(element:DisplayObject, featureName:String, window:BBWinterReskinnableWindow)
      {
         var j:int = 0;
         var btnText:String = null;
         var sfC:ZwTextField = null;
         var sfIcon:MovieClip = null;
         this.sfRequired = new Array();
         this.sfIcon_mc = new Array();
         super(element);
         this.m_featureName = featureName;
         this.m_window = window;
         this.m_windowName = BringBackWinterManager.getInstance(this.m_featureName).getWindowName();
         if(m_element.hasOwnProperty("use_bt"))
         {
            btnText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_RedeemButtonText");
            this.m_redeemButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,btnText,this.onRedeemClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("buyprize_bt"))
         {
            addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buyprize_bt,"Buy","",this.onBuyItem),false);
         }
         if(m_element.hasOwnProperty("points_mc"))
         {
            m_element["points_mc"].visible = true;
            addWidget(this.m_pointsTf = new ZwTextField(m_element["points_tf"],"10"));
         }
         j = 1;
         for(var i:int = 0; i < BringBackWinterManager.SFTYPES.length; i++)
         {
            if(m_element.hasOwnProperty("rewardcount_" + j.toString() + "_tf") && m_element.hasOwnProperty("rewardcount_" + j.toString() + "_icon"))
            {
               sfC = new ZwTextField(m_element["rewardcount_" + j.toString() + "_tf"],this.X + 0,true);
               addWidget(sfC,true) as FarmTextField;
               this.sfRequired[j - 1] = sfC;
               sfIcon = m_element["rewardcount_" + j.toString() + "_icon"] as MovieClip;
               sfIcon.visible = false;
               this.sfIcon_mc[j - 1] = sfIcon;
               j++;
            }
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmarkMc = m_element["checkmark_mc"] as MovieClip;
         }
         if(m_element.hasOwnProperty("egg_mc"))
         {
            this.m_eggMc = m_element.egg_mc as MovieClip;
         }
      }
      
      private function onRedeemClick(event:Event) : void
      {
         if(!this.m_window.isFTUEOn())
         {
            BringBackWinterManager.getInstance(this.m_featureName).redeemRewardForSnowFlakes(this.m_data);
            FarmStatsManager.count("GPF_royalrescue2018","Reward",this.m_data.index);
         }
      }
      
      private function onBuyItem(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_featureName + "BuyConfirmPopup",{
            "cashQuantity":item.cash,
            "item":item.friendlyTitle
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyItemPopupClose,"",true);
      }
      
      private function onConfirmBuyItemPopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            BringBackWinterManager.getInstance(this.m_featureName).buyCollectionItem(this.m_data.name);
            FarmStatsManager.count("GPF_royalrescue2018","Buy",this.m_data.index);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var sfC:ZwTextField = null;
         var sfIcon:MovieClip = null;
         super.populate(data);
         this.m_data = data;
         this.m_redeemButton.visible = true;
         this.m_redeemButton.enabled = true;
         this.m_slotIndex = this.m_data.index;
         var j:int = 0;
         for(var i:int = 0; i < BringBackWinterManager.SFTYPES.length; i++)
         {
            if(this.sfIcon_mc[i])
            {
               (this.sfIcon_mc[i] as MovieClip).visible = false;
            }
            if(Boolean(data.hasOwnProperty(BringBackWinterManager.SFTYPES[i])) && Boolean(this.sfRequired[j]) && Boolean(this.sfIcon_mc[j]))
            {
               sfC = this.sfRequired[j] as ZwTextField;
               if(sfC)
               {
                  sfC.text = this.X + data[BringBackWinterManager.SFTYPES[i]];
                  sfC.visible = true;
               }
               sfIcon = this.sfIcon_mc[j] as MovieClip;
               sfIcon.visible = true;
               sfIcon.gotoAndStop(BringBackWinterManager.SFTYPES[i]);
               j++;
            }
         }
         if(this.m_pointsTf)
         {
            this.m_pointsTf.text = data.bonus.toString();
            this.m_pointsTf.visible = true;
         }
         this.m_icon = null;
         this.m_redeemItem = Global.farmGameSettingsManager.getFarmItemByName(data.name);
         if(this.m_icon2)
         {
            removeWidget(this.m_icon2);
            this.m_icon2 = null;
         }
         if(this.m_icon1)
         {
            removeWidget(this.m_icon1);
            this.m_icon1 = null;
         }
         this.m_icon1 = new ObjectPreviewFrame(m_element.icon_mc,this.m_redeemItem,null,null,null,"","",null,new Point(50,-90));
         addWidget(this.m_icon1,true);
         this.m_icon1.visible = true;
         if(this.m_buyButton)
         {
            this.m_buyButton.setAmountText(this.m_redeemItem.cash.toString());
         }
         this.detachTooltip();
         this.m_eggMc.gotoAndStop(this.m_data.index);
         this.attachTooltip(new FarmTextTooltip(this.m_redeemItem.friendlyTitle));
         this.refreshSlot();
      }
      
      private function getSfCollectionCount() : Object
      {
         var sfCollection:Object = new Object();
         for(var i:int = 0; i < BringBackWinterManager.SFTYPES.length; i++)
         {
            sfCollection[BringBackWinterManager.SFTYPES[i]] = Global.player.getGiftCountForItem(BringBackWinterManager.getSfTypeToItemName(BringBackWinterManager.SFTYPES[i]));
         }
         return sfCollection;
      }
      
      public function refreshSlot() : void
      {
         this.m_checkmarkMc.visible = BringBackWinterManager.getInstance(this.m_featureName).hasCollectedItem(this.m_data.name);
         if(Boolean(this.m_data) && Boolean(this.m_redeemButton) && !BringBackWinterManager.getInstance(this.m_featureName).areSnowFlakeReqsMetFor(this.m_data))
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.applyGrayOut = true;
         }
         else
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.applyGrayOut = false;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = this.m_checkmarkMc.visible;
         }
         if(this.m_pointsTf)
         {
            this.m_pointsTf.text = this.m_data.bonus.toString();
            this.m_pointsTf.visible = true;
         }
         if(this.m_eggMc)
         {
            this.m_eggMc.visible = !this.m_checkmarkMc.visible;
         }
         if(this.m_icon1)
         {
            this.m_icon1.visible = this.m_checkmarkMc.visible;
         }
         if(this.m_icon2)
         {
            this.m_icon2.visible = this.m_checkmarkMc.visible;
         }
         if(this.m_checkmarkMc.visible == false)
         {
            this.detachTooltip();
         }
         if(this.m_checkmarkMc.visible == true)
         {
            this.attachTooltip(new FarmTextTooltip(this.m_redeemItem.friendlyTitle));
         }
      }
   }
}

