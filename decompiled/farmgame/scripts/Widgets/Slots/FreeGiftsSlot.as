package Widgets.Slots
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.Requests2Manager;
   import Managers.ToasterManager;
   import Transactions.TSendRequest2Gifts;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeedPostCompleteToasterWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import Widgets.Windows.MFSSendFreeGifts;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   
   public class FreeGiftsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 79;
      
      private var m_item:FarmItem = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_itemName:ZwTextField = null;
      
      private var m_slotTitle:ZwTextField = null;
      
      private var m_cellFrame:ZwWidget = null;
      
      private var m_frame:ZwWidget = null;
      
      private var m_stroke:ZwWidget = null;
      
      private var m_sendButton:FarmAnimatedTextButton = null;
      
      private var m_helpButton:FarmAnimatedTextButton = null;
      
      private var m_ref:String = "";
      
      private var m_parentWindow:FarmWindow = null;
      
      private var m_requestSentServerTime:int = -1;
      
      public function FreeGiftsSlot(element:DisplayObject, ref:String = "free_gifts_full_mfs", parentWindow:FarmWindow = null)
      {
         super(element);
         this.m_sendButton = addWidget(new FarmAnimatedTextButton(m_element.play_bt,ZLocUtils.t("Dialogs","Send"),null)) as FarmAnimatedTextButton;
         this.m_icon = addWidget(new FarmIcon(m_element.loader_mc)) as FarmIcon;
         this.m_itemName = addWidget(new ZwTextField(m_element.title_tf)) as ZwTextField;
         this.m_slotTitle = addWidget(new ZwTextField(m_element.generic_tf)) as ZwTextField;
         this.m_cellFrame = addWidget(new ZwWidget(m_element.cellFrame_mc)) as ZwWidget;
         this.m_frame = addWidget(new ZwWidget(m_element.frame_mc)) as ZwWidget;
         this.m_stroke = addWidget(new ZwWidget(m_element.stroke_mc)) as ZwWidget;
         this.m_ref = ref;
         this.m_parentWindow = parentWindow;
         (this.element as MovieClip).addEventListener(MouseEvent.CLICK,this.onClickSend);
         (this.element as MovieClip).buttonMode = true;
         if(m_element.question_bt)
         {
            this.m_helpButton = addWidget(new FarmAnimatedTextButton(m_element.question_bt,"?"),false) as FarmAnimatedTextButton;
            this.m_helpButton.attachTooltip(new MarketTooltip());
         }
      }
      
      override public function populate(data:Object) : void
      {
         var colorTransfom:ColorTransform = null;
         var glowFilter:GlowFilter = null;
         var toolTipText:String = null;
         if(data is FarmItem)
         {
            this.m_item = data as FarmItem;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FREE_GIFTS_BITMAP_SMOOTHING) == 1)
            {
               this.m_icon.setSmoothing(true);
            }
            this.m_icon.loadIcon(this.m_item.icon);
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_itemName.text = this.m_item.friendlyTitle;
            colorTransfom = this.m_cellFrame.transform.colorTransform;
            colorTransfom.color = this.m_item.freeGiftColor;
            this.m_cellFrame.transform.colorTransform = colorTransfom;
            glowFilter = this.m_slotTitle.element.filters[0];
            glowFilter.color = this.m_item.freeGiftColor;
            this.m_slotTitle.element.filters = [glowFilter];
            this.m_slotTitle.text = this.m_item.freeGiftTitle;
            this.m_icon.visible = true;
            this.m_itemName.visible = true;
            this.m_cellFrame.visible = true;
            this.m_frame.visible = true;
            this.m_slotTitle.visible = true;
            this.m_stroke.visible = true;
            this.m_sendButton.visible = true;
            if(this.m_helpButton)
            {
               this.m_helpButton.visible = true;
               toolTipText = ZLocUtils.t("Dialogs","FreeGiftsSelection_SDB_ToolTip");
               if(this.m_item.code != "Zg")
               {
                  toolTipText = Global.flashHotParams["FREE_GIFT_ITEM_TOOLTIP_TEXT"];
               }
               (this.m_helpButton.tooltip as MarketTooltip).setText(toolTipText);
               this.m_icon.loadIcon(this.m_item.getImageByName(FarmItem.ICON_FEED));
               this.m_icon.setIconSize(ICON_SIZE * 2,ICON_SIZE * 2);
            }
         }
      }
      
      override public function release() : void
      {
         (this.element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onClickSend);
         this.m_item = null;
         this.m_icon = null;
         this.m_itemName = null;
         this.m_slotTitle = null;
         this.m_cellFrame = null;
         this.m_frame = null;
         this.m_sendButton = null;
         this.m_stroke = null;
         super.release();
      }
      
      private function onClickSend(event:Event) : void
      {
         var toUid:String = null;
         var requestText:String = null;
         var requestTitle:String = null;
         var requestData:String = null;
         if(this.m_parentWindow != null)
         {
            this.m_parentWindow.close();
            UI.displayPopup(new MFSSendFreeGifts(this.m_item,"free_gift_selection",null,this.m_ref));
         }
         else
         {
            toUid = FreeGiftSelectionWindow.getToUid();
            if(toUid == FreeGiftSelectionWindow.NO_TO_UID)
            {
               FreeGiftSelectionWindow.closeWindow();
               UI.displayPopup(new MFSSendFreeGifts(this.m_item,"free_gift_selection",null,this.m_ref));
            }
            else
            {
               requestText = ZLocUtils.t_pk("Gifts","request_text_nodate",{
                  "GIFT_NAME":this.m_item.friendlyTitle,
                  "APP_NAME":MFSConstants.GAME_NAME_FARMVILLE
               });
               requestTitle = ZLocUtils.t_pk("Gifts","GiftRequestTitle");
               requestData = this.getRequestData();
               Requests2Manager.sendGift(requestData,requestText,requestTitle,[toUid],"free_gift_selection",this.fbResponse);
            }
         }
      }
      
      private function getRequestData() : String
      {
         var requestData:Array = [];
         this.m_requestSentServerTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_GIFT);
         requestData.push(this.m_item.code);
         requestData.push(this.m_requestSentServerTime);
         requestData.push("free_gift_selection");
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.GAME_NAME_FARMVILLE);
         requestData.push(MFSConstants.IS_WISH);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      private function fbResponse(response:Object) : void
      {
         var requestIds:Array = response["request_ids"] as Array;
         if(Boolean(requestIds) && requestIds.length > 0)
         {
            TransactionManager.addTransaction(new TSendRequest2Gifts(this.m_item.code,requestIds,MFSConstants.MFS_TYPE_SEND_FREE_GIFT,"free_gift_selection",this.m_requestSentServerTime,function(result:Object):void
            {
               ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow(ZLocUtils.t("Dialogs","GiftSent"),m_item.iconUrl,new Point(0,0)));
            }),true);
            FreeGiftSelectionWindow.closeWindow();
         }
      }
   }
}

