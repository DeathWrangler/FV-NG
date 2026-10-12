package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BoraboraInnovationSpecialDecoSlot extends ZwSlotFrame
   {
      
      private var m_decoIcon:FarmIcon;
      
      private var m_hoverDecorItemMc:MovieClip;
      
      private var m_decoImgIcon:FarmIcon;
      
      private var m_decoNameTf:ZwTextField;
      
      private var m_buyDecoBT:FarmAnimatedTextButton;
      
      private var m_thumbsUPMc:MovieClip;
      
      private var m_thubmsCountTf:ZwTextField;
      
      private var m_decoHitArea:MovieClip;
      
      private var m_slotIndex:int;
      
      private var m_fcCost:int;
      
      private var m_skipFCBt:FarmAnimatedCashButton;
      
      private var m_item:FarmItem;
      
      public function BoraboraInnovationSpecialDecoSlot(element:DisplayObject, slotIndex:int)
      {
         super(element);
         this.m_slotIndex = slotIndex;
         if(m_element.hasOwnProperty("deco_icon_mc"))
         {
            addWidget(this.m_decoIcon = new FarmIcon(m_element["deco_icon_mc"]));
            this.m_decoIcon.visible = true;
         }
         if(m_element.hasOwnProperty("hover_decor_item_mc"))
         {
            this.m_hoverDecorItemMc = m_element["hover_decor_item_mc"] as MovieClip;
            this.m_hoverDecorItemMc.visible = false;
            if(this.m_hoverDecorItemMc.hasOwnProperty("deco_icon_img_mc"))
            {
               addWidget(this.m_decoImgIcon = new FarmIcon(this.m_hoverDecorItemMc["deco_icon_img_mc"]));
               this.m_decoImgIcon.visible = false;
            }
            if(this.m_hoverDecorItemMc.hasOwnProperty("deco_name_tf"))
            {
               addWidget(this.m_decoNameTf = new ZwTextField(this.m_hoverDecorItemMc["deco_name_tf"]));
               this.m_decoNameTf.visible = false;
            }
         }
         if(this.m_slotIndex != 4)
         {
            if(m_element.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_buyDecoBT = new FarmAnimatedTextButton(m_element["okay_bt"],"",this.onBuyDeco));
               this.m_buyDecoBT.visible = true;
            }
         }
         else if(m_element.hasOwnProperty("okay_bt"))
         {
            this.m_skipFCBt = new FarmAnimatedCashButton(m_element["okay_bt"],"Buy","12",this.onClickBuyButton);
         }
         if(m_element.hasOwnProperty("thumbs_up_mc"))
         {
            this.m_thumbsUPMc = m_element["thumbs_up_mc"] as MovieClip;
            this.m_thumbsUPMc.visible = true;
            if(this.m_thumbsUPMc.hasOwnProperty("thumbs_up_count_tf"))
            {
               addWidget(this.m_thubmsCountTf = new ZwTextField(this.m_thumbsUPMc["thumbs_up_count_tf"]));
               this.m_thubmsCountTf.visible = true;
            }
         }
         if(m_element.hasOwnProperty("deco_hitarea_mc"))
         {
            this.m_decoHitArea = m_element["deco_hitarea_mc"] as MovieClip;
            this.m_decoHitArea.visible = true;
            this.m_decoHitArea.addEventListener(MouseEvent.MOUSE_OVER,this.onDecoMouseRollOver);
            this.m_decoHitArea.addEventListener(MouseEvent.MOUSE_OUT,this.onDecoMouseRollOut);
         }
      }
      
      private static function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance("BoraBoraInnovation");
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(data["decoItem"]);
         if(this.m_item)
         {
            this.m_decoIcon.loadIcon(this.m_item.iconUrl);
            this.m_decoIcon.setIconSize(50,50);
            this.m_decoIcon.visible = true;
            if(this.m_slotIndex != 4)
            {
               this.m_buyDecoBT.visible = true;
               this.m_buyDecoBT.text = data["total"].toString();
               this.m_buyDecoBT.enabled = manager.getBoraboraMoney() >= data["total"];
            }
            else
            {
               this.m_skipFCBt.visible = true;
               this.m_fcCost = data["fc"];
               this.m_skipFCBt.setAmountText(this.m_fcCost.toString());
               this.m_skipFCBt.detachTooltip();
               this.m_skipFCBt.enabled = true;
               this.m_skipFCBt.visible = true;
            }
            this.m_thumbsUPMc.visible = true;
            this.m_decoImgIcon.loadIcon(this.m_item.iconUrl);
            this.m_decoImgIcon.setIconSize(100,100);
            this.m_decoNameTf.text = this.m_item.friendlyTitle;
            this.m_thubmsCountTf.visible = true;
            this.m_thubmsCountTf.text = data["thumbs"];
         }
      }
      
      private function onBuyDeco(event:Event) : void
      {
         manager.setPanelDisplayValue(2);
         manager.onBuyDecoUtil(this.m_item);
      }
      
      private function onDecoMouseRollOver(event:MouseEvent) : void
      {
         this.m_hoverDecorItemMc.visible = true;
         this.m_decoImgIcon.visible = true;
         this.m_decoNameTf.visible = true;
      }
      
      private function onDecoMouseRollOut(event:MouseEvent) : void
      {
         this.m_hoverDecorItemMc.visible = false;
      }
      
      private function onClickBuyButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","buyDeco_CashBuyConfirmation",{"price":this.m_fcCost});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"buyItemByFC",true,true))
         {
            this.m_skipFCBt.enabled = false;
            manager.mainWindow.tintWindow();
            manager.mainWindow.enableInput = false;
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            if(Global.player.canBuyCash(this.m_fcCost))
            {
               manager.setPanelDisplayValue(2);
               manager.onBuyDecoUtil(this.m_item);
            }
            else
            {
               this.m_skipFCBt.enabled = true;
               manager.mainWindow.untintWindow();
               manager.mainWindow.enableInput = true;
            }
         }
         else
         {
            this.m_skipFCBt.enabled = true;
            manager.mainWindow.untintWindow();
            manager.mainWindow.enableInput = true;
         }
      }
   }
}

